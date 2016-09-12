//
//  PrizeShareController.m
//  Sport
//
//  Created by haodong  on 14/10/28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PrizeShareController.h"
#import "User.h"
#import "UserManager.h"
#import "LoginController.h"
#import "SportPopupView.h"
#import "WeixinManager.h"
#import "BaseConfigManager.h"
#import "SportProgressView.h"
#import "ShareView.h"
#import "ShareContent.h"

@interface PrizeShareController ()<ShareViewDelegate>

@end

@implementation PrizeShareController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_SHARE_TO_WECHAT object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"分享给朋友";
    [self.topBackgroundImageView setImage:[SportImage shareBackgroundImage]];
    [self.inputBackgroundImageView setImage:[SportImage grayFrameButtonImage]];
    
    [self.shareButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishShareToWeixin)
                                                 name:NOTIFICATION_NAME_FINISH_SHARE_TO_WECHAT
                                               object:nil];
    
    self.shareTipsLabel.text = [[BaseConfigManager defaultManager] recommendRemark];
}

- (IBAction)touchDownBackground:(id)sender {
    [self.phoneTextField resignFirstResponder];
}

#define TAG_ACTIONSHEET_SHARE 2014102801
- (IBAction)clickShareButton:(id)sender {
    [self.phoneTextField resignFirstResponder];
    
    if (![UserManager isLogin]) {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    if ([_phoneTextField.text length] < 11) {
        [SportPopupView popupWithMessage:@"请输入正确的手机号"];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"短信", @"微信", nil];
    actionSheet.tag = TAG_ACTIONSHEET_SHARE;
    [actionSheet showInView:self.view];

//    ShareContent *shareContent = [[ShareContent alloc] init] ;
//    shareContent.thumbImage = [SportImage appIconImage];
//    shareContent.title = @"推荐一个预订运动场地的应用";
//    shareContent.subTitle = @"趣运动手机客户端，数百间优质球馆在线查询预订，低至1折免预约订场，赶紧来试试吧！";
//    shareContent.content = @"趣运动手机客户端，数百间优质球馆在线查询预订，低至1折免预约订场，赶紧来试试吧！";
//    shareContent.linkUrl = @"http://m.quyundong.com";
//    [ShareView popUpViewWithContent:shareContent channelList:[NSArray arrayWithObjects: @(ShareChannelWeChatSession), @(ShareChannelSMS), nil] viewController:self delegate:self];

}

- (void)willShare:(ShareChannel)channel{
    if (channel == ShareChannelWeChatSession) {
        [self addPhoneToService:@"0"];
    }else if (channel == ShareChannelSMS) {
        [self addPhoneToService:@"1"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
    } else {
        if (buttonIndex == 0) {
            [self addPhoneToService:@"0"];

        } else if (buttonIndex == 1) {
            [self addPhoneToService:@"1"];
        }
    }
}

- (void)finishShareToWeixin
{
    [SportPopupView popupWithMessage:@"分享成功"];

}

- (void)addPhoneToService:(NSString *)type
{
    [SportProgressView  showWithStatus:@"正在分享"];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    [UserService addSharePhone:self phone:_phoneTextField.text userId:user.userId type:type];
}

- (void)didAddSharePhone:(NSString *)status msg:(NSString *)msg type:(NSString *)type
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        if ([type isEqualToString:@"0"]) {
            [self shareWithSMS];
        }
        else if ([type isEqualToString:@"1"]) {
            [WeixinManager sendLinkContent:0 title:@"这个APP超赞！运动还能约妹纸！" desc:@"我最近在使用趣运动APP，预订场馆、约人陪练超方便，你也来试一下呗！" image:[SportImage appIconImage] url:@"http://m.quyundong.com"];
        }
    }
    else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)shareWithSMS
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil && [messageClass canSendText]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.body = @"我最近在使用趣运动APP，预订场馆、约人陪练超方便，你也来试一下呗！http://m.quyundong.com";
        picker.messageComposeDelegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"此设备不支持发短信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MessageComposeResultCancelled:
            HDLog(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
            HDLog( @"Result: SMS sent");
            [SportPopupView popupWithMessage:@"分享成功"];
            break;
        case MessageComposeResultFailed:
            HDLog(@"Result: SMS sending failed");
            break;
        default:
            HDLog(@"Result: SMS not sent");
            break;
    }
    //[self dismissModalViewControllerAnimated:YES];
    
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}


@end
