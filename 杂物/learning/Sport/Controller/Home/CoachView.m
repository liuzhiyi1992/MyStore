//
//  CoachView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachView.h"
#import "Coach.h"
#import "BusinessCategory.h"
#import "UIImageView+WebCache.h"
#import "PriceUtil.h"
#import "CLLocation+Util.h"
#import "UserManager.h"

@interface CoachView()
@property (assign, nonatomic) id<CoachViewDelegate> delegate;
@property (strong, nonatomic) Coach *coach;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *categoryHolderView;

@property (weak, nonatomic) IBOutlet UIImageView *distanceIconImageView;

@end

@implementation CoachView


+ (CoachView *)createCoachView:(id<CoachViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CoachView *view = (CoachView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    view.backgroundImageView.image = [SportImage whiteFrameBackgroundImage];
    view.avatarImageView.clipsToBounds = YES;
    return view;
}

+ (CGSize)defaultSize
{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 3 * 10) / 2;
    CGFloat height = width + 50;
    return CGSizeMake(width, height);
}

- (void)updateViewWithCoach:(Coach *)coach
{
    self.coach = coach;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:coach.imageUrl] placeholderImage:nil];
    self.nameLabel.text = coach.name;
    self.priceLabel.text = [NSString stringWithFormat:@"¥ %@",coach.price];
    CLLocation *userLocation = [[UserManager defaultManager] readUserLocation];
    CLLocation *coachLocation = [[CLLocation alloc] initWithLatitude:coach.latitude longitude:coach.longitude];
    NSString *distanceString = [userLocation distanceStringValueFromLocation:coachLocation];
    self.distanceLabel.text = distanceString;
    if (distanceString == nil) {
        self.distanceIconImageView.hidden = YES;
    } else {
        self.distanceIconImageView.hidden = NO;
    }
    //[coachLocation release];
    [self updateCategoryList:coach.categoryList];
}

#define TAG_CATEGORY_BASE   10
#define SPACE   3
- (void)updateCategoryList:(NSArray *)categoryList
{
    for (UIView *subView in self.categoryHolderView.subviews) {
        subView.hidden = YES;
    }
    
    int index = 0;
    for (BusinessCategory *category in categoryList) {
        UIImageView *imageView =(UIImageView *)[self.categoryHolderView viewWithTag:TAG_CATEGORY_BASE + index];
        if (imageView == nil) {
            imageView = [[UIImageView alloc] init] ;
            imageView.tag = TAG_CATEGORY_BASE + index;
            [self.categoryHolderView addSubview:imageView];
        }
        CGFloat width = 13;
        [imageView setFrame:CGRectMake(index * (width + SPACE), 0, width, width)];
        imageView.hidden = NO;
        [imageView sd_setImageWithURL:[NSURL URLWithString:category.imageUrl] placeholderImage:nil];
        index ++;
    }
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickCoachView:)]) {
        [_delegate didClickCoachView:self.coach];
    }
}

@end
