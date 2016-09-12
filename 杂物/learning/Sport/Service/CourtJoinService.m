//
//  CourtJoinService.m
//  Sport
//
//  Created by 江彦聪 on 16/6/6.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinService.h"
#import "GSNetwork.h"
#import "CourtJoin.h"
#import "Order.h"
#import "OrderService.h"
#import "Business.h"
#import "BusinessCategory.h"
#import "CourtJoinUser.h"
#import "ShareContent.h"
#import "SDWebImageManager.h"
#import "UIImage+normalized.h"

@implementation CourtJoinService
+ (void)getCourtJoinInfo:(NSString *)courtJoinId userId:(NSString *)userId completion:(void (^)(NSString *, NSString *, CourtJoin *))completion{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:VALUE_ACTION_GET_COURTJOIN_INFO forKey:PARA_ACTION];
    [inputDic setValue:courtJoinId forKey:PARA_CJ_ORDER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        CourtJoin *courtJoin = [self courtJoinByOneCourtJoinDictionary:data];
        courtJoin.courtJoinId = courtJoinId;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, courtJoin);
        });
    }];
}

+ (void)sponsorCourtJoinWithUserId:(NSString *)userId
                           orderId:(NSString *)orderId
                             phone:(NSString *)phone
                        playersNum:(int)playersNum
                       description:(NSString *)description
                        completion:(void (^)(NSString *, NSString *, NSString *, BOOL, ShareContent *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_LAUNCH_COURT_JOIN  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:phone forKey:PARA_PHONE_ENCODE];
    [inputDic setValue:@(playersNum) forKey:PARA_PLAYERS_NUM];
    [inputDic setValue:description forKey:PARA_DESCRIPTION];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *shareUrl = [data validStringValueForKey:PARA_SHARE_COURT_JOIN_URL];
        BOOL isFirstTimeSponsorCourt = [data validBoolValueForKey:PARA_IS_FIRST_TIME_SPONSOR];
        
        //shareInfo
        NSDictionary *shareInfo = [data validDictionaryValueForKey:PARA_SHARE_INFO];
        ShareContent *shareContent = [[ShareContent alloc] init];
        shareContent.title = [shareInfo validStringValueForKey:PARA_TITLE];
        shareContent.subTitle = [shareInfo validStringValueForKey:PARA_CONTENT];
        shareContent.linkUrl = [shareInfo validStringValueForKey:PARA_URL];
        shareContent.imageUrL = [shareInfo validStringValueForKey:PARA_LOGO];
        shareContent.content = [shareInfo validStringValueForKey:PARA_CONTENT];
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        [downloader downloadImageWithURL:[NSURL URLWithString:shareContent.imageUrL]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    // progression tracking code
                                }
                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                   if (image && finished) {
                                       shareContent.thumbImage = [image compressWithMaxLenth:80];
                                   }
                               }];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, shareUrl, isFirstTimeSponsorCourt, shareContent);
        });
    }];
}

+ (void)updateCourtJoinDescWithOrderId:(NSString *)orderId userId:(NSString *)userId desc:(NSString *)desc completion:(void (^)(NSString *, NSString *, NSString *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UPDATE_COURT_JOIN_DESC  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:desc forKey:PARA_DESCRIPTION];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *resultStatus = [data validStringValueForKey:PARA_UPDATE_RESULT];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, resultStatus);
        });
    }];
}

+ (void)getCourtJoinOrderDetailWithOrderId:(NSString *)orderId completion:(void (^)(NSString *, NSString *, Order *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COURT_JOIN_ORDER_INFO  forKey:PARA_ACTION];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        Order *order = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {

            NSDictionary *orderInfo = [data validDictionaryValueForKey:PARA_ORDER_INFO];
            
            order = [OrderService orderByOneOrderDictionary:orderInfo];
            order.courtJoin = [self courtJoinByOneCourtJoinDictionary:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, order);
        });
    }];
}

+ (void) confirmOrderCourtJoinWithId:(NSString *)courtJoinId userId:(NSString *)userId completion:(void (^)(NSString *status, NSString *msg,CourtJoin *courtJoin))completion{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CONFIRM_ORDER  forKey:PARA_ACTION];
    [inputDic setValue:courtJoinId forKey:PARA_CJ_ORDER_ID];
    [inputDic setValue:[@(OrderTypeCourtJoin) stringValue] forKey:PARA_ORDER_TYPE];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        CourtJoin *courtJoin = [self courtJoinByOneCourtJoinDictionary:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, courtJoin);
        });
        
    }];
}

+ (CourtJoin *)courtJoinByOneCourtJoinDictionary:(NSDictionary *)courtJoinDictionary {
    CourtJoin *courtJoin = [[CourtJoin alloc]init];
    courtJoin.courtJoinId = [courtJoinDictionary validStringValueForKey:PARA_CJ_ORDER_ID];
    courtJoin.sponsorPermission = [courtJoinDictionary validBoolValueForKey:PARA_COURT_JOIN_PERMISSION];
    courtJoin.courtJoinMsg = [courtJoinDictionary validStringValueForKey:PARA_COURT_JOIN_MSG];
    courtJoin.remindTips = [courtJoinDictionary validStringValueForKey:PARA_COURT_JOIN_REMIND_TIPS];
    courtJoin.leftJoinNumber = [courtJoinDictionary validIntValueForKey:PARA_LEFT_JOIN_NUM];
    courtJoin.maximumNumber = [courtJoinDictionary validIntValueForKey:PARA_COURT_JOIN_MAX_PLAYERS];

    //infoDict
    NSDictionary *courtJoinInfoDict = [courtJoinDictionary validDictionaryValueForKey:PARA_COURT_JOIN_INFO];
    if ([courtJoinInfoDict allKeys].count > 0) {
        courtJoin.startTime = [courtJoinInfoDict validDateValueForKey:PARA_START_TIME];
        courtJoin.endTime = [courtJoinInfoDict validDateValueForKey:PARA_END_TIME];
        courtJoin.phoneNumber = [courtJoinInfoDict validStringValueForKey:PARA_LAUNCH_MOBILE];
        courtJoin.bookDate = [courtJoinInfoDict validDateValueForKey:PARA_BOOK_DATE];
        courtJoin.price = [courtJoinInfoDict validDoubleValueForKey:PARA_PRICE];
        courtJoin.courtJoinId = [courtJoinInfoDict validStringValueForKey:PARA_CJ_ORDER_ID];
        courtJoin.avatarUrl = [courtJoinInfoDict validStringValueForKey:PARA_COURT_USER_AVATAR];
        courtJoin.courtUserId = [courtJoinInfoDict validStringValueForKey:PARA_COURT_USER_ID];
        courtJoin.nickName = [courtJoinInfoDict validStringValueForKey:PARA_COURT_USER_NICK_NAME];
        courtJoin.gender = [courtJoinInfoDict validStringValueForKey:PARA_GENDER];
        courtJoin.leftJoinNumber = [courtJoinInfoDict validIntValueForKey:PARA_LEFT_JOIN_NUM];
        courtJoin.leftJoinNumberMsg = [courtJoinInfoDict validStringValueForKey:PARA_LEFT_JOIN_NUM_MSG];
        courtJoin.joinDescription = [courtJoinInfoDict validStringValueForKey:PARA_COURT_JOIN_DESCRIPTION];
        courtJoin.alreadyJoinNumber = [courtJoinInfoDict validIntValueForKey:PARA_ALREADY_JOIN_NUM];
        courtJoin.status = [courtJoinInfoDict validIntValueForKey:PARA_COURT_JOIN_STATUS];
        courtJoin.statusMsg = [courtJoinInfoDict validStringValueForKey:PARA_COURT_JOIN_STATUS_MSG];
        courtJoin.available = [courtJoinInfoDict validBoolValueForKey:PARA_COURT_JOIN_AVAILABLE];
        courtJoin.disableMsg = [courtJoinInfoDict validStringValueForKey:PARA_COURT_JOIN_DISABLE_MSG];
        courtJoin.maximumNumber = [courtJoinInfoDict validIntValueForKey:PARA_JOIN_NUM];
        courtJoin.continuous = [courtJoinInfoDict validStringValueForKey:PARA_COURT_JOIN_CONTINUOUS];
        
        //participantInfoList
        NSArray *participantArray = [courtJoinInfoDict validArrayValueForKey:PARA_PARTICIPANT_INFO];
        if (participantArray) {
            NSMutableArray *userList = [NSMutableArray array];
            for (NSDictionary *participantInfo in participantArray){
                CourtJoinUser *courtJoinUser = [[CourtJoinUser alloc]init];
                courtJoinUser.userId = [participantInfo validStringValueForKey:PARA_USER_ID];
                courtJoinUser.userName = [participantInfo validStringValueForKey:PARA_NICK_NAME];
                courtJoinUser.avatarUrl = [participantInfo validStringValueForKey:PARA_AVATAR];
                courtJoinUser.gender = [participantInfo validStringValueForKey:PARA_GENDER];
                courtJoinUser.orderStatus = [participantInfo validIntValueForKey:PARA_ORDER_STATUS];
                courtJoinUser.phoneNumber = [participantInfo validStringValueForKey:PARA_MOBILE];
                [userList addObject:courtJoinUser];
            }
            courtJoin.userList = userList;
        }
        
        NSArray *productList = [courtJoinInfoDict validArrayValueForKey:PARA_COURT_JOIN_GOODS_LIST];
        if (productList) {
            NSMutableArray *periodTimeList = [NSMutableArray array];
            for (NSDictionary *periodTime in productList) {
                Product *goodsTartet = [self productByOneProductDictionary:periodTime];
                [periodTimeList addObject:goodsTartet];
            }
            courtJoin.productList = periodTimeList;
        }
        
        courtJoin.priceTagMsg = [courtJoinInfoDict validStringValueForKey:PARA_PRICE_TAG_MSG];
    }
    
    //shareInfo
    NSDictionary *shareInfoDict = [courtJoinDictionary validDictionaryValueForKey:PARA_COURT_JOIN_SHARE_INFO];
    if (shareInfoDict.allKeys.count > 0) {
        NSString *linkUrl = [shareInfoDict validStringValueForKey:PARA_URL];
        NSString *logoUrl = [shareInfoDict validStringValueForKey:PARA_LOGO];
        NSString *content = [shareInfoDict validStringValueForKey:PARA_CONTENT];
        NSString *title = [shareInfoDict validStringValueForKey:PARA_TITLE];
        
        ShareContent *shareContent = [[ShareContent alloc]init];
        shareContent.title = title;
        shareContent.subTitle = content;
        shareContent.imageUrL = logoUrl;
        shareContent.content = content;
        shareContent.linkUrl = linkUrl;
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        [downloader downloadImageWithURL:[NSURL URLWithString:shareContent.imageUrL]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    // progression tracking code
                                }
                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                   if (image && finished) {
                                       shareContent.thumbImage = [image compressWithMaxLenth:80];
                                   }
                               }];
        
        courtJoin.shareContent = shareContent;
  
    }
    
    //venuesInfo
    NSDictionary *venuesInfo = [courtJoinDictionary validDictionaryValueForKey:PARA_VENUES_INFO];
    if (venuesInfo.allKeys.count > 0) {
        courtJoin.address = [venuesInfo validStringValueForKey:PARA_VENUES_ADDRESS];
        courtJoin.latitude = [venuesInfo validDoubleValueForKey:PARA_LATITUDE];
        courtJoin.longtitude = [venuesInfo validDoubleValueForKey:PARA_LONGITUDE];
        courtJoin.businessName = [venuesInfo validStringValueForKey:PARA_VENUES_NAME];
        courtJoin.businessId = [venuesInfo validStringValueForKey:PARA_VENUES_ID];
        courtJoin.categoryId = [venuesInfo validStringValueForKey:PARA_CAT_ID];
        courtJoin.categoryName =  [venuesInfo validStringValueForKey:PARA_CAT_NAME];
    }
    
    return courtJoin;
}

+(Product *) productByOneProductDictionary:(NSDictionary *)productDictionary {
    Product *goodsTartet = [[Product alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"H:mm"];
    NSDate *startTime = [productDictionary validDateValueForKey:PARA_START_TIME];
    
    goodsTartet.startTime = [formatter stringFromDate:startTime];
    goodsTartet.courtName = [productDictionary validStringValueForKey:PARA_COURT_NAME];
    goodsTartet.productId = [productDictionary validStringValueForKey:PARA_GOODS_ID];
    goodsTartet.courtJoinPrice = [productDictionary validDoubleValueForKey:PARA_COURT_JOIN_PRICE];
    
    return goodsTartet;
}

//球局列表
+ (void)getCourtJoinList:(id<CourtJoinServiceDelegate>)delegate
                latitude:(double)latitude
               longitude:(double)longitude
                   count:(int)count
                    page:(int)page
              categoryId:(NSString *)categoryId
                  userId:(NSString *)userId
                bookDate:(NSDate *)bookDate{
        
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COURTJOIN_LIST forKey:PARA_ACTION];
    [inputDic setValue:[@(latitude) stringValue] forKey:PARA_LATITUDE];
    [inputDic setValue:[@(longitude) stringValue] forKey:PARA_LONGITUDE];
    [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
    [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
    
    if(bookDate) {
        [inputDic setValue:[@((int)[bookDate timeIntervalSince1970]) stringValue] forKey:PARA_BOOK_DATE];
    }
    
    [inputDic setValue:categoryId forKey:PARA_CAT_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        //球局列表数组
        NSMutableArray *courtJoinList = [NSMutableArray array];
        for (NSDictionary *one in [data validArrayValueForKey:PARA_COURT_JOIN_LIST]){
            CourtJoin *courtJoin = [self courtJoinByOneCourtJoinDictionary:one];
            [courtJoinList addObject:courtJoin];
        }
        
        //球局日期
        NSMutableArray *courtJoinDateList = [NSMutableArray array];
        NSArray *cjdl = [data validArrayValueForKey:PARA_COURT_JOIN_DATE_LIST];
        
        for (NSDictionary *one in cjdl){
            NSString * dateString = [one validStringValueForKey:PARA_BOOK_DATE];
            int dateInt = [dateString intValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateInt];
            [courtJoinDateList addObject:date];
        }
//        NSDate *currentTime = [data validDateValueForKey:PARA_BOOK_DATE];

        //球局项目
        //当前选择项目
        NSString *defaultSelectedCategoryId = nil;
        NSString *currentSelectedCategoryName = nil;
        NSMutableArray *courtJoinCategoriesList = [NSMutableArray array];
        for (NSDictionary *one in [data validArrayValueForKey:PARA_CATEGORIES]) {
            BusinessCategory *businessCategory = [[BusinessCategory alloc] init];
            businessCategory.businessCategoryId = [one validStringValueForKey:PARA_CATEGORY_ID];
            businessCategory.name = [one validStringValueForKey:PARA_CATEGORY_NAME];
            [courtJoinCategoriesList addObject:businessCategory];
            if ([one validBoolValueForKey:PARA_IS_CHOOSE_CATEGORY]) {
                defaultSelectedCategoryId = businessCategory.businessCategoryId;
            }
        }
        
        NSDate *currentDate = [data validDateValueForKey:PARA_SELECTED_DATE];
        
        //对选择的目录做处理
            if (categoryId == nil) {
                for (BusinessCategory *bc in courtJoinCategoriesList) {
                    if ([bc.businessCategoryId isEqualToString:defaultSelectedCategoryId]) {
                        currentSelectedCategoryName = bc.name;
                    }
                }
 
            }else {
                for (BusinessCategory *bc in courtJoinCategoriesList) {
                    if ([bc.businessCategoryId isEqualToString:categoryId]) {
                        currentSelectedCategoryName = bc.name;
                    }
                }
            }
    
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCourtJoinList:courtJoinDateList:courtJoinCategoriesList:currentSelectedCategoryName:currentDate:status:msg:)]) {
                [delegate didGetCourtJoinList:courtJoinList courtJoinDateList:courtJoinDateList courtJoinCategoriesList:courtJoinCategoriesList currentSelectedCategoryName:currentSelectedCategoryName currentDate:currentDate status:status msg:msg ];
            }
        });
    }];
}

@end

