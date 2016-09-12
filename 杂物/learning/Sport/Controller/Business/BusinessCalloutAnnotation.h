//
//  BusinessCalloutAnnotation.h
//  Sport
//
//  Created by haodong  on 14-7-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Business;

@interface BusinessCalloutAnnotation : NSObject<MKAnnotation>

@property (strong, nonatomic) Business *business;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
