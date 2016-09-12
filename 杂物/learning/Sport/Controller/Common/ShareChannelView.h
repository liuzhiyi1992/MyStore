//
//  ShareChannelView.h
//  Sport
//
//  Created by qiuhaodong on 15/5/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareChannelView;

@protocol ShareChannelViewDelegate <NSObject>
@optional
- (void)didClickShareChannelView:(ShareChannelView *)view;
@end

@interface ShareChannelView : UIView

+ (CGSize)defaultSize;

+ (ShareChannelView *)createViewWithImage:(UIImage *)image
                                     name:(NSString *)name
                                 delegate:(id<ShareChannelViewDelegate>)delegate;

@end
