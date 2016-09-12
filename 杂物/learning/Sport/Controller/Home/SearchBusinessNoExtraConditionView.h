//
//  SearchBusinessNoExtraConditionView.h
//  Sport
//
//  Created by xiaoyang on 16/6/6.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchBusinessNoExtraConditionViewDelegate <NSObject>
@optional
- (void)didClickDatePickerViewNoExtraCondition;
- (void)didClickHourPickerViewNoExtraCondition;
- (void)clickSearchBusinessNoExtraCondition;
@end

@interface SearchBusinessNoExtraConditionView : UIView
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *hourLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *hourLabelFour;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

+ (SearchBusinessNoExtraConditionView *)createSearchBusinessQuicklyViewWithDelegate:(id<SearchBusinessNoExtraConditionViewDelegate>)delegate
                                                                   fatherHolderView:(UIView *)fatherHolderView;

@end
