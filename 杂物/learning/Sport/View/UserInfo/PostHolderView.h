//
//  PostHolderView.h
//  Sport
//
//  Created by liuzhiyi on 15/11/5.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

@protocol PostHolderViewDelegate <NSObject>

- (void)postHolderViewDidClickedWithTitle:(NSString *)title;

@end


@interface PostHolderView : DDTableViewCell

@property (weak, nonatomic) id<PostHolderViewDelegate> delegate;

+ (NSString *)getCellIdentifier;

+ (PostHolderView *)creatViewWithStatus:(BOOL)status count:(NSString *)count imageUrl:(NSURL *)imageUrl content:(NSString *)content;

+ (CGFloat)getCellHeight;

- (void)updateViewWithCount:(NSString *)count imageUrl:(NSURL *)imageUrl content:(NSString *)content;

@end
