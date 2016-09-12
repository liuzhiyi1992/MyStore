//
//  SuggestCityAlertManager.m
//  Sport
//
//  Created by qiuhaodong on 16/6/21.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SuggestCityAlertManager.h"
#import "SportLocationManager.h"
#import "UserManager.h"
#import "AppGlobalDataManager.h"
#import "CityManager.h"
#import "City.h"

@interface SuggestCityAlertManager()<CityManagerDelegate>
@property(assign, nonatomic) BOOL isDidFoundUserLocation;
@property(strong, nonatomic) CLLocation *recordedLocation;
@end


@implementation SuggestCityAlertManager

static SuggestCityAlertManager *_suggestCityAlertManager = nil;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _suggestCityAlertManager = [[SuggestCityAlertManager alloc] init];
    });
    return _suggestCityAlertManager;
}

- (void)startSearchSuggestCity {
    __weak __typeof(self) weakSelf = self;
    [[SportLocationManager shareManager] getLocationCoordinate:weakSelf complete:^(CLLocationCoordinate2D coordinate, NSError *error) {
        
        if (error == nil) {
            CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            
            //记录当前定位的条件：1.第一次定位；2.比上次定位距离超过300米
            if (weakSelf.recordedLocation == nil
                || [weakSelf.recordedLocation distanceFromLocation:userLocation] > 300) {
                HDLog(@"1");
                weakSelf.recordedLocation = userLocation;
                [[UserManager defaultManager] saveUserLocation:userLocation];
            }
            
            //在应用启动的生命周期内只提示一次
            if (self.isDidFoundUserLocation == NO
                && [[AppGlobalDataManager defaultManager] isShowingBootPage] == NO
                && [[AppGlobalDataManager defaultManager] isShowingCityListView] == NO) {
                
                self.isDidFoundUserLocation = YES;
                [[CityManager defaultManager] queryLocationCityName:self
                                                           latitude:userLocation.coordinate.latitude  //23.05 //test data
                                                          longitude:userLocation.coordinate.longitude]; //114.22 //test data
            }
        }
    }];
}

#define TAG_CHANGE_CITY_ALERTVIEW 2016062101
- (void)didQueryLocationCityName:(NSString *)cityName
                        latitude:(double)latitude
                       longitude:(double)longitude {
    
    City *equalCity = nil;
    for (City *city in [[CityManager defaultManager] cityList]) {
        if ([city.cityName isEqualToString:cityName]) {
            equalCity = city;
            break;
        }
    }
    
    if (equalCity) {
        [[CityManager defaultManager] setSuggestCity:equalCity];
    }
    
    //找到匹配城市，并且与当前选择城市不一致
    if (equalCity &&
        [equalCity.cityId isEqualToString:[CityManager readCurrentCityId]] == NO) {
        
        //提示换到equalCity城市
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"你所在城市是%@,建议你切换到%@", equalCity.cityName, equalCity.cityName]
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_CHANGE_CITY_ALERTVIEW;
        [alertView show];
        
    }
    
    //找不到匹配城市再计算距离
    else if (equalCity == nil) {
        //用经纬度对比，计算最近城市
        
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude] ;
        CLLocationDistance minDistance = 0;
        City *minDistanceCity = nil;
        
        int index = 0;
        for (City *city in [[CityManager defaultManager] cityList]) {
            CLLocation *cityLocation = [[CLLocation alloc] initWithLatitude:city.latitude longitude:city.longitude];
            CLLocationDistance distance = [cityLocation distanceFromLocation:currentLocation];
            if (index == 0) {
                minDistance = distance;
                minDistanceCity = city;
            } else if (distance < minDistance){
                minDistance = distance;
                minDistanceCity = city;
            }
            
            index ++;
        }
        
        if (minDistanceCity) {
            [[CityManager defaultManager] setSuggestCity:minDistanceCity];
        }
        
        //如果计算得出的最新城市和当前选择的城市不一致，则弹出提示
        if (minDistanceCity &&
            [minDistanceCity.cityId isEqualToString:[CityManager readCurrentCityId]] == NO) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[NSString stringWithFormat:@"离你最近的城市是%@,建议你切换到%@", minDistanceCity.cityName, minDistanceCity.cityName]
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_CHANGE_CITY_ALERTVIEW;
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_CHANGE_CITY_ALERTVIEW) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            City *city = [[CityManager defaultManager] suggestCity];
            
            [CityManager saveCurrentCity:city];
        }
    }
}

@end
