//
//  SmallPromoteView.h
//  Sport
//
//  Created by haodong  on 14-9-26.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallPromoteView : UIView
@property (strong, nonatomic) UILabel *valueLabel;
+ (SmallPromoteView *)createSmallPromoteView;
- (void)updateView:(NSString *)value;

@end
