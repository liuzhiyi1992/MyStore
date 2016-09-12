//
//  FiltrateButtonView.h
//  Sport
//
//  Created by 冯俊霖 on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FiltrateButtonViewDelegate <NSObject>
@optional
- (void)didClickVenueButton;

- (void)didClickCourseButton;
@end

@interface FiltrateButtonView : UIView

@property (assign, nonatomic) id<FiltrateButtonViewDelegate> delegate;

+ (FiltrateButtonView *)createFiltrateButtonViewWithDelegate:(id<FiltrateButtonViewDelegate>)delegate;

- (void)updateViewWithCourseList:(NSArray *)courseList;


@end
