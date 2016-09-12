//
//  DropDownDataManager.h
//  Sport
//
//  Created by qiuhaodong on 16/2/24.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropDownData.h"

#define SORT_ID_RECOMMEND              @"0"
#define SORT_ID_NEAR_TO_FAR            @"1"
#define SORT_ID_PRICE_LOW_TO_HIGH      @"3"
#define SORT_ID_PRICE_HIGH_TO_LOW      @"4"
#define SORT_ID_HEAT_HIGH_TO_LOW       @"5"

#define SORT_NAME_RECOMMEND             @"推荐排序"
#define SORT_NAME_NEAR_TO_FAR          @"距离最近"
#define SORT_NAME_PRICE_LOW_TO_HIGH    @"价格最低"
#define SORT_NAME_PRICE_HIGH_TO_LOW    @"价格最高"
#define SORT_NAME_HEAT_HIGH_TO_LOW     @"人气最高"

#define FILTRATE_ID_ALL                @""
#define FILTRATE_ID_ACT_CLUB           @"1"
#define FILTRATE_ID_CAN_ORDER          @"2"
#define FILTRATE_ID_INDOOR             @"3"
#define FILTRATE_ID_OUTDOOR            @"4"

#define FILTRATE_NAME_ALL              @"全部场馆"
#define FILTRATE_NAME_ACT_CLUB         @"支持动Club"
#define FILTRATE_NAME_CAN_ORDER        @"支持预订"
#define FILTRATE_NAME_INDOOR           @"室内场"
#define FILTRATE_NAME_OUTDOOR          @"室外场"

#define PEOPLE_NUMBER_ALL              @""

#define LEFT_TITLE_CATEGORY @"运动项目"
#define LEFT_TITLE_REGION   @"区域范围"
#define LEFT_TITLE_FILTRATE @"场馆筛选"
#define LEFT_TITLE_SORT     @"排序方式"


@interface DropDownDataManager : NSObject

@property (strong, nonatomic) NSArray *categoryDropDownDataList;
@property (strong, nonatomic) NSArray *regionDropDownDataList;
@property (strong, nonatomic) NSArray *sortDropDownDataList;

+ (DropDownDataManager *)defaultManager;

+ (BOOL)isShowIndoorOutdoorWithCategoryId:(NSString *)categoryId;

- (NSArray *)filterDropDownDataListWithCategoryId:(NSString *)categoryId;

- (NSString *)categoryNameWithId:(NSString *)categoryId;
- (NSString *)regionNameWithId:(NSString *)regionId;
- (NSString *)filterNameWithId:(NSString *)filterId;
- (NSString *)sortNameWithId:(NSString *)sortId;

- (NSString *)categoryIdWithName:(NSString *)categoryName;
- (NSString *)regionIdWithName:(NSString *)regionName;
- (NSString *)filterIdWithName:(NSString *)filterName;
- (NSString *)sortIdWithName:(NSString *)sortName;

//因为筛选场馆只需要在足球，篮球，网球等有室外室内的场地使用，故左右dataList都在这里返回
- (NSArray *)leftAndRightDataListWithCategoryId:(NSString *)categoryId;
@end
