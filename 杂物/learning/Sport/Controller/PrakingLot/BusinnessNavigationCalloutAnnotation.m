//
//  BusinnessNavigationCalloutAnnotation.m
//  Sport
//
//  Created by xiaoyang on 15/12/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "BusinnessNavigationCalloutAnnotation.h"
#import "Business.h"


@interface BusinessNavigationCalloutAnnotation()

 @property (copy, nonatomic) NSString *customTile;
 @property (copy, nonatomic) NSString *customSubtitle;

 @end
 

@implementation BusinessNavigationCalloutAnnotation

@synthesize coordinate;
@synthesize customTile = _customTile;
@synthesize customSubtitle = _customSubtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
                   title:(NSString *)title
                subtitle:(NSString *)subtitle
{
    self = [super init];
    if (self) {
        coordinate.longitude = coord.longitude;
        coordinate.latitude = coord.latitude;
        self.customTile = title;
        self.customSubtitle = subtitle;
    }
    
    return self;
}

- (NSString *)title
{
    return _customTile;
}

- (NSString *)subtitle
{
    return _customSubtitle;
}

@end
