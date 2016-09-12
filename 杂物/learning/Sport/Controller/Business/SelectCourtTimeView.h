//
//  SelectCourtTimeView.h
//  Sport
//
//  Created by qiuhaodong on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCourtTimeView : UIScrollView

+ (instancetype)showViewInSuperView:(UIView *)superView
                           timeList:(NSArray *)timeList
                       singleHeight:(CGFloat)singleHeight
                        singleSpace:(CGFloat)singleSpace;

- (void)changeColorWithSelectedProductList:(NSArray *)selectedProductList;

@end
