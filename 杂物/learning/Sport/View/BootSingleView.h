//
//  BootSingleView.h
//  Sport
//
//  Created by 江彦聪 on 15/3/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BootSingleView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mainTitleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *subTitleImageView;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonYLayoutConstraint;

+ (BootSingleView *)createBootSingleView;
- (void)setButtonStyle;
@end
