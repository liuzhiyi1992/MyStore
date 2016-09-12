//
//  DropDownDataManager.m
//  Sport
//
//  Created by qiuhaodong on 16/2/24.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DropDownDataManager.h"
#import "BusinessCategoryManager.h"
#import "BusinessCategory.h"
#import "CityManager.h"
#import "City.h"
#import "Region.h"

@interface DropDownDataManager()

@property (strong, nonatomic) NSArray *filterDropDownDataList;

@end

static DropDownDataManager *_globalDropDownDataManager = nil;

@implementation DropDownDataManager

+ (DropDownDataManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalDropDownDataManager == nil) {
            _globalDropDownDataManager = [[DropDownDataManager alloc] init];
            
            [_globalDropDownDataManager initStaticData];
        }
    });
    [_globalDropDownDataManager initDynamicData];
    return _globalDropDownDataManager;
}

- (void)initDynamicData {
    //项目
    NSMutableArray *categoryArray = [NSMutableArray array];
    for (BusinessCategory *c in [[BusinessCategoryManager defaultManager] currentAllCategories]) {
        DropDownData *data = [DropDownData createDataWithIdString:c.businessCategoryId
                                                            value:c.name
                                                          iconUrl:c.iconUrl];
        [categoryArray addObject:data];
    }
    self.categoryDropDownDataList = categoryArray;
    
    
    //区域
    DropDownData *firstData = [[DropDownData alloc] init];
    firstData.idString = REGION_ID_ALL;
    firstData.value = REGION_NAME_ALL;
    NSMutableArray *regionArray = [NSMutableArray arrayWithObjects:firstData, nil];
    for (Region *r in [CityManager readCurrentCity].regionList) {
        DropDownData *data = [DropDownData createDataWithIdString:r.regionId
                                                            value:r.regionName
                                                          iconUrl:nil];
        [regionArray addObject:data];
    }
    self.regionDropDownDataList = regionArray;
}

- (void)initStaticData {
    //筛选
    NSMutableArray *filterArray = [NSMutableArray array];
    NSArray *filterNameArray = @[FILTRATE_NAME_ALL,
                                 FILTRATE_NAME_INDOOR,
                                 FILTRATE_NAME_OUTDOOR];
    NSArray *filterIdArray = @[FILTRATE_ID_ALL,
                               FILTRATE_ID_INDOOR,
                               FILTRATE_ID_OUTDOOR];
    for (int i = 0 ; i < filterNameArray.count ; i ++) {
        DropDownData *data = [DropDownData createDataWithIdString:filterIdArray[i]
                                                            value:filterNameArray[i]
                                                          iconUrl:nil];
        [filterArray addObject:data];
    }
    self.filterDropDownDataList = filterArray;
    
    
    //排序
    NSMutableArray *sortArray = [NSMutableArray array];
    NSArray *sortNameArray = @[SORT_NAME_NEAR_TO_FAR,
                               SORT_NAME_PRICE_LOW_TO_HIGH,
                               SORT_NAME_PRICE_HIGH_TO_LOW,
                               SORT_NAME_RECOMMEND];
    NSArray *sortIdArray = @[SORT_ID_NEAR_TO_FAR,
                             SORT_ID_PRICE_LOW_TO_HIGH,
                             SORT_ID_PRICE_HIGH_TO_LOW,
                             SORT_ID_RECOMMEND];
    for (int i = 0 ; i < sortNameArray.count ; i ++) {
        DropDownData *data = [DropDownData createDataWithIdString:sortIdArray[i]
                                                            value:sortNameArray[i]
                                                          iconUrl:nil];
        [sortArray addObject:data];
    }
    self.sortDropDownDataList = sortArray;
}

+ (BOOL)isShowIndoorOutdoorWithCategoryId:(NSString *)categoryId
{
    if ([categoryId isEqualToString:@"11"] ||
        [categoryId isEqualToString:@"12"] ||
        [categoryId isEqualToString:@"13"]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSArray *)filterDropDownDataListWithCategoryId:(NSString *)categoryId
{
    if ([DropDownDataManager isShowIndoorOutdoorWithCategoryId:categoryId]) {
        return self.filterDropDownDataList;
    } else {
        NSMutableArray *subList = [NSMutableArray array];
        for (DropDownData *data in self.filterDropDownDataList) {
            if (![data.value isEqualToString:FILTRATE_NAME_INDOOR] &&
                ![data.value isEqualToString:FILTRATE_NAME_OUTDOOR]) {
                [subList addObject:data];
            }
        }
        return subList;
    }
}

- (NSString *)nameWithId:(NSString *)idString list:(NSArray *)list {
    for (DropDownData *d in list) {
        if ([d.idString isEqualToString:idString]) {
            return d.value;
        }
    }
    return nil;
}

- (NSString *)categoryNameWithId:(NSString *)categoryId {
    return [self nameWithId:categoryId list:self.categoryDropDownDataList];
}

- (NSString *)regionNameWithId:(NSString *)regionId {
    return [self nameWithId:regionId list:self.regionDropDownDataList];
}

- (NSString *)filterNameWithId:(NSString *)filterId {
    return [self nameWithId:filterId list:self.filterDropDownDataList];
}

- (NSString *)sortNameWithId:(NSString *)sortId {
    return [self nameWithId:sortId list:self.sortDropDownDataList];
}


- (NSString *)idWithName:(NSString *)name list:(NSArray *)list {
    for (DropDownData *d in list) {
        if ([d.value isEqualToString:name]) {
            return d.idString;
        }
    }
    return nil;
}


- (NSString *)categoryIdWithName:(NSString *)categoryName {
    return [self idWithName:categoryName list:self.categoryDropDownDataList];
}

- (NSString *)regionIdWithName:(NSString *)regionName {
    return [self idWithName:regionName list:self.regionDropDownDataList];
}

- (NSString *)filterIdWithName:(NSString *)filterName {
    return [self idWithName:filterName list:self.filterDropDownDataList];
}

- (NSString *)sortIdWithName:(NSString *)sortName {
    return [self idWithName:sortName list:self.sortDropDownDataList];
}

- (NSArray *)leftAndRightDataListWithCategoryId:(NSString *)categoryId {

    NSArray *leftDataList;
    NSArray *rightDataList;
    if ([DropDownDataManager isShowIndoorOutdoorWithCategoryId:categoryId]) {
        leftDataList = @[LEFT_TITLE_CATEGORY, LEFT_TITLE_REGION,LEFT_TITLE_FILTRATE,LEFT_TITLE_SORT];
        rightDataList = @[self.categoryDropDownDataList, self.regionDropDownDataList, [self filterDropDownDataListWithCategoryId:categoryId], self.sortDropDownDataList];
    } else {
        leftDataList = @[LEFT_TITLE_CATEGORY, LEFT_TITLE_REGION,LEFT_TITLE_SORT];
        rightDataList = @[self.categoryDropDownDataList, self.regionDropDownDataList,self.sortDropDownDataList];
    }
    
    NSArray *leftAndRightDataList = @[leftDataList,rightDataList];
    
    return leftAndRightDataList;
}

@end
