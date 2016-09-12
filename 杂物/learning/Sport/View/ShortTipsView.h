//
//  ShortTipsView.h
//  Sport
//
//  Created by liuzhiyi on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShortTipsView : UIView


@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *SpaceLineImageView;

+ (ShortTipsView *)creatShortTipsView;

- (void)showWithContent:(NSString *)string frame:(CGRect)frame durationDisplay:(BOOL)durationDisplay holderView:(UIView *)holderView;

- (void)dismiss;

@end
