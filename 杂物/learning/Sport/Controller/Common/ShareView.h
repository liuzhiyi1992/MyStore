//
//  ShareView.h
//  Sport
//
//  Created by qiuhaodong on 15/5/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareChannelView.h"
#import "ShareContent.h"
#import "QQManager.h"
#import "SNSService.h"
#import <MessageUI/MessageUI.h>

typedef enum
{
    ShareChannelWeChatSession = 0,
    ShareChannelWeChatTimeline = 1,
    ShareChannelSina = 2,
    ShareChannelCopy = 3,
    ShareChannelSMS = 4,
    ShareChannelQQ = 5,
    ShareChannelQQZone = 6,
} ShareChannel;

@protocol ShareViewDelegate <NSObject>
@optional
- (void)willShare:(ShareChannel)channel;
- (void)didShare:(ShareChannel)channel;
- (void)didClickShareViewButton;
@end

@interface ShareView : UIView<ShareChannelViewDelegate, QQManagerDelegate, SNSServiceDelegate, MFMessageComposeViewControllerDelegate>

+ (void )popUpViewWithContent:(ShareContent *)content
                  channelList:(NSArray *)channelList
               viewController:(UIViewController *)viewController
                     delegate:(id<ShareViewDelegate>)delegate;

@end
