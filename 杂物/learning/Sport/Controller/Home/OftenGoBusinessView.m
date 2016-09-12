//
//  OftenGoBusinessView.m
//  Sport
//
//  Created by xiaoyang on 16/5/17.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OftenGoBusinessView.h"
#import "LayoutConstraintUtil.h"
#import "Business.h"
#import "CLLocation+Util.h"
#import "UserManager.h"

@interface OftenGoBusinessView()
@property (assign, nonatomic) id<OftenGoBusinessViewDelegate>delegate;
@property (strong, nonatomic) NSArray *venueList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondHolderViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstHolderViewHeightConstraint;

@end

@implementation OftenGoBusinessView

+ (OftenGoBusinessView *)createOftenGoBusinessViewWithDelegate:(id<OftenGoBusinessViewDelegate>)delegate
                                              fatherHolderView:(UIView *)fatherHolderView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OftenGoBusinessView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    OftenGoBusinessView *view = (OftenGoBusinessView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [LayoutConstraintUtil view:view addConstraintsWithSuperView:fatherHolderView];
    //add该View的时候，顺便更新下数据
//    [view updateOftenGoBusinessViewWithVenueList:venueList];
//    view.venueList = venueList;
    [view.firstRefundButton setBackgroundImage:[[UIImage imageNamed:@"RefundBackground"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    [view.secondRefundButton setBackgroundImage:[[UIImage imageNamed:@"RefundBackground"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    [view.firstVenueButton setBackgroundImage:[SportColor  clearButtonHighlightedBackgroundImage] forState:UIControlStateHighlighted];
    [view.secondVenueButton setBackgroundImage:[SportColor clearButtonHighlightedBackgroundImage] forState:UIControlStateHighlighted];
    return view;
}
- (void)updateOftenGoBusinessViewWithVenueList:(NSArray *)venueList
{
    self.venueList = venueList;
    
    CLLocation *userLocation = [[UserManager defaultManager] readUserLocation];

    //第一个推荐场馆的数据
    Business *businessOne = nil;
    if ([venueList count] > 0) {
        businessOne = venueList[0];
    }
    
    // 第二个推荐场馆的推荐数据
    Business *businessTwo = nil;
    if ([venueList count] > 1) {
        businessTwo = venueList[1];
        self.secondHolderViewHeightConstraint.constant = 75;
    }else {
        self.secondHolderViewHeightConstraint.constant = 0;
    }
    
    [self updateSecondBusinessHeight];
    
    self.firstBusinessNameLabel.text = businessOne.name;
    if (businessOne.canRefund){
        self.firstRefundButton.hidden = NO;
    }else {
        self.firstRefundButton.hidden = YES;
    }
    CLLocation *businessLocation = [[CLLocation alloc] initWithLatitude:businessOne.latitude longitude:businessOne.longitude];
    self.firstBusinessDistanceLabel.text = [userLocation distanceStringValueFromLocation:businessLocation];
    
    
    self.secondBusinessNameLabel.text = businessTwo.name;
    if (businessTwo.canRefund){
        self.secondRefundButton.hidden = NO;
    }else {
        self.secondRefundButton.hidden = YES;
    }
    
    CLLocation *businessLocationTwo = [[CLLocation alloc] initWithLatitude:businessTwo.latitude longitude:businessTwo.longitude];
    self.secondBusinessDistanceLabel.text = [userLocation distanceStringValueFromLocation:businessLocationTwo];
}
- (void)updateSecondBusinessHeight {
    if ([_delegate respondsToSelector:@selector(updateSecondOftenGoBusinessHeight:)]) {
        [_delegate updateSecondOftenGoBusinessHeight:self.secondHolderViewHeightConstraint.constant + self.firstHolderViewHeightConstraint.constant];
    }
}

#define OFTEN_GO_BUTTON_TAG_START 400
- (IBAction)clickOftenGoBusinessButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSUInteger index = button.tag - OFTEN_GO_BUTTON_TAG_START;

    if (index < [self.venueList count]) {
        
        Business *business = self.venueList[index];
        
        if ([_delegate respondsToSelector:@selector(didClickOftenGoBusinessButtonWithBusinessId:categoryId:)]) {
            [_delegate didClickOftenGoBusinessButtonWithBusinessId:business.businessId categoryId:business.defaultCategoryId];
        }
        
    }
}

@end
