//
//  ShareView.m
//  Sport
//
//  Created by qiuhaodong on 15/5/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ShareView.h"
#import "UIView+Utils.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "WeixinManager.h"
#import "ShareWithSinaController.h"
#import "SportNavigationController.h"
#import "SNSManager.h"

#import "TencentOpenAPI/QQApiInterface.h"

@interface ShareView()<QQManagerDelegate>

@property (strong, nonatomic) ShareContent *shareContent;
@property (strong, nonatomic) NSArray *channelList;
@property (assign, nonatomic) UIViewController *controller;
@property (assign, nonatomic) id<ShareViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *itemListHolderView;

@end

@implementation ShareView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_SHARE_TO_WECHAT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_SHARE_TO_SINA object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_SHARE_TO_WECHAT_FAIL object:nil];
}

#define TAG_SHARE_VIEW 2015052801
+ (void )popUpViewWithContent:(ShareContent *)content
                        channelList:(NSArray *)channelList
               viewController:(UIViewController *)viewController
                     delegate:(id<ShareViewDelegate>)delegate
{
    UIView *supperView = [UIApplication sharedApplication].keyWindow;
    [(ShareView *)[supperView viewWithTag:TAG_SHARE_VIEW] dismiss];
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return;
    }
    ShareView *view = (ShareView *)[topLevelObjects objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    view.tag = TAG_SHARE_VIEW;
    view.alpha = 0;
    [supperView addSubview:view];
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:view
                                             selector:@selector(finishShareToWeixin)
                                                 name:NOTIFICATION_NAME_FINISH_SHARE_TO_WECHAT
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:view
                                             selector:@selector(shareToWeixinFail)
                                                 name:NOTIFICATION_NAME_SHARE_TO_WECHAT_FAIL
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:view
                                             selector:@selector(finishShareToSina)
                                                 name:NOTIFICATION_NAME_FINISH_SHARE_TO_SINA
                                               object:nil];
    
    view.shareContent = content;
    view.controller = viewController;
    view.channelList = channelList;
    view.delegate = delegate;
    
    [view show];
}

#define MAX_COUNT_ONE_LINE  6
- (void)show
{
    NSUInteger index = 0;
    for (id one in _channelList) {
        ShareChannel channel = [one intValue];
        UIImage *image = nil;
        NSString *name = nil;
        switch (channel) {
            case ShareChannelWeChatSession:
                image = [UIImage imageNamed:@"ShareWechat"];
                name = @"微信";
                break;
            case ShareChannelWeChatTimeline:
                image = [UIImage imageNamed:@"ShareWechatFriends"];
                name = @"朋友圈";
                break;
            case ShareChannelSina:
                image = [UIImage imageNamed:@"ShareSina"];
                name = @"微博";
                break;
            case ShareChannelCopy:
                image = [UIImage imageNamed:@"ShareCopy"];
                name = @"复制链接";
                break;
            case ShareChannelSMS:
                image = [UIImage imageNamed:@"ShareSMS"];
                name = @"短信";
                break;
            case ShareChannelQQ:
                image = [UIImage imageNamed:@"ShareQQ"];
                name = @"QQ";
                break;
            case ShareChannelQQZone:
                image = [UIImage imageNamed:@"ShareQQZone"];
                name = @"QQ空间";
                break;
            default:
                break;
        }
        
        ShareChannelView *channelView = [ShareChannelView createViewWithImage:image name:name delegate:self];
        channelView.tag = index;
        
        CGFloat x, y;
        if ([_channelList count] >= MAX_COUNT_ONE_LINE) {
            x = [ShareChannelView defaultSize].width * (index % MAX_COUNT_ONE_LINE);
            y = [ShareChannelView defaultSize].height * (index/ MAX_COUNT_ONE_LINE);
        } else {
            CGFloat space = ([UIScreen mainScreen].bounds.size.width - ([_channelList count] * [ShareChannelView defaultSize].width)) / ([_channelList count] + 1);
            x = ([ShareChannelView defaultSize].width + space) * index + space;
            y = 0;
        }
        [channelView updateOriginX:x];
        [channelView updateOriginY:y];
        
        [self.itemListHolderView addSubview:channelView];
        
        index ++;
    }
    
    NSUInteger lineCount = ([_channelList count] / MAX_COUNT_ONE_LINE) + ([_channelList count] % MAX_COUNT_ONE_LINE > 0 ? 1 : 0);
    [self.itemListHolderView updateHeight:lineCount * [ShareChannelView defaultSize].height];
    
    [self.itemListHolderView updateOriginY:self.frame.size.height];
    [UIView animateWithDuration:0.2 animations:^{
        [self.itemListHolderView updateOriginY:self.frame.size.height - self.itemListHolderView.frame.size.height];
    }];
}

- (IBAction)touchDownBackground:(id)sender {    
    [self dismiss];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)didClickShareChannelView:(ShareChannelView *)view
{
    self.hidden = YES;
    NSUInteger index = view.tag;
    ShareChannel channel = [[_channelList objectAtIndex:index] intValue];
    
    if ([_delegate respondsToSelector:@selector(willShare:)]) {
        [_delegate willShare:channel];
    }
    
    switch (channel) {
        case ShareChannelWeChatSession:
            [self shareWithWechat:ShareChannelWeChatSession];
            [self didClickShareButton];
            break;
        case ShareChannelWeChatTimeline:
            [self shareWithWechat:ShareChannelWeChatTimeline];
            [self didClickShareButton];
            break;
        case ShareChannelSina:
            [self shareWithSinaWeibo];
            break;
        case ShareChannelCopy:
            [UIPasteboard generalPasteboard].string = self.shareContent.linkUrl;
            [self finishShare:ShareChannelCopy];
            break;
        case ShareChannelSMS:
            [self shareWithSMS];
            break;
        case ShareChannelQQ:
            [self shareToQQ];
            break;
        case ShareChannelQQZone:
            [self shareToQQZone];
            break;
            
        default:
            break;
    }
}

/*
- (void)shareWithTencentWeibo
{
    if ([QQManager isQQInstalled] == NO) {
        [SportPopupView popupWithMessage:@"您尚未安装QQ"];
        return;
    }
    
    [SportProgressView showWithStatus:@"正在分享..."];
    [[QQManager defaultManager] shareToTencentWeibo:self text:[self createShareText]];
}

-(void)didShareToTencentWeibo:(BOOL)isSuccess
{
    [SportProgressView dismiss];
    if (isSuccess) {
        [SportPopupView popupWithMessage:@"分享成功"];
    } else {
        [SportPopupView popupWithMessage:@"分享失败"];
    }
}
 */

- (NSString *)createShareText
{
    NSMutableString *text = [NSMutableString stringWithString:@""];
    [text appendFormat:@"%@ %@",self.shareContent.title, self.shareContent.content];
    if ([self.shareContent.linkUrl length] > 0) {
        [text appendFormat:@" %@", self.shareContent.linkUrl];
    }
    
    return text;
}

- (void)shareWithSinaWeibo
{
    if (![SNSManager isSinaAuthorize]) {
        [SNSManager sinaAuthorize];
        return;
    }
    
    ShareWithSinaController *controller = [[ShareWithSinaController alloc] initWithContent:[self createShareText] image:_shareContent.image imageUrl:_shareContent.imageUrL] ;
    SportNavigationController *nav = [[SportNavigationController alloc] initWithRootViewController:controller] ;
    [self.controller presentViewController:nav animated:YES completion:nil];
}

- (void)shareWithSMS
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil && [messageClass canSendText]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        //picker.navigationBar.tintColor= [UIColor blackColor];
        picker.body = [self createShareText];
        picker.messageComposeDelegate = self;
        [self.controller presentViewController:picker animated:YES completion:nil];
        
    } else  {
    
        if([UIDevice currentDevice].systemVersion.floatValue>=8.0f){
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"此设备不支持发短信" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [_controller presentViewController:alertController animated:YES completion: nil];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"此设备不支持发短信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
        case MessageComposeResultCancelled:
            HDLog(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
            HDLog( @"Result: SMS sent");
            [self finishShare:ShareChannelSMS];
            break;
        case MessageComposeResultFailed:
            HDLog(@"Result: SMS sending failed");
            break;
        default:
            HDLog(@"Result: SMS not sent");
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self dismiss];
}

//分享到微信好友
- (void)shareWithWechat:(ShareChannel)channel
{
    int scene = 0;
    if (channel == ShareChannelWeChatSession) {
        scene = 0;
    } else if (channel == ShareChannelWeChatTimeline) {
        scene = 1;
    }
    
    if ([_shareContent.linkUrl length] > 0) {
        [WeixinManager sendLinkContent:scene
                                 title:_shareContent.title
                                  desc:_shareContent.subTitle
                                 image:(_shareContent.thumbImage ? _shareContent.thumbImage : [UIImage imageNamed:@"defaultIcon"])
                                   url:_shareContent.linkUrl];
    } else {
        [WeixinManager sendTextContent:_shareContent.content scene:scene];
    }
}

- (void)finishShareToWeixin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SportPopupView popupWithMessage:@"分享成功"];
        [self finishShare:ShareChannelWeChatSession];
        [self dismiss];
    });
}

- (void)shareToWeixinFail {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SportPopupView popupWithMessage:@"分享失败"];
        [self dismiss];
    });
}

- (void)finishShareToSina
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SportPopupView popupWithMessage:@"分享成功"];
        [self finishShare:ShareChannelSina];
        [self dismiss];
    });
}

- (void)finishShare:(ShareChannel)channel
{
    if ([_delegate respondsToSelector:@selector(didShare:)]) {
        [_delegate didShare:channel];
    }
}

- (void)didClickShareButton{
    if ([_delegate respondsToSelector:@selector(didClickShareViewButton)]) {
        [_delegate didClickShareViewButton];
    }
}

- (void)shareToQQ{
    [[QQManager defaultManager] getQQUserInfo:self];
    if (_shareContent.linkUrl.length>0&&_shareContent.title>0) {
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:_shareContent.linkUrl]
                                    title:_shareContent.title
                                    description:_shareContent.content
                                    previewImageURL:[NSURL URLWithString:_shareContent.imageUrL]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        NSLog(@"%i",sent);
    }else{
    
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:_shareContent.content];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        //将内容分享到qq
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        NSLog(@"%i",sent);
    }
}

- (void)shareToQQZone{
    [[QQManager defaultManager] getQQUserInfo:self];
    if (_shareContent.linkUrl.length>0&&_shareContent.title>0) {
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:_shareContent.linkUrl]
                                    title:_shareContent.title
                                    description:_shareContent.content
                                    previewImageURL:[NSURL URLWithString:_shareContent.imageUrL]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        NSLog(@"%i",sent);
    }else{
        
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:_shareContent.content];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        //将内容分享到qq
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        NSLog(@"%i",sent);
    }
}

@end
