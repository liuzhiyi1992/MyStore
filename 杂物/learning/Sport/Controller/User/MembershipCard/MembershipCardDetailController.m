//
//  MembershipCardDetailController.m
//  Sport
//
//  Created by haodong  on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MembershipCardDetailController.h"
#import "InputPasswordView.h"
#import "RechargeController.h"
#import "PriceUtil.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "BusinessDetailController.h"
#import "MembershipCardListController.h"
#import "MoneyRecordController.h"
#import "UIAlertView+Block.h"
#import "MembershipCard.h"
#import "MembershipCardVerifyPhoneController.h"

@interface MembershipCardDetailController ()
@property (strong, nonatomic) MembershipCard *card;
@end

@implementation MembershipCardDetailController


- (id)initWithCard:(MembershipCard *)card
{
    self = [super init];
    if (self) {
        self.card = card;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.card.businessName;
    
    [MobClickUtils event:umeng_event_card_detail];
    
    self.infoHolderView.hidden = YES;
   // [self queryData];
    [self updateCardInfoView];
}


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    //[self queryData];
}

- (void)updateCardInfoView
{
    self.infoHolderView.hidden = NO;
    [self.infoHolderView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+1)];
    
//    [self.bookButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
    [self.rechargeButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    self.rechargeButton.hidden = YES;
    
    //[self createRightTopButton:@"设置"];
    self.amountLabel.text = [NSString stringWithFormat:@"￥%@",[PriceUtil toValidPriceString:_card.money]];
    
    if (self.card.status == CardStatusLock && [self.card.oldPhone length] > 4 && [self.card.phone length] > 4) {
        NSString *content = [NSString stringWithFormat:@"该会员卡手机号码变更为%@,您可以确认转移，或者重新绑回本账户，否则该会员卡在趣运动上无法使用",self.card.phone];
        NSString *button1Msg = [NSString stringWithFormat:@"确认转移至%@尾号的账号", [self.card.phone substringFromIndex:[self.card.phone length] - 4]];
        NSString *button2Msg = [NSString stringWithFormat:@"重新绑定回%@尾号的账号",[self.card.oldPhone substringFromIndex:[self.card.oldPhone length]-4]];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:button1Msg, button2Msg,nil];
        [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                //转移到新的会员卡
                MembershipCardVerifyPhoneController *controller = [[MembershipCardVerifyPhoneController alloc]initWithType:VerifyPhoneTypeMembershipCard card:self.card isBindNewPhone:YES];
                 [self.navigationController pushViewController:controller animated:YES];
            } else if (buttonIndex == 2) {
                //绑定回原会员卡
                MembershipCardVerifyPhoneController *controller = [[MembershipCardVerifyPhoneController alloc]initWithType:VerifyPhoneTypeMembershipCard card:self.card isBindNewPhone:NO];
                
                [self.navigationController pushViewController:controller animated:YES];
                
            } else {
                
            }
            
        }];

    
    }
    
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
    NSString *userId = [[[UserManager defaultManager] readCurrentUser] userId];
    [MembershipCardService getCardDetail:self
                              cardNumber:self.card.cardNumber
                                  userId:userId
                                   phone:self.card.phone
                              businessId:self.card.businessId];
}

- (void)didGetCardDetail:(MembershipCard *)card
                  status:(NSString *)status
                     msg:(NSString *)msg
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.card = card;
        
        [self updateCardInfoView];
        
        [self removeNoDataView];
    } else {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        [self showNoDataViewWithType:NoDataTypeDefault frame:CGRectMake(0, 0, screenSize.width, screenSize.height - 20 - 44) tips:msg];
    }
}

- (void)didClickRechargeControllerBookButton
{
    [self performSelector:@selector(pushBusinessDetail) withObject:nil afterDelay:0.2];
}

- (IBAction)clickBookButton:(id)sender {
    [MobClickUtils event:umeng_event_card_detail_click_book];
    [self pushBusinessDetail];
}

- (void)pushBusinessDetail
{
    BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:self.card.businessId categoryId:self.card.categoryId] ;
    [self.navigationController pushViewController:controller animated:NO];
}

- (IBAction)clickRechargeButton:(id)sender {
    [MobClickUtils event:umeng_event_card_detail_click_recharge];
    
    [SportProgressView showWithStatus:@"正在加载"];
    [MembershipCardService getUserCardGoodsList:self
                                     cardNumber:self.card.cardNumber
                                         userId:[[[UserManager defaultManager] readCurrentUser] userId]];

}

- (void)didGetUserCardGoodsList:(NSArray *)goodsList status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        RechargeController *controller = [[RechargeController alloc] initWithGoodsList:goodsList card:self.card] ;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_card_detail_click_set];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"解绑会员卡" otherButtonTitles:nil] ;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [MobClickUtils event:umeng_event_card_detail_click_unbind];
    
    // 如果有支付密码，待验证正确之后再解绑
    if ([[UserManager defaultManager] readCurrentUser].hasPayPassWord) {
        [self performSelector:@selector(showInputPasswordWithTypeValue:) withObject:@(InputPasswordTypeVerify) afterDelay:0.5];
    }
    else
    {
        [self unBindCardWithPassword:nil];
    }
}

-(void) unBindCardWithPassword:(NSString *)password
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"解绑中"];
 
   [MembershipCardService unbindCard:self
                          cardNumber:self.card.cardNumber
                              userId:user.userId
                         payPassword:password
                    isSetPayPassword:user.hasPayPassWord];
}


#pragma mark --MembershipCardService delegate
#define TAG_UNBIND_CARD 0x001
- (void)didUnbindCard:(NSString *)status
                  msg:(NSString *)msg
{
   
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [MobClickUtils event:umeng_event_card_detail_unbind_success];
        
        [SportProgressView dismissWithSuccess:@"解绑成功"];
        if ([self previousControllerIsMembercardListController]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else {
        [SportProgressView dismissWithError:msg];
    }
}

- (BOOL)previousControllerIsMembercardListController //前一个Controller是否MembershipCardListController
{
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 2) {
        if ([[self.navigationController.viewControllers objectAtIndex:count - 2] isKindOfClass:[MembershipCardListController class]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)showInputPasswordWithTypeValue:(NSNumber *)typeValue
{
    NSString *code = nil;
    InputPasswordType type = (InputPasswordType)[typeValue intValue];
    
    [InputPasswordView popUpViewWithType:type
                                delegate:self
                                 smsCode:code];
}

#define TAG_PAY_PASSWORD_WRONG 0x001
- (id)didFinishVerifyPayPassword:(NSString *)payPassword status:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self unBindCardWithPassword:payPassword];
    }
    else if([status isEqualToString:STATUS_PAY_PASSWORD_WRONG]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                message:@"支付密码错误"
                                delegate:self
                                cancelButtonTitle:@"返回"
                                otherButtonTitles:@"重试",@"忘记密码",nil];
        alertView.tag = TAG_PAY_PASSWORD_WRONG;
        [alertView show];
    }
    return nil;
}


#pragma mark -- Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_PAY_PASSWORD_WRONG) {
        if (buttonIndex == 1) {
            [self performSelector:@selector(showInputPasswordWithTypeValue:) withObject:@(InputPasswordTypeVerify) afterDelay:0.5];
        }
        else if(buttonIndex == 2)
        {
            RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeForgotPassword phoneNumber:self.card.phone] ;
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (IBAction)clickRecordButton:(id)sender {
    
    MoneyRecordController *controller = [[MoneyRecordController alloc]initWithMoney:self.card.money cardNumber:self.card.cardNumber type:RecordTypeMembershipcard cardMobile:self.card.phone venueId:self.card.businessId];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
