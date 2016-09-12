//
//  BootSingleView.m
//  Sport
//
//  Created by 江彦聪 on 15/3/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "BootSingleView.h"

@implementation BootSingleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (BootSingleView *)createBootSingleView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BootSingleView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BootSingleView *view = (BootSingleView *)[topLevelObjects objectAtIndex:0];

    return view;
}

- (void)setButtonStyle
{
    [_enterButton setBackgroundImage:[SportImage bootPageEnterButtonImage] forState:UIControlStateNormal];
    [_enterButton setBackgroundImage:[SportImage bootPageEnterButtonSelectedImage] forState:UIControlStateHighlighted];
    //[_enterButton setTitle:@"立即体验" forState:UIControlStateNormal];
    [_enterButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_enterButton setTitleColor:[UIColor colorWithRed:67.0/255.0 green:202.0/255.0 blue:169.0/255.0 alpha:1] forState:UIControlStateHighlighted];

}

@end
