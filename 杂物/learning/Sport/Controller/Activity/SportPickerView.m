//
//  SportPickerView.m
//  Sport
//
//  Created by haodong  on 14-5-2.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportPickerView.h"
#import "UIView+Utils.h"

@implementation SportPickerView


+ (SportPickerView *)createSportPickerView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportPickerView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SportPickerView *view = [topLevelObjects objectAtIndex:0];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat y = screenHeight - view.pickerHolderView.frame.size.height;
    [view.pickerHolderView updateOriginY:y];
    view.lineViewConstraintHeight.constant = 0.5;
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_dataList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [_dataList objectAtIndex:row];
    return title;
}

- (IBAction)clickCancelButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)clickOKButton:(id)sender {
    NSInteger selectRow = [self.dataPickerView selectedRowInComponent:0];
    
    if ([_delegate respondsToSelector:@selector(didClickSportPickerViewOKButton:row:)]) {
        [_delegate didClickSportPickerViewOKButton:self row:selectRow];
    }
    [self removeFromSuperview];
}

@end
