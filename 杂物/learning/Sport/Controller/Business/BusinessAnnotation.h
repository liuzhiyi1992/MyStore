//
//  BusinessAnnotation.h
//  Sport
//
//  Created by haodong  on 13-8-25.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Business;

@interface BusinessAnnotation : NSObject<MKAnnotation>

@property (strong, nonatomic) Business *business;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
                   title:(NSString *)title
                subtitle:(NSString *)subtitle;

- (NSString *)title;

- (NSString *)subtitle;

@end
