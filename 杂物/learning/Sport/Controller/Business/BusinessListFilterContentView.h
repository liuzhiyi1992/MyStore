//
//  BusinessListFilterContentView.h
//  Sport
//
//  Created by qiuhaodong on 16/8/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PullDownTypeCategory = 0,
    PullDownTypeRegion = 1,
    PullDownFilter = 2,
    PullDownTypeSort = 3
} PullDownType;

@interface BusinessListFilterContentView : UIView

+ (BusinessListFilterContentView *)showInSuperView:(UIView *)superView
                                      belowSubview:(UIView *)belowSubview
                         superViewHeightConstraint:(NSLayoutConstraint *)superViewHeightConstraint
                                        categoryId:(NSString *)categoryId
                                      pullDownType:(PullDownType)pullDownType
                                        selectedId:(NSString *)selectedId
                                     finishHandler:(void (^)(NSString *selectedId))finishHandler
                                    dismissHandler:(void (^)())dismissHandler;

- (void)dismiss;

@end
