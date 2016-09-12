//
//  GrayPageControl.m
//  Sport
//
//  Created by 江彦聪 on 15/8/1.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "GrayPageControl.h"

@implementation GrayPageControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    activeImage = [SportImage activeDotImage];
    inactiveImage = [SportImage inactiveDotImage];
    
    return self;
}

-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self imageViewForSubview:[self.subviews objectAtIndex: i]];
        if (i == self.currentPage) dot.image = activeImage;
        else dot.image = inactiveImage;
    }
}

-(void) setCurrentPage:(NSInteger)page
{
    activeImage = [SportImage activeDotImage];
    inactiveImage = [SportImage inactiveDotImage];
    [super setCurrentPage:page];
    [self updateDots];
}

- (UIImageView *) imageViewForSubview: (UIView *) view
{
    UIImageView * dot = nil;
    if ([view isKindOfClass: [UIView class]])
    {
        for (UIView* subview in view.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView *)subview;
                break;
            }
        }
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:dot];
        }
    }
    else
    {
        dot = (UIImageView *) view;
    }
    
    return dot;
}

- (void)awakeFromNib
{
    self.pageIndicatorTintColor = [UIColor clearColor];
    self.currentPageIndicatorTintColor = [UIColor clearColor];
}
@end
