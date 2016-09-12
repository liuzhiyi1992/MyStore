//
//  CourtJoinDateListView.h
//  Sport
//
//  Created by xiaoyang on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CourtJoinDateListViewDelegate <NSObject>
@optional
- (void)didClickCourtJoinDateListView:(NSDate *)date;
@end


@interface CourtJoinDateListView : UIView
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) id<CourtJoinDateListViewDelegate > delegate;

+(CourtJoinDateListView *)createCourtJoinDateListViewWithHoldViewWidth:(CGFloat)holdViewWidth;

- (void)updatView:(NSDate *)date
       isSelected:(BOOL)isSelected
            index:(int)index;

+ (CGSize)defaultSize;

- (void)updateSelected:(BOOL)isSelected;


@end
