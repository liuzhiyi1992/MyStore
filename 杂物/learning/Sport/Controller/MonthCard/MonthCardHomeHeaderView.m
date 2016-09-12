//
//  MonthCardHomeHeaderView.m
//  Sport
//
//  Created by 江彦聪 on 15/6/5.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardHomeHeaderView.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
#import "UserManager.h"
#import "QrCodeView.h"
#import "SportProgressView.h"
#import "SportPopupView.h"

@interface MonthCardHomeHeaderView()
@property (strong, nonatomic) IBOutlet UIView *cardView;

@property (weak, nonatomic) IBOutlet UIView *validTimeView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimelabel;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *assistentView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *qrButton;
@property (weak, nonatomic) IBOutlet UIButton *assistentButton;
@property (weak, nonatomic) IBOutlet UITextView *fronzenTextView;
@property (weak, nonatomic) IBOutlet UILabel *expireLabel;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (strong, nonatomic) MonthCard *card;

@end
@implementation MonthCardHomeHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (MonthCardHomeHeaderView *)createView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MonthCardHomeHeaderView" owner:self options:nil];
    
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    
    MonthCardHomeHeaderView *view = (MonthCardHomeHeaderView *)[topLevelObjects objectAtIndex:0];
    view.cardView.layer.cornerRadius = 5.0f;
    view.cardView.layer.masksToBounds = YES;
    view.maskView.layer.cornerRadius = 5.0f;
    view.maskView.layer.masksToBounds = YES;
    
    view.validTimeView.hidden = YES;
    view.maskView.hidden = YES;
    [view.buyButton setBackgroundImage:[SportImage monthCardButtonBackground] forState:UIControlStateNormal];

    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user.userId == nil) {
        view.nameLabel.text = @"未登录";
    } else {
        view.nameLabel.text = user.nickname;
    }
    
    view.avatarButton.enabled = NO;
    view.avatarButton.layer.cornerRadius = view.avatarImage.frame.size.width/2;
    view.avatarButton.layer.masksToBounds = YES;
    view.avatarImage.layer.cornerRadius = view.avatarImage.frame.size.width/2;
    view.avatarImage.layer.masksToBounds = YES;
    
    return view;
}

+ (MonthCardHomeHeaderView *)createViewWithFrame:(CGRect)frame
{
    MonthCardHomeHeaderView *view = [self createView];
    view.frame = frame;
    
    return view;
}

-(void)showRefreshButton
{
    self.maskView.hidden = NO;
    for (UIView *view in self.maskView.subviews) {
        view.hidden = YES;
    }
    
    self.maskView.hidden = NO;
    self.refreshButton.hidden = NO;
}

-(void)showErrorNoticeMaskView:(CARD_STATUS) cardStatus
{
    self.maskView.hidden = NO;
    for (UIView *view in self.maskView.subviews) {
        view.hidden = YES;
    }
    
    switch (cardStatus) {
        case CARD_STATUS_INVALID:
            self.buyButton.hidden = NO;
            [self.buyButton setTitle:@"加入动Club" forState:UIControlStateNormal];
            break;
        case CARD_STATUS_FROZEN:
            self.fronzenTextView.hidden = NO;
            break;
        case CARD_STATUS_EXPIRED:
            self.expireLabel.hidden = NO;
            self.buyButton.hidden =NO;
            [self.buyButton setTitle:@"点击续费" forState:UIControlStateNormal];
            break;
        default:
            self.maskView.hidden = NO;
            break;
    }
}

-(void)updateAvatarImage:(NSString *)url
{
    if (url == nil) {
        [self.avatarImage setImage:[SportImage monthCardDefaultAvatar]];
        self.avatarImage.layer.borderColor = [[UIColor clearColor] CGColor];
        self.avatarButton.enabled = NO;
        [self.avatarButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.avatarButton setTitle:nil forState:UIControlStateNormal];
        return;
    }

    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[SportImage monthCardDefaultAvatar]];
    self.avatarButton.layer.cornerRadius = self.avatarImage.frame.size.width/2;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;
    self.avatarImage.layer.masksToBounds = YES;
    self.avatarImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.avatarImage.layer.borderWidth = 1.0f;
    self.avatarImage.clipsToBounds = YES;
}

-(void)updateAvatarButton:(CARD_STATUS) cardStatus
{
    if (cardStatus == CARD_STATUS_NO_IMAGE) {
        self.avatarButton.enabled = YES;
        [self.avatarButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateNormal];
        [self.avatarButton setTitle:@"上传头像" forState:UIControlStateNormal];
    } else {
        self.avatarButton.enabled = NO;
        [self.avatarButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.avatarButton setTitle:nil forState:UIControlStateNormal];
    }
}

-(void)updateAvatar:(MonthCard *)card
{
    [self updateAvatarImage:card.avatarThumbURL];
    [self updateAvatarButton:card.cardStatus];
}

-(void)updateViewWithFinishBuyCard:(MonthCard *)card
{
    self.card = card;
    self.backgroundColor = [UIColor clearColor];
    
    self.maskView.hidden = YES;
    self.assistentView.hidden = YES;
    self.validTimeView.hidden = NO;

    self.nameLabel.text = card.nickName;
    self.endTimelabel.text = [DateUtil stringFromDate:card.endTime DateFormat:@"yyyy/MM/dd"];
    [self updateAvatar:card];
}

-(void)clearView
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user.userId == nil) {
        self.nameLabel.text = @"未登录";
    }else {
        self.nameLabel.text = user.nickname;
    }
    
    [self updateAvatarImage:nil];
    self.validTimeView.hidden = YES;
    [self showErrorNoticeMaskView:CARD_STATUS_INVALID];
}

-(void)updateViewWithCard:(MonthCard *)card
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user.userId == nil) {
        self.nameLabel.text = @"未登录";
    }else {
        self.nameLabel.text = card.nickName;
    }
    
    self.card = card;
    [self updateAvatar:card];
    
    switch (card.cardStatus) {
        case CARD_STATUS_ONCE_PERDAY:
        case CARD_STATUS_NO_IMAGE:
        case CARD_STATUS_VALID:
            self.maskView.hidden = YES;
            self.validTimeView.hidden = NO;
            self.endTimelabel.text = [DateUtil stringFromDate:card.endTime DateFormat:@"yyyy/MM/dd"];
            break;
        case CARD_STATUS_INVALID:
        case CARD_STATUS_FROZEN:
        case CARD_STATUS_CANCEL_TRIPLE:
        case CARD_STATUS_EXPIRED:
            self.validTimeView.hidden = YES;
            [self showErrorNoticeMaskView:card.cardStatus];
            break;
        default:
            self.validTimeView.hidden = YES;
            self.maskView.hidden = YES;
            break;
    }
}

- (CGFloat)getCardHeightWithBounds:(CGRect)bounds
{
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(bounds), CGRectGetHeight(self.bounds));
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    
    CGFloat height =  self.cardView.frame.size.height + 16;
    
    return height;
}

- (IBAction)clickBuyButton:(id)sender {
    [MobClickUtils event:umeng_event_month_card_signin];
    
    if ([_delegate respondsToSelector:@selector(didClickBuyButton)]) {
        [_delegate didClickBuyButton];
    }
}
- (IBAction)clickAssistentButton:(id)sender {
    [MobClickUtils event:umeng_event_month_click_sport_assistant];
    
    if ([_delegate respondsToSelector:@selector(didClickAssistentButton)]) {
        [_delegate didClickAssistentButton];
    }
}

- (IBAction)clickQrCodeButton:(id)sender {
    [MobClickUtils event:umeng_event_month_card_qrcode];
    
    if ([_delegate respondsToSelector:@selector(didClickQrCodeButton)]) {
        [_delegate didClickQrCodeButton];
    } else {
        [self doClickQrCodeButton:self.card delegate:self];
    
    }
}

- (IBAction)clickAvatarButton:(id)sender {
    [MobClickUtils event:umeng_event_month_card_upload_portrait];
    
    if ([_delegate respondsToSelector:@selector(didClickAvatarButton)]) {
        [_delegate didClickAvatarButton];
    }
}


- (IBAction)clickRefreshButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickRefreshButton)]) {
        [_delegate didClickRefreshButton];
    }
}

-(void)doClickQrCodeButton:(MonthCard *)card
                  delegate:(id)delegate
{
//    if (card.cardStatus == CARD_STATUS_ONCE_PERDAY) {
//        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"今日消费次数已达上限" delegate:delegate cancelButtonTitle:@"明天再来" otherButtonTitles:nil, nil];
//        [alert show];
//        
//        return;
//    }else if(card.cardStatus == CARD_STATUS_NO_IMAGE) {
//        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:nil message:@"使用前请上传你的头像" delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        alert.tag = TAG_UPLOAD_AVATAR;
//        [alert show];
//        
//        return;
//    }
//    
//    if (card.cardStatus != CARD_STATUS_VALID) {
//        [SportPopupView popupWithMessage:[NSString stringWithFormat:@"动Club状态异常 %d",card.cardStatus]];
//        return;
//    }
    
    //全部使用后台返回的code
    
    [SportProgressView showWithStatus:@"加载中"];
    
    [MonthCardService getQrCode:self userId:[[UserManager defaultManager] readCurrentUser].userId];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_UPLOAD_AVATAR) {
        if (buttonIndex == alertView.cancelButtonIndex){
            
        }
    }
}

-(void)didGetQrCode:(NSString *)qrCode
             status:(NSString *)status
                msg:(NSString *)msg
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        QrCodeView *view = [QrCodeView createQrCodeViewWithCode:qrCode];
        [view performSelector:@selector(showWithMonthCardCodeView) withObject:nil afterDelay:0.5];
    } else {
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
