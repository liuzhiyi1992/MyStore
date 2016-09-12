//
//  OftenGoBusinessView.h
//  Sport
//
//  Created by xiaoyang on 16/5/17.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OftenGoBusinessViewDelegate <NSObject>
@optional
- (void)didClickOftenGoBusinessButtonWithBusinessId:(NSString *)businessId
                                         categoryId:(NSString *)categoryId;
- (void)updateSecondOftenGoBusinessHeight:(CGFloat)height;
@end

@interface OftenGoBusinessView : UIView

@property (weak, nonatomic) IBOutlet UILabel *firstBusinessNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstBusinessRefundImage;
@property (weak, nonatomic) IBOutlet UILabel *firstBusinessDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondBusinessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondBusinessDistanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *secondBusinessRefundImage;
@property (weak, nonatomic) IBOutlet UIButton *firstRefundButton;
@property (weak, nonatomic) IBOutlet UIButton *secondRefundButton;
@property (weak, nonatomic) IBOutlet UIButton *firstVenueButton;
@property (weak, nonatomic) IBOutlet UIButton *secondVenueButton;

- (void)updateOftenGoBusinessViewWithVenueList:(NSArray *)venueList;

+ (OftenGoBusinessView *)createOftenGoBusinessViewWithDelegate:(id<OftenGoBusinessViewDelegate>)delegate
                                              fatherHolderView:(UIView *)fatherHolderView;
@end
