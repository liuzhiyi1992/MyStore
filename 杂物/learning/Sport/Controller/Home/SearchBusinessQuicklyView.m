//
//  SearchBusinessQuicklyView.m
//  Sport
//
//  Created by xiaoyang on 16/5/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SearchBusinessQuicklyView.h"
#import "LayoutConstraintUtil.h"

@interface SearchBusinessQuicklyView()
@property (assign, nonatomic) id<SearchBusinessQuicklyViewDelegate>delegate;

@end
@implementation SearchBusinessQuicklyView

+ (SearchBusinessQuicklyView *)createSearchBusinessQuicklyViewWithDelegate:(id<SearchBusinessQuicklyViewDelegate>)delegate
                                                          fatherHolderView:(UIView *)fatherHolderView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchBusinessQuicklyView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    SearchBusinessQuicklyView *view = (SearchBusinessQuicklyView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [LayoutConstraintUtil view:view addConstraintsWithSuperView:fatherHolderView];
    [view.searchButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackground"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [view.searchButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackgroundSelected"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateHighlighted];
    return view;
}

- (IBAction)clickDatePickButton:(id)sender {
    if([_delegate respondsToSelector:@selector(showDatePickView)]){
        
        [_delegate showDatePickView];
        
    }
}
- (IBAction)clickHourButton:(id)sender {
    if([_delegate respondsToSelector:@selector(showHourPickView)]){
        [_delegate showHourPickView];
    }
}
- (IBAction)clickPickerExtraConditionButton:(id)sender {
    if([_delegate respondsToSelector:@selector(showExtraConditionPickView)]){
        [_delegate showExtraConditionPickView];
    }
}
- (IBAction)clickSearchBusinessButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(clickSearchBusinessButton)]){
        
        [_delegate clickSearchBusinessButton];
    }
}


@end
