//
//  CallBookController.m
//  Sport
//
//  Created by haodong  on 14-4-26.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "CallBookController.h"
#import "UIView+Utils.h"
#import "Business.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "PriceUtil.h"

@interface CallBookController ()
@property (strong, nonatomic) Business *business;
@property (copy, nonatomic) NSString *selectedCategoryId;
@property (strong, nonatomic) NSDate *startTime;
@property (assign, nonatomic) int duration; //持续时间（小时）
@property (copy, nonatomic) NSString *gender;
@end

@implementation CallBookController

- (void)viewDidUnload {
    [self setBusinessNameLabel:nil];
    [self setTimeLabel:nil];
    [self setSummitButton:nil];
    [self setOrderTopBackgroundImageView:nil];
    [self setPriceLabel:nil];
    [self setNameTextField:nil];
    [self setPhoneTextField:nil];
    [self setNameBackgroundImageView:nil];
    [self setPhoneImageView:nil];
    [self setBusinessAddressTextView:nil];
    [self setTimeHolderView:nil];
    [self setNameHolderView:nil];
    [super viewDidUnload];
}

- (instancetype)initWithBusiness:(Business *)business
              selectedCategoryId:(NSString *)selectedCategoryId
                       startTime:(NSDate *)startTime
                        duration:(int)duration
{
    self = [super init];
    if (self) {
        self.business = business;
        self.selectedCategoryId = selectedCategoryId;
        self.startTime = startTime;
        self.duration = duration;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"订单确认";
    
    self.nameTextField.text = @"";
    self.phoneTextField.text = @"";
    
    CGSize  screenSize = [UIScreen mainScreen].bounds.size;
    
    [self.mainScrollView updateHeight:screenSize.height - 20 - 44];
    [self.mainScrollView setContentSize:CGSizeMake(screenSize.width, _mainScrollView.frame.size.height + 1)];
    
    self.orderTopBackgroundImageView.image = [SportImage whiteBackgroundRoundImage];
    [self.lineImageView setImage:[SportImage lineImage]];
    //[self.summitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    self.nameBackgroundImageView.image = [SportImage inputBackgroundImage];
    self.phoneImageView.image = [SportImage inputBackgroundImage];
    
    self.businessNameLabel.text = _business.name;
    
    [self updateAddress];
    
    NSString *priceStr = nil;
    if (_business.price == 0) {
        priceStr = @"暂未确定";
    } else {
        priceStr = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_business.price * _duration]];
    }
    self.priceLabel.text = priceStr;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *startTimeStr = [dateFormatter stringFromDate:_startTime];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *endTimeStr = [dateFormatter stringFromDate:[_startTime dateByAddingTimeInterval:_duration *  60 * 60]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@-%@", startTimeStr, endTimeStr];
    
    [self.nameTextField becomeFirstResponder];
    
    [self clickGenderButton:_mrButton];
    
    [MobClickUtils event:umeng_event_enter_call_book];
}

- (IBAction)clickGenderButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    [UIView animateWithDuration:0.2 animations:^{
        [self.moveLineView updateCenterX:button.center.x];
    }];
    
    if (_mrButton == button) {
        self.gender = @"先生";
        [self.mrButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
        [self.msButton setTitleColor:[UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        self.gender = @"女士";
        [self.mrButton setTitleColor:[UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1] forState:UIControlStateNormal];
        [self.msButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
    }
}

- (void)updateAddress
{
    self.businessAddressTextView.text = _business.address;
    
    CGSize size = [_businessAddressTextView sizeThatFits:CGSizeMake(242, 56)];
    [self.businessAddressTextView updateHeight: MAX(size.height, 28)];
    
    if (_businessAddressTextView.frame.size.height > 28) {
        
        [self.timeHolderView updateOriginY:_businessAddressTextView.frame.origin.y + _businessAddressTextView.frame.size.height - 6];
        [self.nameHolderView updateOriginY:_timeHolderView.frame.origin.y + _timeHolderView.frame.size.height];
        
        [self.orderTopBackgroundImageView updateHeight:_nameHolderView.frame.origin.y + _nameHolderView.frame.size.height - _orderTopBackgroundImageView.frame.origin.y];
        
        [self.summitButton updateOriginY:_nameHolderView.frame.origin.y + _nameHolderView.frame.size.height + 10];
    }
    
    //for test
//    self.businessAddressTextView.backgroundColor = [UIColor blueColor];
//    self.timeHolderView.backgroundColor = [UIColor orangeColor];
//    self.nameHolderView.backgroundColor = [UIColor redColor];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //HDLog(@"scrollViewWillBeginDragging:");
    [self.nameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        [self.mainScrollView setContentOffset:CGPointMake(0, 22) animated:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    return YES;
}

- (IBAction)touchDownBackground:(id)sender {
    [self.nameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}

- (IBAction)clickSummitButton:(id)sender {
    if ([_nameTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请填写姓"];
        return;
    }
    
    if ([_phoneTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请填写电话"];
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *startTimeStr = [dateFormatter stringFromDate:_startTime];
    NSString *endTimeStr = [dateFormatter stringFromDate:[_startTime dateByAddingTimeInterval:_duration *  60 * 60]];
    
    NSString *name = [NSString stringWithFormat:@"%@%@", _nameTextField.text, _gender];
    
    [SportProgressView showWithStatus:@"正在提交..."];
    [BusinessService callBook:self phone:_phoneTextField.text
                     userName:name
                    startTime:startTimeStr
                      endTime:endTimeStr
                   businessId:_business.businessId
                   categoryId:_selectedCategoryId];
}

- (void)didCallBook:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self performSelector:@selector(backAfterSummit) withObject:nil afterDelay:1.5];
        
        [SportProgressView dismissWithSuccess:@"订单提交成功，稍后会有客服联系您"];
        
        [MobClickUtils event:umeng_event_summit_call_book label:@"提交成功"];
    } else {
        [SportProgressView dismissWithSuccess:[NSString stringWithFormat:@"提交失败,%@", msg]];
        
        [MobClickUtils event:umeng_event_summit_call_book label:@"提交失败"];
    }
}

- (void)backAfterSummit
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
