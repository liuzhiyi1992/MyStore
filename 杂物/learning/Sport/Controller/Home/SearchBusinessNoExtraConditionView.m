//
//  SearchBusinessNoExtraConditionView.m
//  Sport
//
//  Created by xiaoyang on 16/6/6.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SearchBusinessNoExtraConditionView.h"
#import "LayoutConstraintUtil.h"

@interface SearchBusinessNoExtraConditionView()
@property (assign, nonatomic) id<SearchBusinessNoExtraConditionViewDelegate>delegate;

@end

@implementation SearchBusinessNoExtraConditionView

+ (SearchBusinessNoExtraConditionView *)createSearchBusinessQuicklyViewWithDelegate:(id<SearchBusinessNoExtraConditionViewDelegate>)delegate
                                                          fatherHolderView:(UIView *)fatherHolderView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchBusinessNoExtraConditionView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    SearchBusinessNoExtraConditionView *view = (SearchBusinessNoExtraConditionView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [LayoutConstraintUtil view:view addConstraintsWithSuperView:fatherHolderView];
    [view.searchButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackground"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [view.searchButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackgroundSelected"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateHighlighted];
    return view;
}

- (IBAction)clickDatePickerViewButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDatePickerViewNoExtraCondition)]) {
        [_delegate didClickDatePickerViewNoExtraCondition];
    }
}

- (IBAction)clickHourPickerButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickHourPickerViewNoExtraCondition)]) {
        [_delegate didClickHourPickerViewNoExtraCondition];
    }
}
- (IBAction)clickSearchBusinessButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(clickSearchBusinessNoExtraCondition)]) {
        [_delegate clickSearchBusinessNoExtraCondition];
    }
}
@end
