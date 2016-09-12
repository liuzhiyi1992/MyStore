//
//  AddMembershipCardController.m
//  Sport
//
//  Created by 江彦聪 on 15/4/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "AddMembershipCardController.h"
#import "ScanQrCodeMaskView.h"
#import "MembershipCardVerifyPhoneController.h"
#import "MembershipCardListController.h"
#import "UserManager.h"
#import "SportProgressView.h"

@interface AddMembershipCardController ()
@property (weak, nonatomic) IBOutlet UIView *scanFailedView;

@property (weak,nonatomic)  IBOutlet UIButton *verifyPhoneButton;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIView *errorNoticeView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *multiLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionTextLabel;

@property (copy, nonatomic) NSString *defaultPhone;
@property (weak, nonatomic) IBOutlet UILabel *errorDecsLabel;

@end

#define TAG_ALREADY_BIND 0x001

@implementation AddMembershipCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定会员卡";
    // Do any additional setup after loading the view.
    self.descTextLabel.text = @"把会员卡上的二维码放入框内";
    
    self.verifyPhoneButton.layer.cornerRadius = 5.0f;
    self.verifyPhoneButton.layer.masksToBounds = YES;
    self.verifyPhoneButton.layer.borderWidth = 1.0f;
    self.verifyPhoneButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.scanFailedView.hidden = YES;
    
    self.delegate = self;
    
    self.errorNoticeView.hidden = YES;
    
    self.bottomHolderView.hidden = YES;
    
    //IOS 7 workaround
    for (UILabel *label in _multiLineLabel) {
        label.preferredMaxLayoutWidth = label.bounds.size.width;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.view bringSubviewToFront:self.bottomHolderView];
}

#define QR_CODE_PREFIX @"cno"
- (void) willValidateQrCode:(NSString *)string
{
    NSString *cardNumber = [self validCardNumber:string];
 
    if (cardNumber == nil) {
        
        [self updateAndShowScanFailedViewWithTitle:@"没有扫描到会员卡信息，请重新扫描"];
        
        return;
    }
    
    User *user =[[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"正在扫描"];
    if([user.userId length] > 0)
    {
        [MembershipCardService scanCardLogined:self
                                    cardNumber:cardNumber
                                        userId:user.userId
                                         phone:user.phoneNumber];
    }
    else
    {
        [MembershipCardService scanCard:self
                             cardNumber:cardNumber];
    
    }
}

- (NSString *)validCardNumber:(NSString *)code
{
    NSArray *urlArray = [code componentsSeparatedByString:@"?"];
    
    if([urlArray count] < 2)
    {
        return nil;
    }
    
    NSArray *codeArray = [[urlArray objectAtIndex:1] componentsSeparatedByString:@"&"];
    
    NSDictionary *dict = [NSMutableDictionary dictionary];

    for (NSString *string in codeArray) {
        NSArray *qrCodeArray = [string componentsSeparatedByString:@"="];
        if (qrCodeArray && ([qrCodeArray count] == 2)) {
            [dict setValue:[qrCodeArray objectAtIndex:1] forKey:[qrCodeArray objectAtIndex:0]];
            HDLog(@"code[0] %@, code[1], %@", qrCodeArray[0],qrCodeArray[1]);
        }
    }
    
    NSString *scanResult = nil;
    if (dict != nil) {
        scanResult = [dict valueForKey:QR_CODE_PREFIX];
    }
    
    return scanResult;
}

- (void)didScanCard:(MembershipCard *)card
             status:(NSString *)status
                msg:(NSString *)msg
              title:(NSString *)title
            content:(NSString *)content
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"扫描成功"];
        MembershipCardVerifyPhoneController *controller = [[MembershipCardVerifyPhoneController alloc]initWithType:VerifyPhoneTypeMembershipCard card:card isBindNewPhone:YES];
                                                           
        [self.navigationController pushViewController:controller animated:YES];
    }else {

        if (status) {
            [self updateAndShowErrorNoticeViewWithTitle:title
                                               bodyText:content];
            [SportProgressView dismiss];
        } else {
            [self updateAndShowScanFailedViewWithTitle:@"当前网络不可用，请检查网络设置"];
            [SportProgressView dismissWithError:msg];
        }
    }
}

- (void)didScanCardLogined:(MembershipCard *)card
                    status:(NSString *)status
                       msg:(NSString *)msg
                     title:(NSString *)title
                   content:(NSString *)content
{
    [MobClickUtils event:umeng_event_business_detail_click_image_info label:status];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"扫描成功"];
        
        BOOL isJump = NO;
        if ([msg isEqualToString:@"success"]) {
            NSUInteger count = [self.navigationController.viewControllers count];
            if (count > 2) {
                if ([[self.navigationController.viewControllers objectAtIndex:count - 2] isKindOfClass:[MembershipCardListController class]]) {
                    MembershipCardListController *controller = [self.navigationController.viewControllers objectAtIndex:count - 2];
                    [controller setBindOneCard:card];
                
                    [self.navigationController popViewControllerAnimated:NO];
                    isJump = YES;
                }
            }
            
            if (isJump == NO) {
                //扫描未绑定的会员卡时，重用MembershipCardListController
                // 正常情况下，不会到这里。只有当上个页面不是MembershipCardListController，才重新load新controller
                MembershipCardListController *controller = [[MembershipCardListController alloc]initWithBindOneCard:card];
                
                //避免重新回退AddMemershipCard
                [self.navigationController popViewControllerAnimated:YES];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            alertView.tag = TAG_ALREADY_BIND;
            [alertView show];
        }
    }else {
        if (status) {
            [self updateAndShowErrorNoticeViewWithTitle:title
                                           bodyText:content];
            [SportProgressView dismiss];
        } else {

            [SportProgressView dismissWithError:msg];
            [self updateAndShowScanFailedViewWithTitle:@"当前网络不可用，请检查网络设置"];
        }

    }
}

-(void) updateAndShowScanFailedViewWithTitle:(NSString *)title
{
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:title
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    self.scanFailedView.hidden = NO;
    self.errorDecsLabel.text = title;
    [self performSelector:@selector(startRunning) withObject:nil afterDelay:2];
}


-(void) updateAndShowErrorNoticeViewWithTitle:(NSString *)title
                                        bodyText:(NSString *)bodyText
{
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:title
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    self.errorTitleLabel.text = title;

    self.errorTitleLabel.numberOfLines = 0;
    [self.errorTitleLabel sizeToFit];
    self.bodyTextLabel.text = bodyText;
    self.errorNoticeView.hidden= NO;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

#pragma mark - Alert View delgate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALREADY_BIND) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

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
