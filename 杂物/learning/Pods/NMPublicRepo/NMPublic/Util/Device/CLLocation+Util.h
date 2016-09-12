//
//  CLLocation+Util.h
//  Sport
//
//  Created by qiuhaodong on 15/7/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Util)

- (NSString *)distanceStringValueFromLocation:(CLLocation *)location;

- (BOOL)isValid;

@end
