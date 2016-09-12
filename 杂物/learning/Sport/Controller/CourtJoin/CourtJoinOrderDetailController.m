//
//  CourtJoinOrderDetailController.m
//  Sport
//
//  Created by 江彦聪 on 16/6/16.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinOrderDetailController.h"
#import "CourtJoinService.h"
#import "User.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "DateUtil.h"
#import "OrderService.h"
#import "LoginController.h"
#import "PayController.h"
#import "NoDataView.h"
#import "PriceUtil.h"
#import "CourtJoinUser.h"
#import "CourtJoinInfoCell.h"
#import "UIImageView+WebCache.h"
#import "SportImage.h"
#import "CourtJoinDetailController.h"
#import "BusinessMapController.h"
#import "UIUtils.h"
#import "ConversationViewController.h"
#import "SportPopupView.h"
#import "UIView+Utils.h"
#import "PayController.h"
#import "OrderAmountView.h"
#import "SportProgressView.h"
#import "UITableView+Utils.h"

@interface CourtJoinOrderDetailController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesLabel;
@property (weak, nonatomic) IBOutlet UILabel *courtDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSArray *titleList;
@property (strong, nonatomic) Order *order;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneCallButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payViewTopMargin;
@property (weak, nonatomic) IBOutlet UIView *payHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *courtDetailHoderHeight;

@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImageView;
@property (weak, nonatomic) IBOutlet UIView *courtJoinHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@end
#define TITLE_ORDER_NUM @"订单号："
#define TITLE_DATE @"下单日期："
#define TITLE_PAY  @"支付方式："
#define TITLE_STATUS @"订单状态："

@implementation CourtJoinOrderDetailController

-(instancetype) initWithOrder:(Order *)order {
    self = [self initWithOrderId:order.orderId];
    if (self) {
        self.order = order;
    }
    
    return self;
}

-(instancetype) initWithOrderId:(NSString *)orderId {
    self = [super init];
    if (self) {
        self.orderId = orderId;
    }
    
    return self;
}

#define TABLE_CELL_HEIGHT 23
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.joinButton roundSide:CornerSideAll size:20 borderColor:[SportColor defaultBlueColor].CGColor borderWidth:1];
    [self.joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.joinButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultBlueColor]] forState:UIControlStateHighlighted];
    [self.joinButton setBackgroundImage:[SportColor createImageWithColor:[SportColor content2Color]] forState:UIControlStateDisabled];
   
    [self.payButton roundSide:CornerSideAll size:20 borderColor:[SportColor defaultBlueColor].CGColor borderWidth:1];
    [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.payButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultBlueColor]] forState:UIControlStateHighlighted];
    
    self.avatarImageView.layer.cornerRadius = 25.0;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.sendMessageButton.layer.borderColor = [UIColor hexColor:@"4f6dcf"].CGColor;
    self.sendMessageButton.layer.borderWidth = 1.0;
    self.sendMessageButton.layer.cornerRadius = 10.0;
    self.sendMessageButton.layer.masksToBounds = YES;
    
    self.phoneCallButton.layer.borderColor = [UIColor hexColor:@"4f6dcf"].CGColor;
    self.phoneCallButton.layer.borderWidth = 1.0;
    self.phoneCallButton.layer.cornerRadius = 10.0;
    self.phoneCallButton.layer.masksToBounds = YES;
    
    self.title = @"订单详情";
    
    self.titleList = @[TITLE_ORDER_NUM,TITLE_DATE,TITLE_PAY,TITLE_STATUS];
    UINib *cellNib = [UINib nibWithNibName:[CourtJoinInfoCell getCellIdentifier] bundle:nil];
    
    [self.infoTableView registerNib:cellNib forCellReuseIdentifier:[CourtJoinInfoCell getCellIdentifier]];
    self.tableViewHeightConstraint.constant = [self.titleList count] * TABLE_CELL_HEIGHT + 20;
    [self queryData];
    
    [self updateViewWithOrder:self.order];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) queryData {
    
    self.courtJoinHolderView.hidden = YES;
    
    [SportProgressView showWithStatus:@"加载中"];
    
    __weak __typeof(self) weakSelf = self;
    [CourtJoinService getCourtJoinOrderDetailWithOrderId:self.orderId completion:^(NSString *status,NSString *msg, Order *order) {

        if ([status isEqualToString:STATUS_SUCCESS]) {
            [SportProgressView dismiss];
            weakSelf.order = order;
            [weakSelf updateViewWithOrder:order];
            self.courtJoinHolderView.hidden = NO;
        } else {
            [SportProgressView dismissWithError:msg];
        }
        
        //无数据时处理分支
        if([order.orderId length] == 0){
            //如果连日期都为空那么就全遮，
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-20-44);

            if([status isEqualToString:STATUS_SUCCESS]){
                [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
            } else{
                [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
            }
            
        }else{
            [self removeNoDataView];
        }
    }];
}


-(void) updateViewWithOrder:(Order *)order {
    if (order.status == OrderStatusUnpaid) {
        self.payButton.hidden = NO;
        self.payViewTopMargin.constant = 110.0f;
    } else {
        self.payButton.hidden = YES;
        self.payViewTopMargin.constant = 40.0f;
    }

    CourtJoin *courtJoin = order.courtJoin;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:courtJoin.avatarUrl ] placeholderImage:[SportImage avatarDefaultImage]];
    
    if ([courtJoin.gender length] == 0) {
        self.genderImageView.hidden = YES;
    }else {
        self.genderImageView.hidden = NO;
        
        UIImage *genderImage = [SportImage genderImageWithGender:courtJoin.gender];
        [self.genderImageView setImage:genderImage];
    }
    
    self.nameLabel.text = courtJoin.nickName;
    self.venuesLabel.text = courtJoin.businessName;
    self.dateLabel.text = [DateUtil dateStringWithTodayAndOtherWeekday:courtJoin.bookDate];
//    self.courtDetailLabel.text = [Product courtDetailString:courtJoin.productList];
    [self showCourtDetailView];
    self.priceLabel.text = [PriceUtil toPriceStringWithYuan:order.totalAmount];
    [self.infoTableView reloadData];
}

-(void) showCourtDetailView {
    
    NSDictionary *group = [self.order.courtJoin createCourtJoinGroup];
    NSArray *nameList = [group allKeys];
    
    NSMutableDictionary *viewsDictionary = [[ NSMutableDictionary alloc] initWithDictionary:    @{@"payHolderView":self.payHolderView}];
    NSMutableArray *constraints = [NSMutableArray array];

    int courtIndex = 0;
    UILabel *lastCourtLabel = nil;
    for (NSString *name in nameList) {
        UILabel *courtLabel = [[UILabel alloc]init];
        courtLabel.font = [UIFont systemFontOfSize:14];
        courtLabel.backgroundColor = [UIColor clearColor];
        courtLabel.textColor = [SportColor content1Color];
        courtLabel.text = [NSString stringWithFormat:@"%@：",name];
        courtLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.payHolderView addSubview:courtLabel];
        
        [viewsDictionary addEntriesFromDictionary:@{ @"currentCourtLabel":courtLabel}];
        
        if (courtIndex == 0) {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
        }else {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastValueLabel]-5-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[currentCourtLabel]" options:0 metrics:nil views:viewsDictionary]];
        
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
            [self.payHolderView addSubview:valueLabel];
            [viewsDictionary addEntriesFromDictionary:@{ @"valueLabel":valueLabel}];
            
            if(valueIndex == 0) {
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[currentCourtLabel]-0-[valueLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
            } else {
                
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastValueLabel]-5-[valueLabel]" options:NSLayoutFormatAlignAllLeading metrics:nil views:viewsDictionary]];
            }

            lastValueLabel = valueLabel;
            [viewsDictionary addEntriesFromDictionary:@{ @"lastValueLabel":lastValueLabel}];
            valueIndex ++;
        }
        
        courtIndex++;
    }
    
    if ([constraints count] > 0) {
        [viewsDictionary addEntriesFromDictionary:@{ @"bottomLineImageView":self.bottomLineImageView}];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastValueLabel]-15-[bottomLineImageView]" options:0 metrics:nil views:viewsDictionary]];
        
        [self.payHolderView addConstraints:constraints];
    }
//    self.courtDetailHoderHeight.constant = self.order.courtJoin.productList.count > 1 ? 45 * 0.7  * (self.order.courtJoin.productList.count):45;
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titleList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *value = self.titleList[indexPath.row];
    
    NSString *identifier = [CourtJoinInfoCell getCellIdentifier];
    CourtJoinInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.titleLabel setTextColor:[UIColor hexColor:@"666666"]];
    [cell.detailLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.detailLabel setTextColor:[UIColor hexColor:@"222222"]];
    
    NSString *subValue = @"";
    BOOL isShowArrow = NO;
    if([value isEqualToString:TITLE_ORDER_NUM]){
        subValue = self.order.orderNumber;
    }else if([value isEqualToString:TITLE_DATE]) {
        subValue = [DateUtil stringFromDate:self.order.createDate DateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }else if ([value isEqualToString:TITLE_PAY]){
        subValue = [self.order orderPayMethodString];
    }else if ([value isEqualToString:TITLE_STATUS]) {
        subValue =  [self.order orderStatusText];
    }
    
    cell.userInteractionEnabled = isShowArrow;
    
    [cell updateViewWithTitle:value detail:subValue isShowArrow:isShowArrow];
    
    return cell;
}
- (IBAction)clickCourtJoinDetailButton:(id)sender {
    
    CourtJoinDetailController *controller = [[CourtJoinDetailController alloc]initWithCourtJoinId:self.order.courtJoin.courtJoinId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickMapButton:(id)sender {

    BusinessMapController *controller = [[BusinessMapController alloc] initWithLatitude:self.order.courtJoin.latitude
                                                                              longitude:self.order.courtJoin.longtitude
                                                                           businessName:self.order.courtJoin.businessName
                                                                        businessAddress:self.order.courtJoin.address
                                                                         parkingLotList:nil
                                                                             businessId:self.order.courtJoin.businessId
                                                                             categoryId:self.order.courtJoin.categoryId
                                                                                   type:0];
    [self.navigationController pushViewController:controller animated:YES];
    
}
- (IBAction)clickPhoneCall:(id)sender {
    [MobClickUtils event:umeng_event_court_join_order_phone];
    BOOL result = [UIUtils makePromptCall:self.order.courtJoin.phoneNumber];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}
- (IBAction)clickIMButton:(id)sender {
    if ([self isLoginAndShowLoginIfNot]) {
        [MobClickUtils event:umeng_event_court_join_order_im];
        ConversationViewController *conversationVC = [[ConversationViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        conversationVC.targetId = self.order.courtJoin.courtUserId;
        conversationVC.title = self.order.courtJoin.nickName;
        
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
}
- (IBAction)clickContactCustomerService:(id)sender {
    NSString *phone = [ConfigData customerServicePhone];
    if ([phone length] > 0) {
        NSString *title = @"客服在线时间:周一至周六10:00-20:00，周日10:00-18:00";
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:phone otherButtonTitles:nil];
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        BOOL result = [UIUtils makePromptCall:title];
        
        if (result == NO) {
            [SportPopupView popupWithMessage:@"此设备不支持打电话"];
        }
    }
}

- (IBAction)clickPayButton:(id)sender {
    PayController *controller = [[PayController alloc]initWithOrder:self.order];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickAvatarButton:(id)sender {
    [self showUserDetailControllerWithUserId:self.order.courtJoin.courtUserId];
}
- (IBAction)clickOrderAmountView:(id)sender {
    OrderAmountView *view = [OrderAmountView createOrderAmountViewWithOrder:_order];
    [view show];
    
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
