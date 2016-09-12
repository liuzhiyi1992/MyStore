//
//  NearbyVenuesView.m
//  Sport
//
//  Created by xiaoyang on 16/1/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "NearbyVenuesView.h"

@interface NearbyVenuesView ()<BusinessServiceDelegate>

@property (weak, nonatomic) IBOutlet UIView *nearbyVenuesHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *venuesImageView;
@property (weak, nonatomic) IBOutlet UILabel *venuesNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesPromotePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesSubTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *promotePriceImageView;

@property (copy, nonatomic) NSString *nearbyBusinessId;
@property (strong, nonatomic) Business *currentBusiness;
@property (copy ,nonatomic) NSString *categoryId;
@property (strong, nonatomic) Business *nearbyVenues;
@property (strong, nonatomic) UIView * superHolderView;

@property (strong,nonatomic) id<NearbyVenuesViewDelegate>delegate;

@end

@implementation NearbyVenuesView


+ (NearbyVenuesView *)createNearbyVenuesViewWithBusiness:(Business *)currentBusiness
                                              categoryId:(NSString *)categoryId
                                               delegate:(id<NearbyVenuesViewDelegate>)delegate
                                               nearbyVenues:(Business *)nearbyVenues
                                              superHolderView:(UIView *)superHoldView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NearbyVenuesView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
   
    }
 
    NearbyVenuesView *view = [topLevelObjects objectAtIndex:0];
    
    view.currentBusiness = currentBusiness;
    view.categoryId = categoryId;
    view.nearbyVenues = nearbyVenues;
    view.delegate = delegate;
    view.superHolderView = superHoldView;
    
    [view updateView];
    [view superHolderViewAddSelf];
    
    return view;
}

  //场馆详情add该view并且增加代码autolayout约束
- (void)superHolderViewAddSelf{
    
    [self.superHolderView addSubview:self];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superHolderView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:self
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.superHolderView
                                         attribute:NSLayoutAttributeLeading
                                         multiplier:1
                                         constant:0]];
    
    [self.superHolderView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:self
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.superHolderView
                                         attribute:NSLayoutAttributeTrailing
                                         multiplier:1
                                         constant:0]];
    
    [self.superHolderView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:self
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.superHolderView
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1
                                         constant:0]];
    
    [self.superHolderView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:self
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.superHolderView
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1
                                         constant:0]];
}

- (IBAction)clickNearbyVenuesButton:(id)sender {
    [MobClickUtils event:umeng_event_click_nearby_bussiness];
    if([_delegate respondsToSelector:@selector(didClickNearbyVenuesViewButton)]){
        [_delegate didClickNearbyVenuesViewButton];
    }
    
}

- (void)updateView{
    
    //存储id
    self.nearbyBusinessId = _nearbyVenues.businessId;
    
    //名称
    self.venuesNameLabel.text = _nearbyVenues.name;
    
    //商圈，距离
    CLLocation *sourceLocation = [[CLLocation alloc] initWithLatitude:self.currentBusiness.latitude longitude:self.currentBusiness.longitude];
    CLLocation *distanceLocation = [[CLLocation alloc] initWithLatitude:_nearbyVenues.latitude longitude:_nearbyVenues.longitude];
    NSString *distance = [distanceLocation distanceStringValueFromLocation:sourceLocation];
    if(distance.length <= 0){
        distance = @"距离未知";//避免出现null
    }
    if(_nearbyVenues.neighborhood.length > 0) {
        self.venuesSubTitleLabel.text = [NSString stringWithFormat:@"[%@] 距离当前球馆%@",_nearbyVenues.neighborhood, distance];
    }else {
        self.venuesSubTitleLabel.text = [NSString stringWithFormat:@"距离当前球馆%@", distance];
    }
    
    //价格
    if(_nearbyVenues.promotePrice > 0) {
        self.venuesPriceLabel.text = [NSString stringWithFormat:@"¥%.0f", _nearbyVenues.price];
        self.venuesPromotePriceLabel.text = [NSString stringWithFormat:@"%.0f", _nearbyVenues.promotePrice];
    }else {
        self.venuesPriceLabel.hidden = YES;
        self.promotePriceImageView.hidden = YES;
        self.venuesPromotePriceLabel.text = [NSString stringWithFormat:@"%.0f", _nearbyVenues.price];
    }
    
    
    //图片
    NSURL *url = [NSURL URLWithString:_nearbyVenues.imageUrl];
    [self.venuesImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_image_sq"]];
    
    if(_nearbyVenues.businessId.length > 0) {
        [MobClickUtils event:umeng_event_show_nearby_bussiness];
        [UIView animateWithDuration:0.1 animations:^{
            self.nearbyVenuesHolderView.alpha = 1.0;
        }];
    }else {
        [self.nearbyVenuesHolderView removeFromSuperview];
    }
}


@end
