//
//  PointGoodsDetailController.m
//  Sport
//
//  Created by haodong  on 14/11/13.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PointGoodsDetailController.h"
#import "PointGoods.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import "User.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "PointRecordController.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"
#import "SportProgressView.h"
#import "NSString+Utils.h"

@interface PointGoodsDetailController ()
@property (strong, nonatomic) PointGoods *pointGoods;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointVisulGoodConstraint;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberHolderView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlHeightConstraint;

@end

@implementation PointGoodsDetailController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self deregsiterKeyboardNotification];
}

- (instancetype)initWithPointGoods:(PointGoods *)pointGoods
{
    self = [super init];
    if (self) {
        self.pointGoods = pointGoods;
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商品详情";
    
    [self.lineImageView setImage:[SportImage lineImage]];
//    [self.submitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    [self.goodsImageView sd_setImageWithURL:[NSURL URLWithString:_pointGoods.imageUrl] placeholderImage:[SportImage defaultImage_92x65]];
    [self.goodsImageView setContentMode:UIViewContentModeScaleAspectFit];
    self.goodsTitleLabel.text = _pointGoods.title;
    self.goodsSubTitleLabel.text = _pointGoods.subTitle;
    
    self.pointLabel.text = [NSString stringWithFormat:@"%d积分", _pointGoods.point];
    
    if (_pointGoods.originalPoint > 0) {
        self.originalPointLabel.hidden = NO;
        self.originalPointLineView.hidden = NO;
        self.originalPointLabel.text = [NSString stringWithFormat:@"%d积分", _pointGoods.originalPoint];
        
        CGSize size = [self.pointLabel.text sizeWithMyFont:self.pointLabel.font];
        CGFloat originalX = _pointLabel.frame.origin.x + _pointLabel.frame.size.width - size.width - 8 - _originalPointHolderView.frame.size.width;
        [self.originalPointHolderView updateOriginX:originalX];
        
        CGSize originalSize = [self.originalPointLabel.text sizeWithMyFont:self.originalPointLabel.font];
        [self.originalPointLineView updateWidth:originalSize.width + 4];
        
        [self.originalPointLineView updateOriginX:_originalPointHolderView.frame.size.width - _originalPointLineView.frame.size.width];
    } else {
        self.originalPointLabel.hidden = YES;
        self.originalPointLineView.hidden = YES;
    }
    
    [self updateDesc];
    [self updateSubmitButton];
    [MobClickUtils event:umeng_event_enter_point_goods_detail];

    self.phoneTextField.delegate = self;
    User *user = [[UserManager defaultManager] readCurrentUser];
    _phoneTextField.text = user.phoneNumber;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) updateSubmitButton
{
    if (_pointGoods.type == PointGoodsTypePhysical) {
        _pointVisulGoodConstraint.constant += _phoneNumberHolderView.frame.size.height;
        _phoneNumberHolderView.hidden = NO;
        
        //Scrollable area, iphone 4s and iphone 6
        self.controlHeightConstraint.constant = MAX(50 + _submitButton.frame.origin.y+_submitButton.frame.size.height,[UIScreen mainScreen].bounds.size.height+30);
    }
    else
    {
        _pointVisulGoodConstraint.constant = 20;
        _phoneNumberHolderView.hidden = YES;
        
        self.controlHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height;
    }

}


#define WIDTH_DESC_TEXT_VIEW 284
- (void)updateDesc
{
    UITextView *view = [self createDescTextView];
    view.text = _pointGoods.desc;
    
    [self.contentHolderView updateHeight:_submitButton.frame.origin.y + _submitButton.frame.size.height + 13];
    
    UIImageView *backgroundImageView = (UIImageView *)[_contentHolderView viewWithTag:102];
    [backgroundImageView updateHeight:_contentHolderView.frame.size.height];
    [backgroundImageView setImage:[SportImage whiteBackgroundRoundImage]];
}

- (UITextView *)createDescTextView
{
    _descTextView.backgroundColor = [UIColor clearColor];
    [_descTextView setTextColor:[SportColor content2Color]];
    _descTextView.scrollEnabled = NO;
    _descTextView.editable = NO;
    
    if ([_descTextView respondsToSelector:@selector(setSelectable:)]) {
        _descTextView.selectable = NO;
    }
    
    return _descTextView;
}

#define TAG_ALERT_VIEW_POINT_NOT_ENOUGH     2014141501
#define TAG_CONVERT_GOODS_ALERTVIEW         2014111701
#define TAG_CONVERT_GOODS_SUCCESS_ALERTVIEW 2014111702
- (IBAction)clickSubmitButton:(id)sender {
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    if (user.point < _pointGoods.point) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的积分不足" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"如何获取积分",nil];
        alertView.tag = TAG_ALERT_VIEW_POINT_NOT_ENOUGH;
        [alertView show];
        return;
    }
    
    if (_pointGoods.type == PointGoodsTypePhysical ) {
        if ([_phoneTextField.text length] == 0) {
            [SportPopupView popupWithMessage:@"请填写手机号码"];
            return;
        }
        
        if ([_phoneTextField.text length] != 11) {
            [SportPopupView popupWithMessage:@"请填写11位手机号码"];
            return;
        }
    }
    
    NSString *message = [NSString stringWithFormat:@"兑换需要花费%d个积分", _pointGoods.point];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = TAG_CONVERT_GOODS_ALERTVIEW;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_CONVERT_GOODS_ALERTVIEW) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            [SportProgressView showWithStatus:@"兑换中"];
            User *user = [[UserManager defaultManager] readCurrentUser];
            [PointService convertGoods:self
                                userId:user.userId
                               goodsId:_pointGoods.goodsId
                                drawId:nil
                                  type:@"0"
                                 phone:_phoneTextField.text];
            
        }
    } else if (alertView.tag == TAG_CONVERT_GOODS_SUCCESS_ALERTVIEW) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            PointRecordController *controller = [[PointRecordController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (alertView.tag == TAG_ALERT_VIEW_POINT_NOT_ENOUGH) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            NSString *opintRuleUrl = [[BaseConfigManager defaultManager] creditRuleUrl];
            
            SportWebController *controller = [[SportWebController alloc] initWithUrlString:opintRuleUrl title:@"积分规则"];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#define TAG_ALERT_VIEW_CONVERT  2014121001
- (void)didConvertGoods:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
       [self.phoneTextField resignFirstResponder];
        
        NSString *message = nil;
        if (_pointGoods.type == PointGoodsTypeVoucher) {
            message = @"可在我的代金券页面查看您的代金券";
        } else {
            message = @"请耐心等候工作人员的来电";
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"兑换成功" message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"查看兑换记录", nil];
        alertView.tag = TAG_CONVERT_GOODS_SUCCESS_ALERTVIEW;
        [alertView show];
        
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"网络不给力，请稍后重试"];
        }
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (self.phoneTextField == textField) {
        if ([aString length] > 11) {
            textField.text = [aString substringToIndex:11];
            return NO;
        }
    }
    return YES;
}

- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    CGFloat offset = 70 +keyboardSize.height- ([UIScreen mainScreen].bounds.size.height - (_submitButton.frame.origin.y+_submitButton.frame.size.height));
  
    if (self.scrollView.contentOffset.y < offset) {
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.contentOffset = CGPointMake(0, offset);
        }];
    }
   
    _scrollView.scrollEnabled = NO;
    
    ///keyboardWasShown = YES;
}

- (void) keyboardWasHidden:(NSNotification *) notif
{
    // keyboardWasShown = NO;
    _scrollView.scrollEnabled = YES;

    [UIView animateWithDuration:0.3 animations:^{
        //self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y - _controlHeightConstraint.constant + [UIScreen mainScreen].bounds.size.height);
        self.scrollView.contentOffset = CGPointMake(0, [UIScreen mainScreen].bounds.size.height - _controlHeightConstraint.constant);
    }];
}


- (IBAction)touchDownBackground:(id)sender {
    [self.phoneTextField resignFirstResponder];
}

@end
