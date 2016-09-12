//
//  SportLocationManager.m
//  Sport
//
//  Created by lzy on 16/5/24.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportLocationManager.h"
#import <UIKit/UIKit.h>

static SportLocationManager *_mkLocationManager = nil;
CGFloat const QUERY_LOCATION_RETRY_DELAY = 1;

@interface SportLocationManager() <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) CLLocationManager *clLocationManager;
@property (strong, nonatomic) NSMutableDictionary *locationCompleteDictionary;
@property (strong, nonatomic) NSMutableDictionary *cityCompleteDictionary;
- (void)queryMapLocation;
@end

const void(^authorityBlock)(NSError *, id<UIAlertViewDelegate>) = ^(NSError *error, id<UIAlertViewDelegate> alertViewDelegate){
    if (error) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status != kCLAuthorizationStatusAuthorized) {
            if (alertViewDelegate != nil) {
                //无权限
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"打开定位权限以使用更多的功能" delegate:alertViewDelegate cancelButtonTitle:@"拒绝" otherButtonTitles:@"好的", nil];
                [alert show];
            }
            //业务处可跳转应用权限页
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            //有权限 && sponsor未被释放前，间隔1秒重试一次
            if (alertViewDelegate) {
                NSLog(@"Ready to try again for positioning");
                [[SportLocationManager shareManager] performSelector:@selector(queryMapLocation) withObject:nil afterDelay:QUERY_LOCATION_RETRY_DELAY];
            }
        }
    }
};


@implementation SportLocationManager

+ (SportLocationManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mkLocationManager = [[SportLocationManager alloc] init];
    });
    return _mkLocationManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self startLocation];
    }
    return self;
}

- (NSMutableDictionary *)cityCompleteDictionary {
    if (nil == _cityCompleteDictionary) {
        _cityCompleteDictionary = [NSMutableDictionary dictionary];
    }
    return _cityCompleteDictionary;
}

- (NSMutableDictionary *)locationCompleteDictionary {
    if (nil == _locationCompleteDictionary) {
        _locationCompleteDictionary = [NSMutableDictionary dictionary];
    }
    return _locationCompleteDictionary;
}

- (void)startLocation {
    _clLocationManager = [[CLLocationManager alloc] init];
    _clLocationManager.delegate = self;
    _clLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([_clLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_clLocationManager requestWhenInUseAuthorization];
    }
}

- (void)getLocationCoordinate:(id)sponsor complete:(LocationCompleteBlock)completeBlock {
    [self.locationCompleteDictionary setObject:completeBlock forKey:[sponsor description]];
    [self queryMapLocation];
}

- (void)getCity:(id)sponsor complete:(CityCompleteBlock)completeBlock {
    [self.cityCompleteDictionary setObject:completeBlock forKey:sponsor];
    [self queryMapLocation];
}

//单次请求地理位置
- (void)queryMapLocation {
    if (_mapView != nil) {
        self.mapView = nil;
    }
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _mapView.delegate = self;
    [_mapView setShowsUserLocation:YES];
    [[UIApplication sharedApplication].keyWindow addSubview:_mapView];
}

- (void)stopMapLocation {
    [_mapView setShowsUserLocation:NO];
    [_mapView removeFromSuperview];
    self.mapView = nil;
}

- (void)removeObject:(id)object FromDict:(NSMutableDictionary *)dict {
    [dict removeObjectsForKeys:[dict allKeysForObject:object]];
}

- (BOOL)isNoAuthorityError:(NSError *)error {
    if (error) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status != kCLAuthorizationStatusAuthorized) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
            break;
        case kCLAuthorizationStatusNotDetermined:
            if ([_clLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_clLocationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusRestricted:
            if ([_clLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_clLocationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
        default:
            break;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //这里考虑做location的归档
    //todo CLGeocoder解析坐标
    [self stopMapLocation];
    CLLocationCoordinate2D coordinate2D = userLocation.location.coordinate;
    for (LocationCompleteBlock locationCompleteBlock in [_locationCompleteDictionary allValues]) {
        if (locationCompleteBlock) {
            locationCompleteBlock(coordinate2D, nil);
            [self removeObject:locationCompleteBlock FromDict:_locationCompleteDictionary];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    //无权限错误，删Block, 不重试, 等业务重新请求
    //有权限错误，不删Block，重试(发起者释放前), 成功则删除Block
    [self stopMapLocation];
    BOOL isNoAuthority = [self isNoAuthorityError:error];
    //location
    for (LocationCompleteBlock locationCompleteBlock in [_locationCompleteDictionary allValues]) {
        if (locationCompleteBlock) {
            locationCompleteBlock(kCLLocationCoordinate2DInvalid, error);
            if (isNoAuthority) {
                [self removeObject:locationCompleteBlock FromDict:_locationCompleteDictionary];
            }
        }
    }
    //city
    for (CityCompleteBlock cityCompleteBlock in [_cityCompleteDictionary allValues]) {
        if (cityCompleteBlock) {
            cityCompleteBlock(nil, kCLLocationCoordinate2DInvalid , error);
            if (isNoAuthority) {
                [self removeObject:cityCompleteBlock FromDict:_cityCompleteDictionary];
            }
        }
    }
    //retry query location
    if (!isNoAuthority) {
        //有权限
        [self performSelector:@selector(queryMapLocation) withObject:nil afterDelay:QUERY_LOCATION_RETRY_DELAY];
    }
}

@end
