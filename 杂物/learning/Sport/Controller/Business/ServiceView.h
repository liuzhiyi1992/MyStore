//
//  ServiceView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServiceViewDelegate <NSObject>

@optional
- (void)didChangeServiceViewHeight:(CGFloat)height;
- (void)didClickServiceViewCell:(NSIndexPath *)indexPath;

@end

#define TITLE_CAN_REFUND @"支持退款"

@interface ServiceView : UIView

+ (ServiceView *)createViewWithServiceList:(NSArray *)serviceList
                                controller:(UIViewController *)controller
                                  delegate:(id<ServiceViewDelegate>)delegate;
-(CGFloat)sectionFooterViewHeight;
@end
