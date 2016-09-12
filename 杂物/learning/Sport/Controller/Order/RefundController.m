//
//  RefundController.m
//  Sport
//
//  Created by haodong  on 15/3/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "RefundController.h"
#import "RefundWay.h"
#import "UIView+Utils.h"
#import "RefundCauseCell.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "UIUtils.h"
#import "SportPopupView.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"
#import "RefundCause.h"
#import "PriceUtil.h"
#import "MyVouchersController.h"
#import "MyMoneyController.h"
#import "SportPlusMinusView.h"

typedef enum
{
    RefundStatusDefault = 0,
    RefundStatusProcessing = 1,
    RefundStatusFinish = 2,
} RefundStatus;

@interface RefundController ()<SportPlusMinusViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *refundAmountSubmitLabel;
@property (weak, nonatomic) IBOutlet UILabel *refundWayLabel;
@property (assign, nonatomic) float refundAmount;
@property (strong, nonatomic) NSArray *refundWayList;
@property (strong, nonatomic) NSArray *refundCauseList;
@property (copy, nonatomic) NSString *orderId;

@property (strong, nonatomic) RefundWay *selectedRefundWay;
@property (strong, nonatomic) NSMutableArray *selectedCauseIdList;

@property (assign, nonatomic) RefundStatus status;
@property (copy, nonatomic) NSString *refundWay;

@property (assign, nonatomic) BOOL onlyShowStatus;
@property (weak, nonatomic) IBOutlet UILabel *refundProcessingLabel;

@property (weak, nonatomic) IBOutlet UIButton *myVoucherButton;
@property (assign, nonatomic) CGFloat offset;
@property (assign, nonatomic) int canRefundNum;
@property (strong, nonatomic) NSArray *priceList;
@property (weak, nonatomic) IBOutlet UIView *plusMinusHolderView;
@property (strong, nonatomic) SportPlusMinusView *plusMinusView;
@property (weak, nonatomic) IBOutlet UIView *refundNumberHolderView;
@property (assign, nonatomic) int refundNum;
@property (weak, nonatomic) IBOutlet UILabel *refundWayTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notUsedNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *refundPriceHolderView;
@end

@implementation RefundController

- (void)dealloc
{
    [self deregsiterKeyboardNotification];
}

- (instancetype)initWithAmount:(float)amount
                 refundWayList:(NSArray *)refundWayList
               refundCauseList:(NSArray *)refundCauseList
                       orderId:(NSString *)orderId
                     priceList:(NSArray *)priceList
{
    self = [super init];
    if (self) {
        // test data
//        RefundWay *tmp = [[RefundWay alloc]init];
//        tmp.subTitle = @"subtitle";
//        tmp.title = @"title";
//        tmp.refundWayId = @"refundWayId";
//        NSMutableArray *refundWayTmp = [[NSMutableArray alloc]initWithArray:refundWayList];
//        [refundWayTmp addObject:tmp];
        
        self.refundAmount = amount;
        self.refundWayList = refundWayList;
        self.refundCauseList = refundCauseList;
        self.orderId = orderId;
        self.onlyShowStatus = NO;
        self.canRefundNum = [priceList count];
        if (self.canRefundNum > 0) {
            self.refundNum = 1;
        }
        
        self.priceList = priceList;
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (instancetype)initWithStatus:(int)status
                     refundWay:(NSString *)refundWay
                        amount:(float)amount
{
    self = [super init];
    if (self) {
        self.status = status;
        self.refundAmount = amount;
        self.refundWay = refundWay;
        self.onlyShowStatus = YES;
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"申请退款";
    [self createRightTopButton:@"退款规则"];
    
    self.mainScrollView.backgroundColor = self.view.backgroundColor;
    [self initBaseViews];
    self.suggestionTextField.delegate = self;
    
    if (_onlyShowStatus) {
        self.mainScrollView.hidden = YES;
        self.statusView.hidden = NO;
        
        [self updateStatusView];
    } else {
        self.mainScrollView.hidden = NO;
        self.statusView.hidden = YES;
        
        [self initWayViews];
        [self updateViewsFrame];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


- (void)clickRightTopButton:(id)sender
{
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] refundRuleUrl] title:@"退款规则"] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)initBaseViews
{
    for (UIView *first in self.mainScrollView.subviews) {
        if (first.tag == 200 && [first isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)first setImage:[SportImage whiteBackgroundImage]];
        }
        for (UIView *second in first.subviews) {
            if (second.tag == 200 && [second isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)second setImage:[SportImage whiteBackgroundImage]];
            }
        }
    }
    
    for (UIView *first in self.statusView.subviews) {
        if (first.tag == 200 && [first isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)first setImage:[SportImage whiteBackgroundImage]];
        }
        if (first.tag == 100 && [first isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)first setImage:[SportImage lineImage]];
        }
    }
    
    [self.suggestionBackgroundImageView setImage:[SportImage grayBackgroundRoundImage]];
//    [self.submitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
}

#define BASE_TAG_WAY 100
- (void)initWayViews
{
    if ([self.priceList count] > 0) {
        self.notUsedNumberLabel.text = [NSString stringWithFormat:@"共有%d张人次票未使用",self.canRefundNum];
        
        if (self.plusMinusView == nil) {
            self.plusMinusView = [SportPlusMinusView createSportPlusMinusViewWithMaxNumber:self.canRefundNum minNumber:1];
            self.plusMinusView.delegate = self;
            self.plusMinusView.countNumber = self.canRefundNum;
            [self.plusMinusView updateMinusButtonAndPlusButton];
            [self.plusMinusHolderView addSubview:self.plusMinusView];
        }
        
        self.refundNumberHolderView.hidden = NO;
        
    } else {
        self.refundNumberHolderView.hidden = YES;
        [self.refundNumberHolderView updateHeight:0];
    }
    
    [self.refundPriceHolderView updateOriginY:self.refundNumberHolderView.frame.origin.y + self.refundNumberHolderView.frame.size.height];
    
    [self.refundWayTitleLabel updateOriginY:self.refundPriceHolderView.frame.origin.y + self.refundPriceHolderView.frame.size.height +15];
    [self.wayHolderView updateOriginY:self.refundWayTitleLabel.frame.origin.y + self.refundWayTitleLabel.frame.size.height + 10];
    
    CGFloat y = 0;
    NSUInteger index = 0;
    
    for (RefundWay *way in _refundWayList) {
        RefundTypeView *view = [RefundTypeView createWithRefundWay:way index:index];
        view.delegate = self;
        view.tag = BASE_TAG_WAY + index;
        [view updateOriginY:y];
        y += view.frame.size.height;
        [self.wayHolderView addSubview:view];
        
        if (index == 0) {
            [view updateSelectStatus:YES];
            self.selectedRefundWay = way;
        }
        
        index ++;
    }
    [self.wayHolderView updateHeight:y];
    
}

- (void)didSelectRefundTypeView:(RefundWay *)refundWay
{
     [self.suggestionTextField resignFirstResponder];
    
    if ([_selectedRefundWay.refundWayId isEqualToString:refundWay.refundWayId] == NO) {
        int index = 0;
        for (RefundWay *way in _refundWayList) {
            
            //把之前的状态改为不选择
            if (_selectedRefundWay && [_selectedRefundWay.refundWayId isEqualToString:way.refundWayId]) {
                RefundTypeView *view = (RefundTypeView *)[self.wayHolderView viewWithTag:BASE_TAG_WAY + index];
                [view updateSelectStatus:NO];
            }
            
            //把当前的改为选中
            if ([refundWay.refundWayId isEqualToString:way.refundWayId]) {
                RefundTypeView *view = (RefundTypeView *)[self.wayHolderView viewWithTag:BASE_TAG_WAY + index];
                [view updateSelectStatus:YES];
            }
            
            index ++;
        }
        self.selectedRefundWay = refundWay;
    }
}

#define SPACE 15
- (void)updateViewsFrame
{
    [self.causeTitleLabel updateOriginY:_wayHolderView.frame.origin.y + _wayHolderView.frame.size.height + SPACE];
    
    [self.causeTableView updateOriginY:_causeTitleLabel.frame.origin.y + _causeTitleLabel.frame.size.height + 10];
    [self.causeTableView updateHeight:[_refundCauseList count] * [RefundCauseCell getCellHeight]];
    
    [self.bottomHolderView updateOriginY:_causeTableView.frame.origin.y + _causeTableView.frame.size.height];
    
    [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    [(UIScrollView *)self.mainScrollView setContentSize:CGSizeMake(self.view.frame.size.width, _bottomHolderView.frame.origin.y + _bottomHolderView.frame.size.height)];
    
    [self updateRefundPrice];
}

-(void) updateRefundPrice {
    float amount = 0;
    if ([self.priceList count] > 0) {
        
        for (int i = 0;i < self.refundNum;i++){
            if (i > [self.priceList count] - 1) {
                break;
            }
            
            amount += [self.priceList[i] floatValue];
        }
        
        _refundAmount = amount;
        
    }
    
    self.refundAmountSubmitLabel.text = [NSString stringWithFormat:@"%@元",[PriceUtil toValidPriceString:_refundAmount]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_refundCauseList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [RefundCauseCell getCellIdentifier];
    RefundCauseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [RefundCauseCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    RefundCause *cause = [_refundCauseList objectAtIndex:indexPath.row];
    
    BOOL isSelected = [self.selectedCauseIdList containsObject:cause.refundCauseId];
    
    BOOL isLast = indexPath.row == [_refundCauseList count] - 1;
    
    [cell updateCellWithCause:cause.title isSelected:isSelected indexPath:indexPath isLast:isLast];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RefundCauseCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.suggestionTextField resignFirstResponder];
    
    if (_selectedCauseIdList == nil) {
        self.selectedCauseIdList = [NSMutableArray array];
    }
    
    RefundCause *cause = [_refundCauseList objectAtIndex:indexPath.row];
    
    if ([self.selectedCauseIdList containsObject:cause.refundCauseId]) {
        [self.selectedCauseIdList removeObject:cause.refundCauseId];
    }
    else
    {
        [self.selectedCauseIdList addObject:cause.refundCauseId];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [tableView reloadData];
}

-(void)doRefundSubmit{
    NSString *idList = [_selectedCauseIdList componentsJoinedByString:@","];
    
    [SportProgressView showWithStatus:@"提交中"];
    [OrderService applyRefund:self
                       userId:[[UserManager defaultManager] readCurrentUser].userId
                      orderId:_orderId
                  refundWayId:_selectedRefundWay.refundWayId
                  refundCause:idList
                  description:_suggestionTextField.text
                refundNumer:self.refundNum];
}

- (IBAction)clickSubmitButton:(id)sender {
    
    if ([self.selectedCauseIdList count] == 0) {
        [SportPopupView popupWithMessage:@"请指定至少一个退款原因"];
        return;
    }
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    if (_selectedRefundWay.isPayPassword == YES && user.hasPayPassWord == NO){
        
        [InputPasswordView popUpViewWithType:InputPasswordTypeSet delegate:self smsCode:nil];
        return;
    }
    
    [self doRefundSubmit];
    
}

- (void)didFinishSetPayPassword:(NSString *)payPassword status:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self doRefundSubmit];
    }

}

- (void)didApplyRefund:(NSString *)status
                   msg:(NSString *)msg
          refundStatus:(int)refundStatus
          refundAmount:(float)refundAmount
             refundWay:(NSString *)refundWay
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        self.mainScrollView.hidden = YES;
        self.statusView.hidden = NO;
        self.status = refundStatus;
        self.refundWay = refundWay;

        [self updateStatusView];

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_APPLY_REFUND object:nil userInfo:@{@"order_id":_orderId, @"refund_status":[NSNumber numberWithInt:refundStatus]}];
        
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)updateStatusView
{
    self.refundProcessingLabel.hidden = YES;
    if (_status == RefundStatusProcessing) {
        [self.statusImageView setImage:[SportImage refundProcessingImage]];
        self.statusLabel.text = @"退款处理中";
        self.refundProcessingLabel.hidden = NO;
    } else if (_status == RefundStatusFinish) {
        [self.statusImageView setImage:[SportImage refundFinishImage]];
        self.statusLabel.text = @"已成功退款";
    } else {
        self.statusLabel.text = @"未知状态";
    }
    
    [self.statusView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    
    self.refundAmountLabel.text = [NSString stringWithFormat:@"%@元",[PriceUtil toValidPriceString:_refundAmount]];
    
    // containsString只适用于IOS8.0以上
    if ([self.refundWay rangeOfString:@"趣运动余额"].length) {
        self.myVoucherButton.hidden = NO;
         NSMutableAttributedString *mutaString = [[NSMutableAttributedString alloc] initWithString:_refundWay] ;
        
        [mutaString addAttribute:NSForegroundColorAttributeName
                           value:[SportColor defaultColor]
                           range:[_refundWay rangeOfString:@"趣运动余额"]];
        self.refundWayLabel.attributedText = mutaString;
    }
    else {
        self.myVoucherButton.hidden = YES;
        self.refundWayLabel.text = [NSString stringWithFormat:@"%@",_refundWay];
    }
}

- (void) keyboardWasShown:(NSNotification *) notif
{
    if (![self.suggestionTextField isFirstResponder]) {
        return;
    }
    
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    
    if (self.offset == 0) {
        self.offset = keyboardSize.height - ([UIScreen mainScreen].bounds.size.height - self.submitButton.frame.origin.y - self.bottomHolderView.frame.origin.y - self.submitButton.frame.size.height - 20);

        if (self.offset > 0) {
            [UIView animateWithDuration:0.2 animations:^{
                CGPoint center = self.mainScrollView.center;
                center.y -= _offset;
                self.mainScrollView.center = center;
            }];
        }
        else
        {
            self.offset = 0;
        }
        
    }
    _mainScrollView.scrollEnabled = NO;
    
    ///keyboardWasShown = YES;
}

- (void) keyboardWasHidden:(NSNotification *) notif
{
    if (![self.suggestionTextField isFirstResponder]) {
        return;
    }
    
    // keyboardWasShown = NO;
    _mainScrollView.scrollEnabled = YES;
    //NSDictionary *info = [notif userInfo];
   
    [UIView animateWithDuration:0.2 animations:^{
    CGPoint center = self.mainScrollView.center;
    center.y += _offset;
    self.mainScrollView.center = center;
    self.offset = 0;

    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.suggestionTextField resignFirstResponder];
    return YES;
}
- (IBAction)touchDownBackground:(id)sender {
    [self.suggestionTextField resignFirstResponder];
}


- (IBAction)clickMyVoucher:(id)sender {
    MyMoneyController *controller = [[MyMoneyController alloc] initWithType:TypeMoney];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickPhoneButton:(id)sender {
    BOOL result = [UIUtils makePromptCall:@"4000410480"];
    
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

#pragma mark SportPlusMinusViewDelegate
-(void) updateSelectNumber:(int) number {
    self.refundNum = number;
    [self updateRefundPrice];
}

@end
