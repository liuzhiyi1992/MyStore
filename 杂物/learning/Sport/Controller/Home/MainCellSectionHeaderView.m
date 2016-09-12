//
//  MainCellSectionHeaderView.m
//  Sport
//
//  Created by xiaoyang on 16/5/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "MainCellSectionHeaderView.h"

@implementation MainCellSectionHeaderView

+ (MainCellSectionHeaderView *)createMainCellSectionHeaderViewWithDelegate:(id<MainCellSectionHeaderViewDelegate>)delegate{
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MainCellSectionHeaderView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    MainCellSectionHeaderView *view = (MainCellSectionHeaderView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;

    return view;
}
- (IBAction)clickCheckMoreButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickCheckMoreButton)]){
        [_delegate didClickCheckMoreButton];
    }
}

@end
