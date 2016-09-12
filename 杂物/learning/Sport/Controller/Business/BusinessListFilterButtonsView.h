//
//  BusinessListFilterButtonsView.h
//  Sport
//
//  Created by qiuhaodong on 16/8/3.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  BusinessListFilterButtonsViewDelegate <NSObject>
@optional
- (void)didClickBusinessListFilterButtonsView:(NSUInteger)index isOpen:(BOOL)isOpen;
@end

@interface BusinessListFilterButtonsView : UIView

+ (BusinessListFilterButtonsView *)showInSuperView:(UIView *)superView
                                          delegate:(id<BusinessListFilterButtonsViewDelegate>)delegate;

- (void)updateWithTitleArray:(NSArray *)titleArray;

@end
