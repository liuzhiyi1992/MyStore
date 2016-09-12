//
//  FacilityView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacilityView : UIView

+ (FacilityView *)createViewWithFacilityList:(NSArray *)facilityList
                                  businessId:(NSString *)businessId
                                  categoryId:(NSString *)categoryId
                                  controller:(UIViewController *)controller
                             imageTotalCount:(NSUInteger)imageTotalCount;

@end
