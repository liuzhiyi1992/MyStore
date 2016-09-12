//
//  SportTimePickerView.h
//  Sport
//
//  Created by haodong  on 14-5-2.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class SportTimePickerView;

@protocol SportTimePickerViewDelegate <NSObject>
@optional
- (void)didClickSportTimePickerViewOKButton:(SportTimePickerView *)sportTimePickerView selectedTime:(NSDate *)selectedTime;
@end

@interface SportTimePickerView : UIView
@property (weak, nonatomic) IBOutlet UIView *pickerHolderView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;

@property (assign, nonatomic) id<SportTimePickerViewDelegate> delegate;

+ (SportTimePickerView *)createSportTimePickerView;

- (void)show;

@end
