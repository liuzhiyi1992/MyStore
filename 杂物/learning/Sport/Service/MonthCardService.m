//
//  MonthCardService.m
//  Sport
//
//

#import "MonthCardService.h"
#import "SportNetwork.h"
#import "BusinessCategory.h"
#import "Business.h"
#import "BusinessManager.h"
#import "MonthCardCourseManager.h"
#import "User.h"
#import "UserManager.h"
#import "BusinessPhoto.h"
#import "MonthCardAssistent.h"
#import "OrderService.h"

@implementation MonthCardService

+ (void)getVenuesList:(id<MonthCardServiceDelegate>)delegate
             categoryId:(NSString *)categoryId
                 cityId:(NSString *)cityId
              regionId:(NSString *)regionId
             latitude:(double)latitude
            longitude:(double)longitude
                  count:(int)count
                   page:(int)page
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_VENUES_LIST forKey:PARA_ACTION];
        [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        [inputDic setValue:regionId forKey:PARA_REGION_ID];
        
        if (latitude != 0 && longitude != 0) {
            [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
            [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];
        }
        
        [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
        [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSArray *businesses = [BusinessManager venuesListByDictionary:resultDictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetVenuesList:page:status:msg:)]) {
                [delegate didGetVenuesList:businesses
                                      page:page status:status msg:msg];
            }
        });
    });
}

+ (void)getCourseList:(id<MonthCardServiceDelegate>)delegate
           categoryId:(NSString *)categoryId
               cityId:(NSString *)cityId
             regionId:(NSString *)regionId
                 date:(NSString *)date
             latitude:(double)latitude
            longitude:(double)longitude
                count:(int)count
                 page:(int)page
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_COURSE_LIST forKey:PARA_ACTION];
        [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        [inputDic setValue:regionId forKey:PARA_REGION_ID];

        [inputDic setValue:date forKey:PARA_DATE];
        
        if (latitude != 0 && longitude != 0) {
            [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
            [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];
        }
        
        [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
        [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];

        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSArray *courses = [MonthCardCourseManager courseListByDictionary:resultDictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetCourseList:page:status:msg:)]) {
                [delegate didGetCourseList:courses
                                      page:page status:status msg:msg];
            }
        });
    });
}

+ (void)venuesInfo:(id<MonthCardServiceDelegate>)delegate
        businessId:(NSString *)businessId
        categoryId:(NSString *)categoryId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_VENUES_INFO forKey:PARA_ACTION];
        [inputDic setValue:businessId forKey:PARA_BUSINESS_ID];
        [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
        [inputDic setValue:[[UserManager defaultManager] readCurrentUser].userId forKey:PARA_USER_ID];
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        Business *business = [BusinessManager businessByOneBusinessJson:data];
        int monthCardStatus = [data validIntValueForKey:PARA_MONCARD_STATUS];
 
         dispatch_async(dispatch_get_main_queue(), ^{
             if (delegate && [delegate respondsToSelector:@selector(didVenuesInfo:monthCardStatus:status:msg:)]) {
                 [delegate didVenuesInfo:business monthCardStatus:monthCardStatus status:status msg:msg];
             }
         });
     });
}

+ (void)getRecommendCourseList:(id<MonthCardServiceDelegate>)delegate
                        cityId:(NSString *)cityId
                         count:(int)count
                          page:(int)page
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_RECOMMEND_COURSE forKey:PARA_ACTION];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        
        [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
        [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSArray *courses = [MonthCardCourseManager courseListByDictionary:resultDictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetRecommendCourseList:page:status:msg:)]) {
                [delegate didGetRecommendCourseList:courses
                                               page:page status:status msg:msg];
            }
        });
    });
}

+ (void)uploadAvatar:(id<MonthCardServiceDelegate>)delegate
            userId:(NSString *)userId
            image:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_UPLOAD_IMAGE forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
        NSDictionary *resultDictionary = [SportNetwork jsonWithpostImage:image
                                                               imageName:[NSString stringWithFormat:@"%@.jpg", userId]
                                                          basicUrlString:SPORT_URL_DEFAULT_APP_MONTHCARD
                                                     parameterDictionary:inputDic];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        BusinessPhoto *photo = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            photo = [[BusinessPhoto alloc] init];
            photo.photoId = [data validStringValueForKey:PARA_ATTACH_ID];
            photo.photoImageUrl = [data validStringValueForKey:PARA_IMAGE_URL];
            photo.photoThumbUrl = [data validStringValueForKey:PARA_THUMB_URL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUploadAvatar:status:msg:)]) {
                [delegate didUploadAvatar:photo status:status msg:msg];
            }
        });
    });
}

+ (void)getQrCode:(id<MonthCardServiceDelegate>)delegate
              userId:(NSString *)userId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_QR_CODE_SIGN forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];

        NSString *qrCode = [data validStringValueForKey:PARA_SIGN];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetQrCode:status:msg:)]) {
                [delegate didGetQrCode:qrCode status:status msg:msg];
            }
        });
    });
}

+ (void)getMonthCardInfo:(id<MonthCardServiceDelegate>)delegate
           userId:(NSString *)userId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CARD_INFO forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        MonthCard *card = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            card = [self monthCardFromDictionary:data];
            
            User *user = [[UserManager defaultManager] readCurrentUser];
            user.monthCard = card;
            [[UserManager defaultManager] saveCurrentUser:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetMonthCardInfo:status:msg:)]) {
                [delegate didGetMonthCardInfo:card status:status msg:msg];
            }
        });
    });
}

+ (MonthCard *)monthCardFromDictionary:(NSDictionary *)dictionary
{
    MonthCard *card = [[MonthCard alloc]init];
    card.cardId = [dictionary validStringValueForKey:PARA_CARD_ID];
    card.nickName = [dictionary validStringValueForKey:PARA_NICK_NAME];
    card.avatarImageURL = [dictionary validStringValueForKey:PARA_AVATAR];
    card.avatarThumbURL = [dictionary validStringValueForKey:PARA_THUMB_AVATAR];
    card.endTime = [dictionary validDateValueForKey:PARA_END_TIME];
    card.cardStatus = [dictionary validIntValueForKey:PARA_CARD_STATUS];
    
    return card;
}

+ (void)addMonCardOrder:(id<MonthCardServiceDelegate>)delegate
                  phone:(NSString *)phone
            goodsNumber:(NSUInteger)goodsNumber
             activityId:(NSString *)activityId
               couponId:(NSString *)couponId
             ticketType:(NSString *)ticketType
                 cityId:(NSString *)cityId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_MON_CARD_ORDER forKey:PARA_ACTION];
        [inputDic setValue:[[UserManager defaultManager] readCurrentUser].userId forKey:PARA_USER_ID];
        [inputDic setValue:phone forKey:PARA_PHONE];
        [inputDic setValue:[@(goodsNumber) stringValue] forKey:PARA_GOODS_NUMBER];
        [inputDic setValue:activityId forKey:PARA_ACT_ID];
        [inputDic setValue:couponId forKey:PARA_COUPON_ID];
        [inputDic setValue:ticketType forKey:PARA_TICKET_TYPE];
        [inputDic setValue:@"5" forKey:PARA_ORDER_TYPE];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        [inputDic setValue:@"1.1" forKey:PARA_VER]; //版本1.1：添加了ticket_type
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        Order *order = [OrderService orderByOneOrderDictionary:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAddMonCardOrder:status:msg:)]) {
                [delegate didAddMonCardOrder:order status:status msg:msg];
            }
        });
    });
}

//- (void)courseInfo:(id<MonthCardServiceDelegate>)delegate
//          courseId:(NSString *)courseId
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
//        [inputDic setValue:VALUE_ACTION_COURSE_INFO forKey:PARA_ACTION];
//        [inputDic setValue:courseId forKey:PARA_COURSE_ID];
//
//        NSDictionary *resultDictionary = [SportNetwrok getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
//        
//        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
//        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([delegate respondsToSelector:@selector(didCourseInfo:status:msg:)]) {
//                [delegate didCourseInfo:nil status:status msg:msg];
//            }
//        });
//    });
//}

+ (void)bookCourse:(id<MonthCardServiceDelegate>)delegate
           goodsId:(NSString *)goodsId
            userId:(NSString *)userId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_BOOK_COURSE forKey:PARA_ACTION];
        [inputDic setValue:goodsId forKey:PARA_GOODS_ID];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didBookCourse:msg:)]) {
                [delegate didBookCourse:status msg:msg];
            }
        });
    });
}

+ (void)checkCourseStatus:(id<MonthCardServiceDelegate>)delegate
                   userId:(NSString *)userId
                 courseId:(NSString *)courseId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CHECK_COURSE_STATUS forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:courseId forKey:PARA_COURSE_ID];
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        int courseStatus = [data validIntValueForKey:PARA_STATUS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didCheckCourseStatus:status:msg:)]) {
                [delegate didCheckCourseStatus:courseStatus status:status msg:msg];
            }
        });
    });
}

//- (void)cardGoodsInfo:(id<MonthCardServiceDelegate>)delegate
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
//        [inputDic setValue:VALUE_ACTION_CARD_GOODS_INFO forKey:PARA_ACTION];
//        
//        NSDictionary *resultDictionary = [SportNetwrok getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
//        
//        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
//        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
//        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
//        
//        NSString *name = [data validStringValueForKey:PARA_GOODS_NAME];
//        NSString *goodsId = [data validStringValueForKey:PARA_GOODS_ID];
//        float price = [data validFloatValueForKey:PARA_PRICE];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([delegate respondsToSelector:@selector(didCardGoodsInfo:goodsId:price:status:msg:)]) {
//                [delegate didCardGoodsInfo:name goodsId:goodsId price:price status:status msg:msg];
//            }
//        });
//    });
//}

+ (void)monCardConfirmOrder:(id<MonthCardServiceDelegate>)delegate
                goodsNumber:(NSUInteger)goodsNumber
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_MON_CARD_CONFIRM_ORDER forKey:PARA_ACTION];
        [inputDic setValue:[[UserManager defaultManager] readCurrentUser].userId forKey:PARA_USER_ID];
        [inputDic setValue:[@(goodsNumber) stringValue] forKey:PARA_GOODS_NUMBER];
        [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *goodsId = nil;
        NSString *goodsName = nil;
        float onePrice = 0;
        float totalAmount = 0;
        float orderAmount = 0;
        float orderPromote = 0;
        NSString *activityId = nil;
        NSArray *activityList = nil;
        NSString *activityMessage = nil;
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            goodsId = [data validStringValueForKey:PARA_GOODS_ID];
            goodsName = [data validStringValueForKey:PARA_GOODS_NAME];
            onePrice = [data validFloatValueForKey:PARA_PRICE];
            totalAmount = [data validFloatValueForKey:PARA_TOTAL_AMOUNT];
            orderAmount = [data validFloatValueForKey:PARA_ORDER_AMOUNT];
            orderPromote = [data validFloatValueForKey:PARA_ORDER_PROMOTE];
            activityId = [data validStringValueForKey:PARA_ACT_ID];
            activityList = [OrderService activityListByDictionaryList:[data validArrayValueForKey:PARA_ACTIVITY_LIST]];
            activityMessage = [data validStringValueForKey:PARA_ACTIVITY_MESSAGE];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didMonCardConfirmOrder:msg:goodsId:goodsName:onePrice:totalAmount:orderAmount:orderPromote:activityId:activityList:activityMessage:goodsNumber:)]) {
                [delegate didMonCardConfirmOrder:status
                                             msg:msg
                                         goodsId:goodsId
                                       goodsName:goodsName
                                        onePrice:onePrice
                                     totalAmount:totalAmount
                                     orderAmount:orderAmount
                                    orderPromote:orderPromote
                                      activityId:activityId
                                    activityList:activityList
                                 activityMessage:activityMessage
                                     goodsNumber:goodsNumber];
            }
        });
    }];
}

+ (void)sportAssistant:(id<MonthCardServiceDelegate>)delegate
                userId:(NSString *)userId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_SPORT_ASSISTANT forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSArray *list = [MonthCardService assistListByDictionary:resultDictionary];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetSportAssistant:status:msg:)]) {
                [delegate didGetSportAssistant:list status:status msg:msg];
            }
        });
    });
}


+ (NSArray *)assistListByDictionary:(NSDictionary *)dictionary
{
    id dicList = [dictionary objectForKey:PARA_DATA];
    if ([dicList isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    NSMutableArray *list = [NSMutableArray array];
    for (id dic in (NSArray *)dicList) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            MonthCardAssistent *assis = [self assistFromDictionary:dic];
            [list addObject:assis];
        }
    }
    return list;
}

+ (MonthCardAssistent *)assistFromDictionary:(NSDictionary *)dictionary
{
    MonthCardAssistent *assis = [[MonthCardAssistent alloc]init];
    assis.date = [dictionary validDateValueForKey:PARA_DATE];
    assis.venuesId = [dictionary validStringValueForKey:PARA_VENUES_ID];
    assis.venuesName = [dictionary validStringValueForKey:PARA_VENUES_NAME];
    assis.categoryId = [dictionary validStringValueForKey:PARA_CATEGORY_ID];
    
    assis.categoryImageURL = [dictionary validStringValueForKey:PARA_CATEGORY_IMG_URL];
    assis.course.courseId = [dictionary validStringValueForKey:PARA_COURSE_ID];
    assis.course.courseUrl = [dictionary validStringValueForKey:PARA_MONCARD_COURSE_URL];
    assis.course.courseName = [dictionary validStringValueForKey:PARA_COURSE_NAME];
    
    assis.course.startTime = [dictionary validDateValueForKey:PARA_COURSE_START_TIME];
    assis.course.endTime = [dictionary validDateValueForKey:PARA_COURSE_END_TIME];
    
    assis.address = [dictionary validStringValueForKey:PARA_ADDRESS];
    assis.phone = [dictionary validStringValueForKey:PARA_PHONE];
    
    assis.latitude = [dictionary validDoubleValueForKey:PARA_LATITUDE];
    assis.longitude = [dictionary validDoubleValueForKey:PARA_LONGITUDE];
    assis.notice = [dictionary validStringValueForKey:PARA_NOTICE];
    
    return assis;
}


+ (void)sportRecordVenues:(id<MonthCardServiceDelegate>)delegate
                   userId:(NSString *)userId
                     page:(NSUInteger)page
                    count:(NSUInteger)count
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_SPORT_RECORD_VENUES forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
        [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSArray *venues = [BusinessManager venuesListByDictionary:resultDictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetRcordVenueList:page:status:msg:)]) {
                [delegate didGetRcordVenueList:venues page:page status:status msg:msg];
            }
        });
    });
}

+ (void)sportRecordCourse:(id<MonthCardServiceDelegate>)delegate
                   userId:(NSString *)userId
                     page:(NSUInteger)page
                    count:(NSUInteger)count
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_SPORT_RECORD_COURSE forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
        [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
        
        NSDictionary *resultDictionary = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_MONTHCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSArray *courses = [MonthCardCourseManager courseListByDictionary:resultDictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetRcordCourseList:page:status:msg:)]) {
                [delegate didGetRcordCourseList:courses page:page status:status msg:msg];
            }
        });
    });
}

@end
