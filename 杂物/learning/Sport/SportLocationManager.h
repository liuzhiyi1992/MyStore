//
//  SportLocationManager.h
//  Sport
//
//  Created by lzy on 16/5/24.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


typedef void (^LocationCompleteBlock)(CLLocationCoordinate2D location, NSError *error);
typedef void (^CityCompleteBlock)(NSString *city, CLLocationCoordinate2D location, NSError *error);

extern const void(^authorityBlock)(NSError *, id<UIAlertViewDelegate>);

@interface SportLocationManager : NSObject
@property (strong, nonatomic) MKMapView *mapView;
@property (assign, nonatomic) CLLocationCoordinate2D lastCoordinate;
@property(assign, nonatomic)float latitude;
@property(assign, nonatomic)float longitude;

+ (SportLocationManager *)shareManager;
- (void)getLocationCoordinate:(id)sponsor complete:(LocationCompleteBlock)completeBlock;
- (void)getCity:(id)sponsor complete:(CityCompleteBlock)completeBlock;
@end
