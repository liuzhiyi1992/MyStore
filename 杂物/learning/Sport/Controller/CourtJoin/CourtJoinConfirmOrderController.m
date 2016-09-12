//
//  CourtJoinConfirmOrderController.m
//  Sport
//
//  Created by 江彦聪 on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinConfirmOrderController.h"
#import "CourtJoinService.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "PriceUtil.h"
#import "DateUtil.h"
#import "OrderService.h"
#import "PayController.h"

@interface CourtJoinConfirmOrderController ()
@property (strong, nonatomic) NSString *courtJoinId;
@property (strong, nonatomic) ConfirmOrder *confirmOrder;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *courtTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *courtTipsLabel;

@property (weak, nonatomic) IBOutlet UILabel *courtDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) CourtJoin *courtJoin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CourtDetailHolderViewHeight;
@property (weak, nonatomic) IBOutlet UIView *courtDetailView;
@property (weak, nonatomic) IBOutlet UIImageView *courtDetailTopView;
@property (weak, nonatomic) IBOutlet UILabel *courtDetailBottomView;

@end

@implementation CourtJoinConfirmOrderController

-(instancetype) initWithCourtJoin:(CourtJoin *)courtJoin {
    self = [super init];
    if (self) {
        self.courtJoin = courtJoin;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.submitButton.layer.cornerRadius = 20.0;
    self.submitButton.layer.masksToBounds = YES;
    
    self.title = @"确认订单";
    
    [self queryData];
}

-(void) queryData {
    __weak __typeof(self) weakSelf = self;

    [SportProgressView showWithStatus:@"加载中"];
    [CourtJoinService confirmOrderCourtJoinWithId:self.courtJoin.courtJoinId userId:[[UserManager defaultManager] readCurrentUser].userId completion:^(NSString *status, NSString *msg, CourtJoin *courtJoin){
        if ([status isEqualToString:STATUS_SUCCESS]){
            [SportProgressView dismiss];
            weakSelf.courtJoin = courtJoin;
            [weakSelf updateViewWithCourtJoin:courtJoin];
        } else {
            [SportProgressView dismissWithError:msg];
        }
    }];
}

-(void) updateViewWithCourtJoin:(CourtJoin *)courtJoin {
    
    self.categoryNameLabel.text = courtJoin.categoryName;
    self.businessNameLabel.text = courtJoin.businessName;
    
    NSMutableString *courtTimeStr = [NSMutableString string];
    int index = 0;
    for (Product *product in self.courtJoin.productList) {
        [courtTimeStr appendString:[NSString stringWithFormat:@"%@ %@ ", product.courtName, [product startTimeToEndTime]]];
        [courtTimeStr appendString:[PriceUtil toPriceStringWithYuan:product.courtJoinPrice]];
        if (index < [courtJoin.productList count] - 1) {
            [courtTimeStr appendString:@"\n"];
        }
        
        index++;
    }
    
    self.courtTimeLabel.text = courtTimeStr;
    
    self.courtTipsLabel.text = courtJoin.priceTagMsg;
    self.priceLabel.text = [PriceUtil toPriceStringWithYuan:courtJoin.price];
    self.phoneLabel.text = [NSString stringWithFormat:@"您的手机号码：%@", [[UserManager defaultManager] readCurrentUser].phoneNumber];
    self.courtDateLabel.text = [DateUtil dateStringWithTodayAndOtherWeekday:courtJoin.bookDate];
    [self showCourtDetailView];
}

- (IBAction)clickSubmitButton:(id)sender {

    User *user = [[UserManager defaultManager] readCurrentUser];
    
    [SportProgressView showWithStatus:@"加载中"];
    [OrderService submitOrderByCourtJoinWithUserId:user.userId courtJoinId:self.courtJoin.courtJoinId phone:user.phoneEncode completion:^(NSString *status, NSString *msg, Order *order) {
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [SportProgressView dismiss];
            [MobClickUtils event:umeng_event_court_join_pay_request];
            PayController *controller = [[PayController alloc]initWithOrder:order];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [SportProgressView dismissWithError:msg];
        }
    }];
}

-(void) showCourtDetailView {
    
    NSDictionary *group = [self.courtJoin createCourtJoinGroup];
    NSArray *nameList = [group allKeys];
    
    NSMutableDictionary *viewsDictionary = [[ NSMutableDictionary alloc] initWithDictionary:@{@"courtDetailView":self.courtDetailView,@"topView":self.courtDetailTopView}];
    NSMutableArray *constraints = [NSMutableArray array];
    
    int courtIndex = 0;
    UILabel *lastCourtLabel = nil;
    for (NSString *name in nameList) {
        UILabel *courtLabel = [[UILabel alloc]init];
        courtLabel.font = [UIFont systemFontOfSize:14];
        courtLabel.backgroundColor = [UIColor clearColor];
        courtLabel.textColor = [SportColor content1Color];
        courtLabel.text = name;
        courtLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.courtDetailView addSubview:courtLabel];
        
        [viewsDictionary addEntriesFromDictionary:@{ @"currentCourtLabel":courtLabel}];
        
        if (courtIndex == 0) {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-15-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
        }else {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastValueLabel]-5-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
        }

        lastCourtLabel = courtLabel;
        [viewsDictionary addEntriesFromDictionary:@{ @"lastCourtLabel":lastCourtLabel}];
        
        //add时间价钱的view
        int valueIndex = 0;
        UILabel *lastValueLabel = nil;
        NSArray *valueList = [group objectForKey:name];
        for (NSString *oneValue in valueList) {
            UILabel *valueLabel = [[UILabel alloc] init] ;
            valueLabel.font = [UIFont systemFontOfSize:14];
            valueLabel.backgroundColor = [UIColor clearColor];
            valueLabel.textColor = [SportColor highlightTextColor];
            valueLabel.text = oneValue;
            valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.courtDetailView addSubview:valueLabel];

            UIImageView *iconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CourtJoinIcon"]];
            iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.courtDetailView addSubview:iconImageView];
            
            [viewsDictionary addEntriesFromDictionary:@{@"valueLabel":valueLabel, @"iconImageView":iconImageView}];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[iconImageView(15)]-15-|" options:0 metrics:nil views:viewsDictionary]];

            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[valueLabel]-5-[iconImageView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
            
            if(valueIndex == 0 && courtIndex == 0) {
                
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-15-[iconImageView(15)]" options:0 metrics:nil views:viewsDictionary]];
            } else {
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastValueLabel]-5-[valueLabel]" options:0 metrics:nil views:viewsDictionary]];
            }
            
            lastValueLabel = valueLabel;
            [viewsDictionary addEntriesFromDictionary:@{ @"lastValueLabel":lastValueLabel}];

            valueIndex ++;
        }
        
        courtIndex++;
    }
    
    if ([constraints count] > 0) {
        [viewsDictionary addEntriesFromDictionary:@{ @"courtDetailBottomView":self.courtDetailBottomView}];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastValueLabel]-15-[courtDetailBottomView]" options:0 metrics:nil views:viewsDictionary]];
        [self.courtDetailView addConstraints:constraints];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
