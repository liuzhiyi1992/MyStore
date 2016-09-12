//
//  HomeFooterView.h
//  Sport
//
//  Created by 冯俊霖 on 15/8/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeController;

@protocol HomeFooterViewDelegate <NSObject>
@optional
- (void)didClickLookMoreButton;
@end

@interface HomeFooterView : UIView
@property (assign, nonatomic) id<HomeFooterViewDelegate> delegate;

+ (HomeFooterView *)createHomeFooterViewWithDelegate:(id<HomeFooterViewDelegate>)delegate;

- (void)updateFooterViewWithIsHidebutton:(BOOL)isHidebutton hasMoreCourse:(NSString *)hasMoreCourse courseList:(NSArray *)courseList;

@end
