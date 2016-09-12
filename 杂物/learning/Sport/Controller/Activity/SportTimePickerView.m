//
//  SportTimePickerView.m
//  Sport
//
//  Created by haodong  on 14-5-2.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportTimePickerView.h"
#import "UIView+Utils.h"

@implementation SportTimePickerView


+ (SportTimePickerView *)createSportTimePickerView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportTimePickerView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SportTimePickerView *view = [topLevelObjects objectAtIndex:0];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat y = screenHeight - view.pickerHolderView.frame.size.height;
    [view.pickerHolderView updateOriginY:y];
    return view;
}

- (void)show
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [self setFrame:CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height)];
    [keyWindow addSubview:self];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.pickerHolderView updateOriginY:screenHeight];
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat y = screenHeight - self.pickerHolderView.frame.size.height;
        [self.pickerHolderView updateOriginY:y];
    }];
}

- (IBAction)clickCancelButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)clickOKButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickSportTimePickerViewOKButton:selectedTime:)]) {
        [_delegate didClickSportTimePickerViewOKButton:self selectedTime:_datePickerView.date];
    }
    [self removeFromSuperview];
}

@end
