//
//  SportPickerView.h
//  Sport
//
//  Created by haodong  on 14-5-2.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class SportPickerView;

@protocol SportPickerViewDelegate <NSObject>
@optional
- (void)didClickSportPickerViewOKButton:(SportPickerView *)sportPickerView
                                    row:(NSInteger)row;
@end

@interface SportPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *dataPickerView;
@property (weak, nonatomic) IBOutlet UIView *pickerHolderView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineViewConstraintHeight;

@property (strong, nonatomic) NSArray *dataList;

@property (assign, nonatomic) id<SportPickerViewDelegate> delegate;

+ (SportPickerView *)createSportPickerView;

- (void)show;

@end
