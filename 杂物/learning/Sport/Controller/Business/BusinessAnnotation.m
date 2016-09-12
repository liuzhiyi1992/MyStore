//
//  BusinessAnnotation.m
//  Sport
//
//  Created by haodong  on 13-8-25.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessAnnotation.h"
#import "Business.h"

@interface BusinessAnnotation()

@property (copy, nonatomic) NSString *customTile;
@property (copy, nonatomic) NSString *customSubtitle;

@end

@implementation BusinessAnnotation

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
