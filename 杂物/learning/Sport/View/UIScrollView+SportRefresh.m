//
//  UIScrollView+SportRefresh.m
//  Sport
//
//  Created by qiuhaodong on 15/5/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UIScrollView+SportRefresh.h"
#import "MJRefresh.h"
// RGB颜色
#define MJRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 文字颜色
#define SportRefreshLabelTextColor MJRefreshColor(153, 153, 153)

@implementation UIScrollView (SportRefresh)

- (void)addPullDownReloadWithTarget:(id)target action:(SEL)action
{
   
 //动画代码
//    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:target refreshingAction:action];
//    
//  隐藏时间
//    header.lastUpdatedTimeLabel.hidden = YES;
//    
// 隐藏状态
//    header.stateLab el.hidden = YES;
    
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:target refreshingAction:action];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.textColor = SportRefreshLabelTextColor;
    [header.arrowView setImage:[UIImage imageNamed:@"MJArrow"]];
   self.mj_header=header;
 
}

- (void)addPullUpLoadMoreWithTarget:(id)target action:(SEL)action
{
 
  MJRefreshAutoStateFooter *foot=[MJRefreshAutoStateFooter footerWithRefreshingTarget:target refreshingAction:action];
    //动画代码
 //MJChiBaoZiFooter *foot=[MJChiBaoZiFooter footerWithRefreshingTarget:target refreshingAction:action];
  // foot.refreshingTitleHidden=YES;
    
    // 隐藏状态
  //foot.stateLabel.hidden = NO;
    foot.stateLabel.textColor = MJRefreshLabelTextColor;
    
    self.mj_footer = foot;
    self.mj_footer.automaticallyHidden = NO;
    self.mj_footer.hidden = YES;
}

- (void)beginReload
{
    [self.mj_header beginRefreshing];
}

- (void)beginLoadMore
{
    [self.mj_footer beginRefreshing];
}

- (void)endLoad
{
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

- (void)canLoadMore
{
    self.mj_footer.hidden = NO;
    [self.mj_footer resetNoMoreData];
}

- (void)canNotLoadMore
{
    
    [self.mj_footer endRefreshingWithNoMoreData];
    self.mj_footer.hidden = YES;
   
}



@end
