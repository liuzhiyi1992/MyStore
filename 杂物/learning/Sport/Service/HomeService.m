//
//  HomeService.m
//  Sport
//
//  Created by haodong  on 14-5-4.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "HomeService.h"
#import "SportNetwork.h"
#import "SportAd.h"
#import "Business.h"
#import "User.h"
#import "BusinessManager.h"
#import "BusinessCategory.h"
#import "BusinessCategoryManager.h"
#import "MonthCardCourse.h"
#import "FastOrderEntrance.h"
#import "Product.h"

@implementation HomeService

+ (void)queryHomePage:(id<HomeServiceDelegate>)delegate
               userId:(NSString *)userId
               cityId:(NSString *)cityId
            longitude:(NSString *)longitude
             latitude:(NSString *)latitude
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_INDEX forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        [inputDic setValue:longitude forKey:PARA_LONGITUDE];
        [inputDic setValue:latitude forKey:PARA_LATITUDE];
        
        //2015-02-02添加版本1.1，因为新旧版本的banner高度不一致
        //2015-04-02添加版本1.2，banner的连接添加新的url规则,例如：gosport://business_detail?
        [inputDic setValue:@"1.7" forKey:PARA_VER];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        
        NSMutableArray *adList = [NSMutableArray array];
        NSMutableArray *businessList = [NSMutableArray array];
        NSMutableArray *categoryList = [NSMutableArray array];
        NSMutableArray *MonthCardCategoryList = [NSMutableArray array];
        NSMutableArray *courseList = [NSMutableArray array];
        NSString *hasMoreCourse = @"";
        
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if (data) {
            
            //广告
            NSArray *list1 = [data validArrayValueForKey:PARA_AD_LIST];
            for (id one in list1) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                SportAd *ad = [[SportAd alloc] init] ;
                ad.adId = [one validStringValueForKey:PARA_AD_ID];
                ad.adLink = [one validStringValueForKey:PARA_AD_LINK];
                ad.adName = [one validStringValueForKey:PARA_AD_NAME];
                ad.imageUrl = [one validStringValueForKey:PARA_IMAGE_URL];
                
                [adList addObject:ad];
            }
            
            //场馆
            NSArray *list2 = [data validArrayValueForKey:PARA_VENUE_LIST];
            for (id one in list2) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                Business *business = [BusinessManager businessByOneBusinessJson:one];
                [businessList addObject:business];
            }
            
            //运动项目
            NSArray *list3 = [data validArrayValueForKey:PARA_CATEGORIES];
            for (id one in list3) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                BusinessCategory *category = [[BusinessCategory alloc] init] ;
                category.businessCategoryId  = [(NSDictionary *)one validStringValueForKey:PARA_CATEGORY_ID];
                category.name = [(NSDictionary *)one validStringValueForKey:PARA_CATEGORY_NAME];
                category.imageUrl = [(NSDictionary *)one validStringValueForKey:PARA_IMAGE_URL];
                category.activeImageUrl = [(NSDictionary *)one validStringValueForKey:PARA_ACTIVE_IMAGE_URL];
                category.smallImageUrl = [(NSDictionary *)one validStringValueForKey:PARA_SMALL_IMAGE_URL];
                category.isSupportClub = [(NSDictionary *)one validBoolValueForKey:PARA_IS_SUPPORT_CLUB];
                category.iconUrl = [(NSDictionary *)one validStringValueForKey:PARA_ICON_URL];
                [categoryList addObject:category];
            }
            [[BusinessCategoryManager defaultManager] setCurrentAllCategories:categoryList];
            
            
            //推荐课程列表
            NSArray *list5 = [data validArrayValueForKey:PARA_RECOMMEND_COURSE_LIST];
            for (id one in list5) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                MonthCardCourse *course = [[MonthCardCourse alloc] init];
                course.courseId = [(NSDictionary *)one validStringValueForKey:PARA_COURSE_ID];
                
                course.courseName = [(NSDictionary *)one validStringValueForKey:PARA_COURSE_NAME];
                course.venuesName = [(NSDictionary *)one validStringValueForKey:PARA_VENUES_NAME];
                course.imageUrl = [(NSDictionary *)one validStringValueForKey:PARA_IMAGE_URL];
                
                course.startTime = [(NSDictionary *)one validDateValueForKey:PARA_START_TIME];
                course.endTime = [(NSDictionary *)one validDateValueForKey:PARA_END_TIME];
                
                course.isRecommend = [(NSDictionary *)one validBoolValueForKey:PARA_IS_RECOMMEND];
                course.courseUrl = [(NSDictionary *)one validStringValueForKey:PARA_COURSE_URL];
                [courseList addObject:course];
            }
            
            hasMoreCourse = [data validStringValueForKey:PARA_HAS_MORE_COURSE];
            
            NSArray *list4 = [data validArrayValueForKey:PARA_MONCARD_CATEGORIES];
            for (id one in list4) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                BusinessCategory *category = [[BusinessCategory alloc] init] ;
                category.businessCategoryId  = [(NSDictionary *)one validStringValueForKey:PARA_CATEGORY_ID];
                category.name = [(NSDictionary *)one validStringValueForKey:PARA_CATEGORY_NAME];
                category.imageUrl = [(NSDictionary *)one validStringValueForKey:PARA_IMAGE_URL];
                category.activeImageUrl = [(NSDictionary *)one validStringValueForKey:PARA_ACTIVE_IMAGE_URL];
                category.smallImageUrl = [(NSDictionary *)one validStringValueForKey:PARA_SMALL_IMAGE_URL];
                
                [MonthCardCategoryList addObject:category];
            }
            
            [[BusinessCategoryManager defaultManager] setMonthCardAllCategories:MonthCardCategoryList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryHomePage:msg:adList:businessList:categoryList:courseList:hasMoreCourse:)]) {
                [delegate didQueryHomePage:status
                                       msg:msg
                                    adList:adList
                              businessList:businessList
                              categoryList:categoryList
                                courseList:courseList
                             hasMoreCourse:hasMoreCourse];
            }
        });
    });
}

+ (void)queryUserIndex:(id<HomeServiceDelegate>)delegate
                  page:(int)page
                 count:(int)count
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_INDEX_USER forKey:PARA_ACTION];
        [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
        [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        NSMutableArray *userList = [NSMutableArray array];
        
        NSArray *sourceList = [resultDictionary validArrayValueForKey:PARA_DATA];
        for (id one in sourceList) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            User *user = [[User alloc] init] ;
            user.userId = [one validStringValueForKey:PARA_USER_ID];
            user.nickname = [one validStringValueForKey:PARA_NICK_NAME];
            user.avatarUrl = [one validStringValueForKey:PARA_AVATAR];
            [userList addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryUserIndex:userList:)]) {
                [delegate didQueryUserIndex:status userList:userList];
            }
        });
    });
}

+ (void)queryHomeVenueList:(id<HomeServiceDelegate>)delegate
                    userID:(NSString *)userID
                    cityID:(NSString *)cityID
                       ver:(NSString *)ver
                 longitude:(NSString *)longitude
                  latitude:(NSString *)latitude
                      page:(int)page
                     count:(NSString *)count{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_INDEX_VENUE_LIST forKey:PARA_ACTION];
        [inputDic setValue:userID forKey:PARA_USER_ID];
        [inputDic setValue:cityID forKey:PARA_CITY_ID];
        [inputDic setValue:longitude forKey:PARA_LONGITUDE];
        [inputDic setValue:latitude forKey:PARA_LATITUDE];
        [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
        [inputDic setValue:count forKey:PARA_COUNT];
        
        //2015-02-02添加版本1.1，因为新旧版本的banner高度不一致
        //2015-04-02添加版本1.2，banner的连接添加新的url规则,例如：gosport://business_detail?
        [inputDic setValue:ver forKey:PARA_VER];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAUL_VENUE];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSMutableArray *businessList = [NSMutableArray array];
        NSArray *data = [resultDictionary validArrayValueForKey:PARA_DATA];
        
        if (data) {
            for (id one in data) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                Business *business = [BusinessManager businessByOneBusinessJson:one];
                [businessList addObject:business];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryHomeVenueList:msg:page:businessList:)]) {
                [delegate didQueryHomeVenueList:status msg:msg page:page businessList:businessList];
            }
        });
    });
}

+ (void)queryQuickBookInfo:(id<HomeServiceDelegate>)delegate
                    userId:(NSString *)userId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_QUICK_BOOK forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAUL_VENUE];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        FastOrderEntrance *entrance = nil;
        
        if (data.count != 0) {
            entrance = [[FastOrderEntrance alloc]init];
            entrance.businessName = [data validStringValueForKey:PARA_NAME];
            entrance.businessId = [data validStringValueForKey:PARA_BUSINESS_ID];
            entrance.categoryId = [data validStringValueForKey:PARA_CATEGORY_ID];
            entrance.categoryName = [data validStringValueForKey:PARA_CATEGORY_NAME];
            entrance.iconUrl = [data validStringValueForKey:PARA_ICON_URL];
            entrance.bookDate = [data validDateValueForKey:PARA_BOOK_DATE];
            entrance.detailTimeString = [data validStringValueForKey:PARA_TIME];
            
            NSMutableArray *goodsList = [NSMutableArray array];
            
            NSArray *sourceList = [data validArrayValueForKey:PARA_GOODS_LIST];
            for (id one in sourceList) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                
                Product *product = [[Product alloc]init];
                product.productId = [one validStringValueForKey:PARA_GOODS_ID];
                product.courtId = [one validStringValueForKey:PARA_COURT_ID];
                product.courtName = [one validStringValueForKey:PARA_COURT_NAME];
                product.price = [one validFloatValueForKey:PARA_PRICE];
                product.startTime = [one validStringValueForKey:PARA_START_TIME];
                
                [goodsList addObject:product];
            }
            
            entrance.goodsList = goodsList;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryQuickBookInfo:entrance:)]) {
                [delegate didQueryQuickBookInfo:status entrance:entrance];
            }
        });
    });
}



@end
