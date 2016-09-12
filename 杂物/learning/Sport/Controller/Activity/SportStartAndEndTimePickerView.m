//
//  SportStartAndEndTimePickerView.m
//  Sport
//
//  Created by haodong  on 14-5-2.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportStartAndEndTimePickerView.h"
#import "UIView+Utils.h"

@interface SportStartAndEndTimePickerView()
@property (strong, nonatomic) NSArray *currentSelectedArray;
@property (assign, nonatomic) NSInteger currentClickPickerStyleId;
@property (copy, nonatomic) void (^hander)(SportStartAndEndTimePickerView *view);
@end

@implementation SportStartAndEndTimePickerView

+ (SportStartAndEndTimePickerView *)popupPickerWithDelegate:(id<SportStartAndEndTimePickerViewDelegate>)delegate
                                                  dataArray:(NSArray *)dataArray
                                       currentSelectedArray:(NSArray *)currentSelectedArray
                                  currentClickPickerStyleId:(NSInteger)currentClickPickerStyleId{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportStartAndEndTimePickerView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SportStartAndEndTimePickerView *view = [topLevelObjects objectAtIndex:0];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat y = screenHeight - view.pickerHolderView.frame.size.height;
    [view.pickerHolderView updateOriginY:y];
    view.delegate = delegate;
    view.dataList = dataArray;
    view.currentSelectedArray = currentSelectedArray;
    view.currentClickPickerStyleId = currentClickPickerStyleId;
    [view show];
    return view;
}

+ (SportStartAndEndTimePickerView *)popupPickerWithDelegate:(id<SportStartAndEndTimePickerViewDelegate>)delegate dataArray:(NSArray *)dataArray {
    return [self popupPickerWithDelegate:delegate dataArray:dataArray currentSelectedArray:nil currentClickPickerStyleId:0];
}

+ (SportStartAndEndTimePickerView *)popupPickerWithDataArray:(NSArray *)dataArray currentSelectedArray:(NSArray *)currentSelectedArray currentClickPickerStyleId:(NSInteger)currentClickPickerStyleId handler:(void (^)(SportStartAndEndTimePickerView *view))handler
{
    SportStartAndEndTimePickerView *view = [self popupPickerWithDelegate:nil dataArray:dataArray currentSelectedArray:currentSelectedArray currentClickPickerStyleId:currentClickPickerStyleId];
    view.hander = handler;
    return view;
}

- (void)show
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
    self.frame = [[UIScreen mainScreen] bounds];
    
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.pickerHolderView updateOriginY:screenHeight];
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat y = screenHeight - self.pickerHolderView.frame.size.height;
        [self.pickerHolderView updateOriginY:y];
    }];
    
    if ([self.currentSelectedArray count] > 0) {
        
        switch (self.currentClickPickerStyleId) {
            case 1:
                [self.dataPickerView selectRow:[_currentSelectedArray[0] integerValue] inComponent:0 animated:NO];
                break;
            case 2:
                [self.dataPickerView selectRow:[_currentSelectedArray[0] integerValue] inComponent:0 animated:NO];
                [self.dataPickerView selectRow:[_currentSelectedArray[1] integerValue] inComponent:1 animated:NO];
                break;
            case 3:
                [self.dataPickerView selectRow:[_currentSelectedArray[0] integerValue] inComponent:0 animated:NO];
                [self.dataPickerView selectRow:[_currentSelectedArray[1] integerValue] inComponent:1 animated:NO];
                break;
            case 4:
                [self.dataPickerView selectRow:[_currentSelectedArray[0] integerValue] inComponent:0 animated:NO];
                break;
            default:
                break;
        }

    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [_dataList count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray *list = [_dataList objectAtIndex:component];
    return [list count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{

    NSArray *list = [_dataList objectAtIndex:component];
    NSString *title = [list objectAtIndex:row];;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/MAX(1, [_dataList count]), 20)] ;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = title;
    return label;
}

- (IBAction)clickCancelButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)clickOKButton:(id)sender {
    if (self.hander) {
        self.hander(self);
    }
    if ([_delegate respondsToSelector:@selector(didClickSportStartAndEndTimePickerViewOKButton:)]) {
        [_delegate didClickSportStartAndEndTimePickerViewOKButton:self];
    }
    [self removeFromSuperview];
}

@end
