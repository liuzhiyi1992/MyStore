//
//  BusinessCalloutAnnotation.m
//  Sport
//
//  Created by haodong  on 14-7-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BusinessCalloutAnnotation.h"
#import "Business.h"

@implementation BusinessCalloutAnnotation
@synthesize coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
{
    self = [super init];
    if (self) {
        coordinate.longitude = coord.longitude;
        coordinate.latitude = coord.latitude;
    }
    
    return self;
}

@end
