//
//  SportStartAndEndTimePickerView.h
//  Sport
//
//  Created by haodong  on 14-5-2.
//  Copyright (c) 2014年 haodong . All rights rese rved.
//

#import <UIKit/UIKit.h>

@class SportStartAndEndTimePickerView;

@protocol SportStartAndEndTimePickerViewDelegate <NSObject>
@optional
- (void)didClickSportStartAndEndTimePickerViewOKButton:(SportStartAndEndTimePickerView *)sportPickerView;
@end

@interface SportStartAndEndTimePickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *pickerHolderView;
@property (weak, nonatomic) IBOutlet UIPickerView *dataPickerView;

@property (assign, nonatomic) id<SportStartAndEndTimePickerViewDelegate> delegate;

@property (strong, nonatomic) NSArray *dataList; //注意：数组里面的元素应该是数组

- (void)show;

+ (SportStartAndEndTimePickerView *)popupPickerWithDelegate:(id<SportStartAndEndTimePickerViewDelegate>)delegate dataArray:(NSArray *)dataArray;

+ (SportStartAndEndTimePickerView *)popupPickerWithDataArray:(NSArray *)dataArray currentSelectedArray:(NSArray *)currentSelectedArray currentClickPickerStyleId:(NSInteger)currentClickPickerStyleId  handler:(void (^)(SportStartAndEndTimePickerView *view))handler;

@end
