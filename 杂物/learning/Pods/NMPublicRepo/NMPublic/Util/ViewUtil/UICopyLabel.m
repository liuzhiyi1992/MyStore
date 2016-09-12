//
//  UICopyLabel.m
//  Sport
//
//  Created by 江彦聪 on 16/4/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UICopyLabel.h"
@implementation UICopyLabel

#define CopyLabelBackgroundColor    [UIColor colorWithRed:190.0/255.0 green:210.0/255.0 blue:230.0/255.0 alpha:1]

- (void)copys:(id)sender
{
    NSString *pBoardString = self.text;
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
        self.backgroundColor = CopyLabelBackgroundColor;
        
        [self becomeFirstResponder];
        
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copys:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        [menu setMenuItems:[NSArray arrayWithObjects:copy, nil]];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillHideMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

- (void)WillHideMenu:(id)sender
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}

@end
