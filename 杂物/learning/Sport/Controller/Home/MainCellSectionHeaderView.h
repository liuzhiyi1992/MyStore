//
//  MainCellSectionHeaderView.h
//  Sport
//
//  Created by xiaoyang on 16/5/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  MainCellSectionHeaderViewDelegate<NSObject>

- (void) didClickCheckMoreButton;

@end
@interface MainCellSectionHeaderView : UIView

@property (assign, nonatomic) id<MainCellSectionHeaderViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *checkMoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *courtJoinNameLabel;

+ (MainCellSectionHeaderView *)createMainCellSectionHeaderViewWithDelegate:(id<MainCellSectionHeaderViewDelegate>)delegate;

@end
