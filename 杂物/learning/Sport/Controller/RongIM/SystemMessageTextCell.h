//
//  SystemMessageTextCell.h
//  Sport
//
//  Created by 江彦聪 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

//#import <RongIMKit/RongIMKit.h>
#import "SystemMessage.h"

@protocol SystemMessageTextCellDelegate <NSObject>

- (void)pushBusinessDetailControllerWithBusinessId:(NSString *)businessId
                                        categoryId:(NSString *)categoryId;
- (void)pushWebViewWithUrl:(NSString *)url
                     title:(NSString *)title;

- (void)pushMembershipWebController:(NSString *)url;
- (void)pushPostDetailControllerWithPostId:(NSString *)postId
                                   content:(NSString *)content;

- (void)pushVoucherController;
- (void)pushOrderListController;
- (void)pushInviteShareController;
@end



@interface SystemMessageTextCell : DDTableViewCell
- (void)updateCell:(SystemMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@property (weak, nonatomic) id<SystemMessageTextCellDelegate>delegate;
@end
