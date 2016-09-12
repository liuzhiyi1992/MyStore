//
//  SmallPromoteView.m
//  Sport
//
//  Created by haodong  on 14-9-26.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SmallPromoteView.h"
#import "UIView+Utils.h"
#import "NSString+Utils.h"
#import "UIBlueRoundStokeButton.h"
@interface SmallPromoteView()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIBlueRoundStokeButton *button;
@end

@implementation SmallPromoteView


+ (SmallPromoteView *)createSmallPromoteView
{
    SmallPromoteView *view = [[SmallPromoteView alloc] initWithFrame:CGRectMake(0, 0, 20, 13)] ;
    view.backgroundColor = [UIColor clearColor];
    
    view.button = [[UIBlueRoundStokeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 13)];
    view.button.layer.borderWidth = 0.5;
    view.button.userInteractionEnabled = NO;
//    view.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 13)] ;
//    [view.backgroundImageView setImage:[SportImage blueFrameButtonImage]];
    [view addSubview:view.button];
    
    view.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 13)] ;
    [view.valueLabel setBackgroundColor:[UIColor clearColor]];
    [view.valueLabel setFont:[UIFont systemFontOfSize:9]];
    [view.valueLabel setTextAlignment:NSTextAlignmentCenter];
    [view.valueLabel setTextColor:[SportColor defaultColor]];
    [view addSubview:view.valueLabel];
    return view;
}

- (void)updateView:(NSString *)value
{
    self.valueLabel.text = value;
    CGSize size = [self.valueLabel.text sizeWithMyFont:_valueLabel.font];
    [self.valueLabel updateWidth:size.width + 6];
    [self.button updateWidth:_valueLabel.frame.size.width];
    [self updateWidth:_valueLabel.frame.size.width];
}

@end
