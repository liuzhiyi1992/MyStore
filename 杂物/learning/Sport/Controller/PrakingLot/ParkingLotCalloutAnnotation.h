//
//  ParkingLotCalloutAnnotation.h
//  Sport
//
//  Created by xiaoyang on 15/12/11.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface ParkingLotCalloutAnnotation : NSObject<MKAnnotation>

@property (assign, nonatomic) double distance;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
                   title:(NSString *)title
                subtitle:(NSString *)subtitle;


@end
