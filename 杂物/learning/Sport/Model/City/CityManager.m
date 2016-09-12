//
//  CityManager.m
//  Sport
//
//  Created by haodong  on 13-8-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "CityManager.h"
#import "City.h"
#import "Region.h"
#import <CoreLocation/CoreLocation.h>

#define DEFAULT_CITY_ID     @"76"
#define DEFAULT_CITY_NAME   @"广州"

#define KEY_CURRENT_CITY_ID     @"KEY_CURRENT_CITY_ID"
#define KEY_CURRENT_CITY_NAME   @"KEY_CURRENT_CITY_NAME"

static CityManager *_globalCityManager = nil;

@implementation CityManager

+ (CityManager *)defaultManager
{
    if (_globalCityManager == nil) {
        _globalCityManager = [[CityManager alloc] init];
    }
    return _globalCityManager;
}

- (NSString *)regionName:(NSString *)regionId cityId:(NSString *)cityId
{
    if ([regionId isEqualToString:REGION_ID_ALL]) {
        return REGION_NAME_ALL;
    }
    
    if ([regionId isEqualToString:MONTHCARD_REGION_ID_ALL]) {
        return MONTHCARD_REGION_NAME_ALL;
    }
    
    
    City *city = nil;
    for (City *oneCity in _cityList) {
        if ([cityId isEqualToString:oneCity.cityId]) {
            city = oneCity;
            break;
        }
    }
    for (Region *region in city.regionList) {
        if ([regionId isEqualToString:region.regionId]) {
            return region.regionName;
        }
    }
    return nil;
}

#pragma mark - 私有
+ (BOOL)saveCurrentCityName:(NSString *)cityName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:cityName forKey:KEY_CURRENT_CITY_NAME];
    return [defaults synchronize];
}

+ (BOOL)saveCurrentCityId:(NSString *)cityId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:cityId forKey:KEY_CURRENT_CITY_ID];
    return [defaults synchronize];
}

#pragma mark -
+ (City *)readCurrentCity {
    for (City *city in [CityManager defaultManager].cityList) {
        if ([city.cityId isEqualToString:[CityManager readCurrentCityId]]) {
            return city;
        }
    }
    
    //如果找不到，则默认创建一个
    City *city = [[City alloc] init];
    city.cityId = [self readCurrentCityId];
    city.cityName = [self readCurrentCityName];
    return city;
}

+ (void)saveCurrentCity:(City *)city
{
    NSString *oldCityId = [self readCurrentCityId];
    
    [self saveCurrentCityId:city.cityId];
    [self saveCurrentCityName:city.cityName];
    
    if (![oldCityId isEqualToString:city.cityId]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_DID_CHANGE_CITY object:nil userInfo:nil];
    }
}

+ (NSString *)readCurrentCityId
{
    NSString *cityId = [self readRealCurrentCityId];
    if (cityId == nil) {
        cityId = DEFAULT_CITY_ID;
    }
    return cityId;
}

+ (NSString *)readRealCurrentCityId
{
    NSString *cityId = [[NSUserDefaults standardUserDefaults] valueForKey:KEY_CURRENT_CITY_ID];
    return cityId;
}

+ (NSString *)readCurrentCityName
{
    NSString *cityName = [[NSUserDefaults standardUserDefaults] valueForKey:KEY_CURRENT_CITY_NAME];
    if (cityName == nil) {
        cityName = DEFAULT_CITY_NAME;
    }
    return cityName;
}

- (void)queryLocationCityName:(id<CityManagerDelegate>)delegate
                     latitude:(double)latitude
                    longitude:(double)longitude
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSMutableString *address = [NSMutableString stringWithString:@""];
            if (placemark.locality) {
                [address appendString:placemark.locality];
            }
            if (placemark.subLocality) {
                [address appendString:placemark.subLocality];
            }
            if (placemark.thoroughfare) {
                [address appendString:placemark.thoroughfare];
            }
            if (placemark.subThoroughfare) {
                [address appendString:placemark.subThoroughfare];
            }
            
            NSString *cityName = nil;
            cityName = [placemark.locality stringByReplacingOccurrencesOfString:@"市" withString:@""];

            HDLog(@"您当前所在位置:%@",address);
            /*
             HDLog(@"name:%@", placemark.name);
             HDLog(@"thoroughfare:%@", placemark.thoroughfare);
             HDLog(@"subThoroughfare:%@", placemark.subThoroughfare);
             HDLog(@"locality:%@", placemark.locality);
             HDLog(@"subLocality:%@", placemark.subLocality);
             HDLog(@"administrativeArea:%@", placemark.administrativeArea);
             HDLog(@"subAdministrativeArea:%@", placemark.subAdministrativeArea);
             HDLog(@"postalCode:%@", placemark.postalCode);
             HDLog(@"ISOcountryCode:%@", placemark.ISOcountryCode);
             HDLog(@"country:%@", placemark.country);
             HDLog(@"inlandWater:%@", placemark.inlandWater);
             HDLog(@"ocean:%@", placemark.ocean);
             HDLog(@"areasOfInterest:%@", placemark.areasOfInterest);
             */
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([delegate respondsToSelector:@selector(didQueryLocationCityName:latitude:longitude:)]) {
                    [delegate didQueryLocationCityName:cityName latitude:latitude longitude:longitude];
                }
                
            });
        }];
    });
}

@end
