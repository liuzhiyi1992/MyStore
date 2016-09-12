//
//  BusinnessNavigationCalloutAnnotation.h
//  Sport
//
//  Created by xiaoyang on 15/12/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class Business;

@interface BusinessNavigationCalloutAnnotation : NSObject<MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
                   title:(NSString *)title
                subtitle:(NSString *)subtitle;

@end
