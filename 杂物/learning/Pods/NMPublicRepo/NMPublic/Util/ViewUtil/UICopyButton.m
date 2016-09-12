//
//  UICopyButton.m
//  Sport
//
//  Created by 江彦聪 on 16/4/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UICopyButton.h"

@implementation UICopyButton

- (void)copys:(id)sender
{
    NSString *pBoardString = [self titleForState:UIControlStateApplication];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = pBoardString;
}

- (void)attachTapHandler
{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    press.minimumPressDuration = 1.0;
    [self addGestureRecognizer:press];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copys:)) {
        return YES;
    }
    return NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self attachTapHandler];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self attachTapHandler];
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        
        [self becomeFirstResponder];
        
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copys:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        [menu setMenuItems:[NSArray arrayWithObjects:copy, nil]];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
        
    }
}

@end
