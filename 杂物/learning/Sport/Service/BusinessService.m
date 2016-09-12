//
//  BusinessService.m
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessService.h"
#import "BusinessCategory.h"
#import "Business.h"
#import "BusinessCategoryManager.h"
#import "BusinessManager.h"
#import "CommentManager.h"
#import "OtherServiceItem.h"
#import "User.h"
#import "UserManager.h"
#import "BusinessPhoto.h"
#import "Business.h"
#import "DayBookingInfo.h"
#import "ParkingLot.h"
#import "GSNetwork.h"
#import "CourtJoinService.h"
#import "TrafficInfo.h"
#import "GalleryCategory.h"
#import "BusinessGoods.h"


@implementation BusinessService
+ (NSURLSessionTask *)queryBusinesses:(id<BusinessServiceDelegate>)delegate
             categoryId:(NSString *)categoryId
                 cityId:(NSString *)cityId
              region_id:(NSString *)regionId
                   sort:(NSString *)sort
           querySupport:(NSString *)querySupport
               latitude:(double)latitude
              longitude:(double)longitude
                  count:(int)count
                   page:(int)page
                   from:(NSString *)from
              queryDate:(NSString *)queryDate
              queryHour:(NSString *)queryHour
            queryNumber:(NSString *)queryNumber
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [inputDic setValue:user.userId forKey:PARA_USER_ID];
    [inputDic setValue:VALUE_ACTION_GET_BUINESSES forKey:PARA_ACTION];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:regionId forKey:PARA_REGION_ID];
    [inputDic setValue:sort forKey:PARA_SORT];
    [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
    [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:querySupport forKey:PARA_QUERY_SUPPORT];
    [inputDic setValue:queryDate forKey:PARA_QUERY_DATE];
    [inputDic setValue:queryHour forKey:PARA_QUERY_HOUR];
    [inputDic setValue:from forKey:PARA_FROM];
    [inputDic setValue:queryNumber forKey:PARA_QUERY_NUMBER];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    NSURLSessionTask *task = [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSString *canFiltrateTime = [data validStringValueForKey:PARA_CAN_TIME_QUERY];
        NSDictionary *pageInfo = [data validDictionaryValueForKey:PARA_PAGE_DATA];
        NSString *totalNumber = [pageInfo validStringValueForKey:PARA_RECORD_TOTAL];
        NSString *tips = [pageInfo validStringValueForKey:PARA_RECORD_TITLE];
        NSArray *businesses = [BusinessManager businessListByDictionary:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryBusinesses:status:msg:page:canFiltrateTime:totalNumber:tips:)]) {
                [delegate didQueryBusinesses:businesses status:status msg:msg page:page canFiltrateTime:canFiltrateTime totalNumber:totalNumber tips:tips];
            }
        });
    }];
    
    return task;
}

+ (void)searchBusinesses:(id<BusinessServiceDelegate>)delegate
              searchText:(NSString *)searchText
                  cityId:(NSString *)cityId
                   count:(int)count
                    page:(int)page
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SEARCH_BUSINESSES forKey:PARA_ACTION];
    [inputDic setValue:searchText forKey:PRAR_SEARCH_TEXT];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSArray *businesses = [BusinessManager businessListByDictionary:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSearchBusinesses:status:)]) {
                [delegate didSearchBusinesses:businesses status:status];
            }
        });
    }];
}

+ (void)queryBusinessDetail:(id<BusinessServiceDelegate>)delegate
                 businessId:(NSString *)businessId
                 categoryId:(NSString *)categoryId
                     userId:(NSString *)userId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_BUSINESS_INFO forKey:PARA_ACTION];
    [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@"2.1" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        Business *business = [BusinessManager businessByOneBusinessJson:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryBusinessDetail:status:msg:)]) {
                [delegate didQueryBusinessDetail:business status:status msg:msg];
            }
        });
    }];
}

+ (void)queryBookingStatisticsList:(id<BusinessServiceDelegate>)delegate
                        businessId:(NSString *)businessId
                        categoryId:(NSString *)categoryId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_BOOKING_SUM forKey:PARA_ACTION];
    [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        int orderType = 0;
        NSMutableArray *statisticsListlist = [NSMutableArray array];
        NSMutableArray *goodsList = [NSMutableArray array];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            orderType = [data validIntValueForKey:PARA_ORDER_TYPE];
            NSArray *bookLists = [data validArrayValueForKey:PARA_BOOK_LISTS];
            for (id one in bookLists) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                
                if (orderType == BookingTypeTime) {
                    BookingStatistics *statistics = [[BookingStatistics alloc] init] ;
                    statistics.count = [one validIntValueForKey:PARA_SURPLUS_COUNT];
                    statistics.date = [NSDate dateWithTimeIntervalSince1970:[one validIntValueForKey:PARA_BOOK_DATE]];
                    [statisticsListlist addObject:statistics];
                } else if (orderType == BookingTypeSingle) {
                    Goods *goods = [BusinessManager goodsByDictionary:one];
                    [goodsList addObject:goods];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryBookingStatisticsList:status:msg:orderType:goodsList:)]) {
                [delegate didQueryBookingStatisticsList:statisticsListlist status:status msg:msg orderType:orderType goodsList:goodsList];
            }
        });
    }];
}

+ (void)getVenueBookingWithBusinessId:(NSString *)businessId
                           categoryId:(NSString *)categoryId
                                 date:(NSDate *)date
                         courseTypeId:(NSString *)courseTypeId
                          queryNumber:(NSString *)queryNumber
                           completion:(void(^)(NSString *status, NSString *msg, ProductInfo *productInfo, NSArray *dateList, BOOL isCardUser, NSString *tips))completion
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_VENUE_BOOKING_DATE forKey:PARA_ACTION];
    [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [inputDic setValue:dateStr forKey:PARA_BOOK_DATE];
    [inputDic setValue:courseTypeId forKeyPath:PARA_TYPE];
    [inputDic setValue:[[UserManager defaultManager] readCurrentUser].userId forKey:PARA_USER_ID];
    [inputDic setValue:queryNumber forKey:PARA_QUERY_NUMBER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        BOOL isCardUser = NO;
        ProductInfo *productInfo = nil;
        NSMutableArray *dateList = nil;
        NSString *tips = nil;
        NSMutableArray *courtJoinList = nil;
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            isCardUser = [data validBoolValueForKey:PARA_IS_CARD_USER];
            productInfo = [[ProductInfo alloc] init] ;
            dateList = [NSMutableArray array];
            
            //设置dayBookingInfo
            DayBookingInfo *dayBookingInfo = [[DayBookingInfo alloc] init] ;
            dayBookingInfo.date = [data validDateValueForKey:PARA_BOOK_DATE];
            NSMutableArray *courtList = [NSMutableArray array];
            NSArray *goodsList = [data validArrayValueForKey:PARA_GOODS_LIST];
            for (id one in goodsList) {
                if ([one isKindOfClass:[NSDictionary class]] == NO) {
                    continue;
                }
                
                Court *court = [BusinessManager courtByDictionary:one];
                [courtList addObject:court];
            }
            dayBookingInfo.courtList = courtList;
            
            //设置courtJoinList
            courtJoinList = [NSMutableArray array];
            for (id oneCourtJoinSource in [data validArrayValueForKey:PARA_COURT_JOIN_LIST]) {
                if (![oneCourtJoinSource isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                CourtJoin *cj = [CourtJoinService courtJoinByOneCourtJoinDictionary:oneCourtJoinSource];
                [courtJoinList addObject:cj];
                
                //给product的courtJoinId,courtJoinPrice,courtJoinCanBuy赋值
                for (Product *product in cj.productList) {
                    Product *foundProduct = [dayBookingInfo findProductWithProductId:product.productId];
                    foundProduct.courtJoinPrice = product.courtJoinPrice;
                    foundProduct.courtJoinId = cj.courtJoinId;
                    foundProduct.courtJoinCanBuy = cj.available;
                }
            }
            dayBookingInfo.courtJoinlist = courtJoinList;
            
            //设置productInfo
            productInfo.dayBookingInfo = dayBookingInfo;
            productInfo.businessId = [data validStringValueForKey:PARA_BUSINESS_ID];
            productInfo.busienssName = [data validStringValueForKey:PARA_NAME];
            productInfo.categoryId = [data validStringValueForKey:PARA_CATEGORY_ID];
            productInfo.categoryName = [data validStringValueForKey:PARA_CATEGORY_NAME];
            productInfo.address = [data validStringValueForKey:PARA_ADDRESS];
            productInfo.timeList = [data validArrayValueForKey:PARA_HOUR_LIST];
            productInfo.type = [data validIntValueForKey:PARA_ORDER_TYPE];
            productInfo.promoteMessage = [data validStringValueForKey:PARA_PROMOTE_MESSAGE];
            productInfo.minHour = [data validIntValueForKey:PARA_MIN_HOUR];
            
            NSArray *courseTypeSourceList = [data validArrayValueForKey:PARA_COURSE_TYPE];
            NSMutableArray *courseTypeList = [NSMutableArray array];
            int index = 0;
            for (NSDictionary *dic in courseTypeSourceList) {
                CourseType *courseType = [[CourseType alloc] init] ;
                courseType.courseTypeId = [dic validStringValueForKey:PARA_TYPE];
                courseType.courseTypeName = [dic validStringValueForKey:PARA_NAME];
                [courseTypeList addObject:courseType];
                
                if (productInfo.selectedCourseTypeId == nil && index == 0) {
                    productInfo.selectedCourseTypeId = courseType.courseTypeId;
                }
                
                index ++;
            }
            productInfo.courseTypeList = courseTypeList;
            
            //设置dateList
            for (id dateSource in [data validArrayValueForKey:PARA_DATE_LIST]) {
                NSTimeInterval time = [dateSource integerValue];
                NSDate *oneDate = [NSDate dateWithTimeIntervalSince1970:time];
                [dateList addObject:oneDate];
            }
            
            //设置提示
            tips = [data validStringValueForKey:PARA_TIPS];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(status, msg, productInfo, dateList, isCardUser, tips);
            }
        });
    }];
}

+ (void)queryComments:(id<BusinessServiceDelegate>)delegate
           businessId:(NSString *)businessId
               userId:(NSString *)userId
                navId:(NSString *)navId
                count:(int)count
                 page:(int)page
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COMMENTS forKey:PARA_ACTION];
    [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:navId forKey:PARA_NAV_ID];
    
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:@"2.0" forKey:PARA_VER]; //2014-11-05添加，添加有评分的评论
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSArray *reviewList;
        NSArray *categoryList;
        int count = 0;
        double totalRank = 0;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            reviewList = [CommentManager reviewListByDictionary:data];
            count = [data validIntValueForKey:PARA_COMMENT_COUNT];
            categoryList = [data validArrayValueForKey:PARA_NAVIGATION];
            totalRank = [data validDoubleValueForKey:PARA_TOTAL_RANK];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryComments:categoryList:totalCount:totalRank:status:msg:)]) {
                [delegate didQueryComments:reviewList categoryList:categoryList totalCount:count totalRank:totalRank status:status msg:msg];
            }
        });
    }];
}

+ (void)sendComment:(id<BusinessServiceDelegate>)delegate
         businessId:(NSString *)businessId
               text:(NSString *)text
             userId:(NSString *)userId
        commentRank:(int)commentRank
            orderId:(NSString *)orderId
         galleryIds:(NSString *)galleryIds
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_COMMENT forKey:PARA_ACTION];
    [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:text forKey:PARA_CONTENT];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%d", commentRank] forKey:PARA_COMMENT_RANK];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:galleryIds forKey:PARA_GALLERY_IDS];
    [inputDic setValue:@"1.1" forKey:PARA_VER]; //2014-11-06添加，更改为有评分的评论
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        int point = [data validIntValueForKey:PARA_CREDIT];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSendComment:msg:point:text:)]) {
                [delegate didSendComment:status msg:msg point:point text:text];
            }
        });
    }];
}

+ (void)addFavoriteBusiness:(id<BusinessServiceDelegate>)delegate
                 businessId:(NSString *)businessId
                 categoryId:(NSString *)categoryId
                     userId:(NSString *)userId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_FAVORITE forKey:PARA_ACTION];
        [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
        [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        //HDLog(@"<addFavoriteBusiness> %@", resultDictionary);
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didAddFavoriteBusiness:)]) {
                [delegate didAddFavoriteBusiness:status];
            }
        });
    }];
}

+ (void)removeFavoriteBusiness:(id<BusinessServiceDelegate>)delegate
                    businessId:(NSString *)businessId
                    categoryId:(NSString *)categoryId
                        userId:(NSString *)userId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_REMOVE_FAVORITE forKey:PARA_ACTION];
        [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
        [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
       //HDLog(@"<removeFavoriteBusiness> %@", resultDictionary);
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didRemoveFavoriteBusiness:)]) {
                [delegate didRemoveFavoriteBusiness:status];
            }
        });
    }];
}

+ (void)queryFavoriteBusinessList:(id<BusinessServiceDelegate>)delegate
                           userId:(NSString *)userId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_FAVORITE_LIST forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
        //最多返回一百条
        [inputDic setValue:[NSString stringWithFormat:@"%d", 100] forKey:PARA_COUNT];
        [inputDic setValue:[NSString stringWithFormat:@"%d", 1] forKey:PARA_PAGE];
        [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *businesses = [BusinessManager favoriteBusinessListByDictionary:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryFavoriteBusinessList:status:)]) {
                [delegate didQueryFavoriteBusinessList:businesses status:status];
            }
        });
    }];
}

+ (void)callBook:(id<BusinessServiceDelegate>)delegate
           phone:(NSString *)phone
        userName:(NSString *)userName
       startTime:(NSString *)startTime //yyyy-MM-dd HH:mm
         endTime:(NSString *)endTime //yyyy-MM-dd HH:mm
      businessId:(NSString *)bussinessId
      categoryId:(NSString *)categoryId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_ADD_CALL_BOOKING forKey:PARA_ACTION];
    [inputDic setValue:phone forKey:PARA_PHONE];
    [inputDic setValue:userName forKey:PARA_NAME];
    [inputDic setValue:startTime forKey:PARA_START_TIME];
    [inputDic setValue:endTime forKey:PARA_END_TIME];
    [inputDic setValue:bussinessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];

    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCallBook:msg:)]) {
                [delegate didCallBook:status msg:msg];
            }
        });
    }];
}

+ (void)queryMapBusinessList:(id<BusinessServiceDelegate>)delegate
                      cityId:(NSString *)cityId
                  categoryId:(NSString *)categoryId
              centerLatitude:(double)centerLatitude
             centerLongitude:(double)centerLongitude
                 minLatitude:(double)minLatitude
                 maxLatitude:(double)maxLatitude
                minLongitude:(double)minLongitude
                maxLongitude:(double)maxLongitude
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_MAP_BUSINESS_LIST forKey:PARA_ACTION];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%f", minLatitude] forKey:PARA_MIN_LATITUDE];
    [inputDic setValue:[NSString stringWithFormat:@"%f", maxLatitude] forKey:PARA_MAX_LATITUDE];
    [inputDic setValue:[NSString stringWithFormat:@"%f", minLongitude] forKey:PARA_MIN_LONGITUDE];
    [inputDic setValue:[NSString stringWithFormat:@"%f", maxLongitude] forKey:PARA_MAX_LONGITUDE];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSArray *businessList = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            businessList = [BusinessManager mapBusinessListByDictionary:data];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryMapBusinessList:status:msg:centerLatitude:centerLongitude:)]) {
                [delegate didQueryMapBusinessList:businessList status:status msg:msg centerLatitude:centerLatitude centerLongitude:centerLongitude];
            }
        });
    }];
}

+ (void)getBusinesseAllPhoto:(id<BusinessServiceDelegate>)delegate
                 businessId:(NSString *)businessId
                 categoryId:(NSString *)categoryId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_BUSINESSE_ALL_PHOTO forKey:PARA_ACTION];
    [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *photoList = [NSMutableArray array];
        NSMutableArray *photoCategoryList = [NSMutableArray array];
        int index = 0;
        for (NSDictionary *dic in list) {
            
            GalleryCategory * galleryCategory = [[GalleryCategory alloc] init];
            galleryCategory.galleryCategoryName = [dic validStringValueForKey:PARA_NAME];
            galleryCategory.galleryCategoryCount = [dic validIntValueForKey:PARA_COUNT];
            
            //相册分类只有不等于零的情况下才显示
            if (galleryCategory.galleryCategoryCount !=0) {
               [photoCategoryList addObject:galleryCategory];
            }

            
            NSArray *listTwo = [dic validArrayValueForKey:PARA_PHOTO_LIST];
            for (NSDictionary *dicTwo in listTwo) {
                
                BusinessPhoto *photo = [[BusinessPhoto alloc] init] ;
                photo.photoIndex = index ++;
                photo.photoId = [dicTwo validStringValueForKey:PARA_ID];
                photo.photoThumbUrl = [dicTwo validStringValueForKey:PARA_THUMB_URL];
                photo.photoImageUrl = [dicTwo validStringValueForKey:@"img_url"];
                photo.imageTitle =[dicTwo validStringValueForKey:PARA_IMAGE_TITLE];
                photo.imageDescription =[dicTwo validStringValueForKey:PARA_IMAGE_DESC];
                
                [photoList addObject:photo];
            }
        }
        if ([status isEqualToString:STATUS_SUCCESS]) {
            if ([photoList count] == 0) {
                BusinessPhoto *photo = [[BusinessPhoto alloc] init];
                photo.photoIndex = 0;
                photo.photoThumbUrl = nil;
                photo.imageDescription = nil;
                photo.imageTitle = nil;
                photo.photoId = nil;
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"default_banner_image.png" ofType:nil];
                photo.photoImageUrl = [NSString stringWithFormat:@"file://%@", filePath];
                [photoList addObject:photo];
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetBusinesseAllPhoto:photoCategoryList:status:msg:)]) {
                [delegate didGetBusinesseAllPhoto:photoList photoCategoryList:photoCategoryList status:status msg:msg];
            }
        });
    }];
}


+ (void)getNearbyVenues:(id<BusinessServiceDelegate>)delegate categoryId:(NSString *)categoryId cityId:(NSString *)cityId venuesId:(NSString *)venuesId startTime:(NSString *)startTime endTime:(NSString *)endTime userId:(NSString *)userId {
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_NEARBY_VENUES forKey:PARA_ACTION];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:venuesId forKey:PARA_VENUES_ID];
    [inputDic setValue:startTime forKey:PARA_START_TIME];
    [inputDic setValue:endTime forKey:PARA_END_TIME];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        Business *business = nil;
        
        if ([data validStringValueForKey:PARA_BUSINESS_ID]) {
            business = [[Business alloc] init];
            business.businessId = [data validStringValueForKey:PARA_BUSINESS_ID];
            business.name = [data validStringValueForKey:PARA_NAME];
            business.neighborhood = [data validStringValueForKey:PARA_SUB_REGION];
            business.latitude = [[data validStringValueForKey:PARA_LATITUDE] doubleValue];
            business.longitude = [[data validStringValueForKey:PARA_LONGITUDE] doubleValue];
            business.promotePrice = [[data validStringValueForKey:PARA_PROMOTE_PRICE] floatValue];
            business.price = [[data validStringValueForKey:PARA_PRICE] floatValue];
            business.imageUrl = [data validStringValueForKey:PARA_IMAGE_URL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([delegate respondsToSelector:@selector(didGetNearbyVenusWithStatus:msg:business:)]) {
                [delegate didGetNearbyVenusWithStatus:status msg:msg business:business];
            }
        });
    }];
}

+ (void)getVenueParkList:(id<BusinessServiceDelegate>)delegate venuesId:(NSString *)venues_id categoryId:(NSString *)categoryId {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_BUSINESS_LIST forKey:PARA_ACTION];
    [inputDic setValue:venues_id forKey:PARA_BUSINESS_ID];
    [inputDic setValue:@"2.1" forKey:PARA_VER];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSArray *list = [NSArray array];
        [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *parkList = [NSMutableArray array];
        for(NSDictionary *one in list){
            ParkingLot *pl = [[ParkingLot alloc]init];
            pl.name = [one validStringValueForKey:PARA_NAME];
            pl.address =[one validStringValueForKey:PARA_ADDRESS];
            pl.lat =[one validDoubleValueForKey:PARA_LATITUDE];
            pl.lon = [one validDoubleValueForKey:PARA_LONGITUDE];
            [parkList addObject:pl];
        }
        NSArray *listTwo = [NSArray array];
        listTwo = [data validArrayValueForKey:PARA_TRAFFIC_INFO_LIST];
        NSMutableArray *trafficInfoList = [NSMutableArray array];
        for (NSDictionary *two in listTwo) {
            TrafficInfo *ti = [[TrafficInfo alloc] init];
            ti.name = [two validStringValueForKey:PARA_NAME];
            ti.content = [two validStringValueForKey:PARA_CONTENT];
            [trafficInfoList addObject:ti];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([delegate respondsToSelector:@selector(didGetVenueParkList: trafficInfoList: status: msg:)]) {
                [delegate didGetVenueParkList:parkList trafficInfoList:trafficInfoList status:status msg:msg];
            }
        });
    }];
}

+ (void)getVenuesUserRecommend:(id<BusinessServiceDelegate>)delegate
                    venuesName:(NSString *)venuesName
                  locationName:(NSString *)locationName
                        userId:(NSString *)userId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SUBMIT_VENUES_USER_RECOMMEND forKey:PARA_ACTION];
    [inputDic setValue:venuesName forKey:PARA_VENUES_NAME];
    [inputDic setValue:locationName forKey:PARA_LOCATION_NAME];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if([delegate respondsToSelector:@selector(didGetVenuesUserRecommendWithStatus:msg:)]) {
                [delegate didGetVenuesUserRecommendWithStatus:status msg:msg];
            }
        });
    }];
}

+ (void)setCommentUseful:(BOOL)isUseful
                  userId:(NSString *)userId
                reviewId:(NSString *)reviewId
              completion:(void (^)(NSString *, NSString *))completion {
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SET_COMMENT_USEFUL forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:reviewId forKey:PARA_COMMENT_ID];
    if (isUseful) {
        [inputDic setValue:@"1" forKey:PARA_IS_USEFUL];
    } else {
        [inputDic setValue:@"0" forKey:PARA_IS_USEFUL];
    }
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg);
        });
    }];
}

+ (void)getBusinessGoodsListWithBusinessId:(NSString *)businessId
                                categoryId:(NSString *)categoryId
                                  complete:(void(^)(NSString *status,NSString* msg, NSArray*goodsList ,NSString *guide))complete {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_BUSINESS_GOODS_LIST forKey:PARA_ACTION];
    [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSString *guide = [data validStringValueForKey:PARA_RECEIVE_GUIDE];
        NSArray *list = [data validArrayValueForKey:PARA_GOODS_LIST];
        NSMutableArray *goodsList = [NSMutableArray array];
        for(NSDictionary *one in list){
            if (![one isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            BusinessGoods *goods = [[BusinessGoods alloc]init];
            goods.goodsId = [one validStringValueForKey:PARA_GOODS_ID];
            goods.name = [one validStringValueForKey:PARA_NAME];
            goods.price = [one validDoubleValueForKey:PARA_PRICE];
            goods.limitCount = [one validIntValueForKey:PARA_LIMIT_BUY];
            goods.speci = [one validStringValueForKey:PARA_SPECI];
            goods.totalCount = 0;
            [goodsList addObject:goods];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(status,msg,goodsList,guide);
        });
    }];
}

+ (void)submitVenuesMistakeWithUserId:(NSString *)userId
                               cityId:(NSString *)cityId
                             venuesId:(NSString *)venuesId
                          venuesCatId:(NSString *)venuesCatId
                           typeString:(NSString *)typeString
                              content:(NSString *)content
                           completion:(void (^)(NSString *, NSString *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SUBMIT_VENUES_MISTAKE forKey:PARA_ACTION];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:venuesId forKey:PARA_VENUES_ID];
    [inputDic setValue:venuesCatId forKey:PARA_VENUES_CAT_ID];
    [inputDic setValue:typeString forKey:PARA_MISTAKE_TYPE];
    [inputDic setValue:content forKey:PARA_MISTAKE_CONTENT];
    if (userId) {
        [inputDic setValue:userId forKey:PARA_USER_ID];
    }
    
    [GSNetwork getWithBasicUrlString:GS_URL_VENUE parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg);
        });
    }];
}

@end
