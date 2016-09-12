//
//  BookWithPhoneController.m
//  Sport
//
//  Created by liuzhiyi on 15/11/2.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "BookWithPhoneController.h"
#import "SportImage.h"
#import "UIView+Utils.h"
#import "Business.h"
#import "UserManager.h"
#import "CLLocation+Util.h"
#import "UIImageView+WebCache.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "BusinessDetailController.h"
#import "SportProgressView.h"
#import "ZYKeyboardUtil.h"

#define TAG_BUTTON_MALE     10
#define TAG_BUTTON_FEMALE   20

#define VIEW_OFFSET_MARGIN  15

#define STRING_MALE         @"先生"
#define STRING_FEMALE       @"小姐"

@interface BookWithPhoneController ()

@property (copy, nonatomic) NSString *gender;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UIView *headHolderView;
@property (copy, nonatomic) NSString *nearbyBusinessId;
@property (weak, nonatomic) IBOutlet UIImageView *promotePriceImageView;


@property (weak, nonatomic) IBOutlet UIView *nearbyVenuesHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *venuesImageView;
@property (weak, nonatomic) IBOutlet UILabel *venuesNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesPromotePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesSubTitleLabel;

@property (strong, nonatomic) Business *business;
@property (copy ,nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSDate *startTime;
@property (assign, nonatomic) int duration;
@property (assign, nonatomic) CGFloat viewOffset;

@property (strong, nonatomic) ZYKeyboardUtil *keyboardUtil;
@end

@implementation BookWithPhoneController

- (instancetype)initWithBusiness:(Business *)business
                      categoryId:(NSString *)categoryId
                       startTime:(NSDate *)startTime
                        duration:(int)duration {
    
    self = [super init];
    if(self) {
        self.business = business;
        self.categoryId = categoryId;
        self.startTime = startTime;
        self.duration = duration;
//        [self registerForKeyboardNotifications];
        self.keyboardUtil = [[ZYKeyboardUtil alloc] init];
    }
    return self;
}

- (void)dealloc {
//    [self deregsiterKeyboardNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"电话预约";
    
    [self initLayout];
    
    [self initData];
    
    [MobClickUtils event:umeng_event_enter_call_book];
    
    __unsafe_unretained BookWithPhoneController *weakSelf = self;
    [self.keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.phoneTextField.superview, nil];
    }];
}

- (void)initLayout {
    self.nearbyVenuesHolderView.alpha = 0.0;
    
    self.nameTextField.delegate = self;
    self.phoneTextField.delegate = self;
    
//    [self.commitButton setBackgroundImage:[SportImage blueRoundButtonImage] forState:UIControlStateNormal];
//    [self.commitButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
//    [self.commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    self.viewOffset = VIEW_OFFSET_MARGIN;
}

- (void)initData {

    //时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日 HH:mm"];
    NSString *front = [formatter stringFromDate:_startTime];
    [formatter setDateFormat:@"HH:mm"];
    NSString *rear = [formatter stringFromDate:[_startTime dateByAddingTimeInterval:_duration * 3600]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@-%@", front, rear];
    
    //地址
    self.addressLabel.text = self.business.address;
    
    //名称
    self.businessNameLabel.text = self.business.name;
    
    //价钱
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f元", self.business.price * _duration];
    
    //性别
    self.gender = STRING_MALE;
}

- (IBAction)clickGenderButton:(UIButton *)sender {
    if(!sender.selected) {
        switch (sender.tag) {
            case TAG_BUTTON_MALE:
                
                sender.selected = !sender.selected;
                ((UIButton *)[sender.superview viewWithTag:TAG_BUTTON_FEMALE]).selected = !sender.selected;
                self.gender = STRING_MALE;
                break;
            case TAG_BUTTON_FEMALE:
                sender.selected = !sender.selected;
                ((UIButton *)[sender.superview viewWithTag:TAG_BUTTON_MALE]).selected = !sender.selected;
                self.gender = STRING_FEMALE;
                break;
            default:
                break;
        }
    }
}

- (IBAction)clickVenuesInfoButton:(id)sender {
    [self clickLookupButton:nil];
}

- (IBAction)clickCommitButton:(id)sender {
    if(_nameTextField.text.length <= 0) {
        [SportPopupView popupWithMessage:@"请填写称呼"];
        return;
    }
    if(_phoneTextField.text.length <= 0) {
        [SportPopupView popupWithMessage:@"请填写联系电话"];
        return;
    }
    
    
    [SportProgressView showWithStatus:@"正在提交..."];
    
    NSString *name = [NSString stringWithFormat:@"%@%@", _nameTextField.text, _gender];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *startTimeStr = [formatter stringFromDate:_startTime];
    NSString *endTimeStr = [formatter stringFromDate:[_startTime dateByAddingTimeInterval:_duration * 3600]];
    
    [BusinessService callBook:self phone:_phoneTextField.text userName:name startTime:startTimeStr endTime:endTimeStr businessId:_business.businessId categoryId:_categoryId];
}


- (IBAction)clickLookupButton:(id)sender {
    [MobClickUtils event:umeng_event_click_nearby_bussiness];
    BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:_nearbyBusinessId categoryId:_categoryId];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark delegate

- (void)didCallBook:(NSString *)status msg:(NSString *)msg {
    if([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"订单提交成功，稍后会有客服联系您"];
        [MobClickUtils event:umeng_event_summit_call_book label:@"提交成功"];
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(1) afterDelay:1.5];
    }else {
        [SportProgressView dismissWithSuccess:[NSString stringWithFormat:@"提交失败,%@", msg]];
        [MobClickUtils event:umeng_event_summit_call_book label:@"提交失败"];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_nameTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_nameTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark 键盘展示收起
- (void)keyboardWasShown:(NSNotification *)notification {
    //解析通知
    NSDictionary* info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [value getValue:&keyboardRect];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect convertRect = [self.phoneTextField.superview convertRect:self.phoneTextField.frame toView:window];

    if((keyboardRect.origin.y) < CGRectGetMaxY(convertRect)) {
        CGFloat diff = CGRectGetMaxY(convertRect) - (keyboardRect.origin.y);
        self.viewOffset -= diff;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view updateOriginY:(self.viewOffset)];
        }];
    }
}

- (void)keyboardWasHidden:(NSNotification *)notification {
    self.viewOffset = VIEW_OFFSET_MARGIN;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view updateOriginY:64];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
