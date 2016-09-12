//
//  NearbyVenuesView.h
//  Sport
//
//  Created by xiaoyang on 16/1/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessService.h"
#import "SportProgressView.h"
#import "Business.h"
#import "CLLocation+Util.h"
#import "UIImageView+WebCache.h"
#import "BusinessService.h"
#import "UserManager.h"

@protocol NearbyVenuesViewDelegate<NSObject>
@optional
-(void)didClickNearbyVenuesViewButton;

@end

@interface NearbyVenuesView : UIView

+ (NearbyVenuesView *)createNearbyVenuesViewWithBusiness:(Business *)business
                                              categoryId:(NSString *)categoryId
                                                delegate:(id<NearbyVenuesViewDelegate>)delegate
                                            nearbyVenues:(Business *)nearbyVenues
                                           superHolderView:(UIView *)superHoldView;

@end
