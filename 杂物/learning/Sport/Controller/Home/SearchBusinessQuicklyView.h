//
//  SearchBusinessQuicklyView.h
//  Sport
//
//  Created by xiaoyang on 16/5/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchBusinessQuicklyViewDelegate <NSObject>
@optional

- (void)showDatePickView;
- (void)showHourPickView;
- (void)showExtraConditionPickView;
- (void)clickSearchBusinessButton;

@end

@interface SearchBusinessQuicklyView : UIView
@property (weak, nonatomic) IBOutlet UILabel *pickTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickBeginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthOfSportTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekendLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *hourLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *hourLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *hourLabelFour;
@property (weak, nonatomic) IBOutlet UIButton *extraConditionButton;
@property (weak, nonatomic) IBOutlet UILabel *playerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *outOrIndoorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *searchBusiessBackgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;


+ (SearchBusinessQuicklyView *)createSearchBusinessQuicklyViewWithDelegate:(id<SearchBusinessQuicklyViewDelegate>)delegate
                                                          fatherHolderView:(UIView *)fatherHolderView;


@end
