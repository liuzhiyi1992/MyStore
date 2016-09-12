//
//  BaseService.m
//  Sport
//
//  Created by haodong  on 13-8-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BaseService.h"
#import "City.h"
#import "CityManager.h"
#import "Region.h"
#import "Province.h"
#import "NSString+Utils.h"
#import "BaseConfigManager.h"
#import "CircleProjectManager.h"
#import "BusinessCategoryManager.h"
#import "BusinessCategory.h"
#import "PayMethod.h"
#import "AppGlobalDataManager.h"
#import "FileUtil.h"
#import "BusinessSearchDataManager.h"
#import "GSNetwork.h"


@interface BaseService()
@property (assign, nonatomic) BOOL isLoadingStaticData;
@property (assign, nonatomic) int loadStaticDataTimes;
@end

static BaseService *_globalBaseService = nil;

@implementation BaseService

+ (BaseService *)defaultService
{
    if (_globalBaseService == nil) {
        _globalBaseService = [[BaseService alloc] init];
    }
    return _globalBaseService;
}

- (NSArray *)parseCityList:(NSArray *)cities
{
//    NSArray *cities = [dataDic validArrayValueForKey:PARA_CITIES];
    
    NSMutableArray *cityList = [NSMutableArray array];
    for (id dic in cities) {
        if ([dic isKindOfClass:[NSDictionary class]] == NO)
        {
            continue;
        }
        City *city = [[City alloc] init] ;
        city.cityId  = [(NSDictionary *)dic validStringValueForKey:PARA_CITY_ID];
        city.cityName = [(NSDictionary *)dic validStringValueForKey:PARA_CITY_NAME];
        
        city.latitude =[(NSDictionary *)dic validDoubleValueForKey:PARA_LATITUDE];
        city.longitude =[(NSDictionary *)dic validDoubleValueForKey:PARA_LONGITUDE];
        
        NSArray *regions = [dic validArrayValueForKey:PARA_REGIONS];
        NSMutableArray *regionList = [NSMutableArray array];
        for (id regoinSource in regions) {
            if ([regoinSource isKindOfClass:[NSDictionary class]] == NO)
            {
                continue;
            }
            Region *region = [[Region alloc] init];
            region.regionId = [regoinSource validStringValueForKey:PARA_REGION_ID];
            region.regionName = [regoinSource validStringValueForKey:PARA_REGION_NAME];
            [regionList addObject:region];
        }
        city.regionList = regionList;
        [cityList addObject:city];
    }
    
    return cityList;
}

- (void)queryCityList:(id<BaseServiceDelegate>)delegate
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CITIES forKey:PARA_ACTION];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        NSArray *cityList = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            cityList = [self parseCityList:[data validArrayValueForKey:PARA_LIST]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([status isEqualToString:STATUS_SUCCESS]) {
                [[CityManager defaultManager] setCityList:cityList];
            }
            
            if (delegate && [delegate respondsToSelector:@selector(didQueryCityList:status:)]) {
                [delegate didQueryCityList:cityList status:status];
            }
        });
    }];
}

- (void)feedback:(id<BaseServiceDelegate>)delegate
         content:(NSString *)content
          userId:(NSString *)userId
            type:(int)type
{
        //send
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_INSERT_FEEDBACK forKey:PARA_ACTION];
        [inputDic setValue:content forKey:PARA_CONTENT];
        if (userId) {
            [inputDic setValue:userId forKey:PARA_USER_ID];
        }
        [inputDic setValue:[NSString stringWithFormat:@"%d",type] forKeyPath:PARA_TYPE];
        
       [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (delegate && [delegate respondsToSelector:@selector(didFeedback:msg:)]) {
                    [delegate didFeedback:status msg:msg];
                }
            });
    }];
}

- (void)queryUserProvinceList:(id<BaseServiceDelegate>)delegate
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_CITY_LIST forKey:PARA_ACTION];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        //        HDLog(@"user city list:%@", resultDictionary);
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *sourceProvinceList = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *targetProvinceList = [NSMutableArray array];
        
        for (id dic in sourceProvinceList) {
            if ([dic isKindOfClass:[NSDictionary class]] == NO)
            {
                continue;
            }
            
            Province *province = [[Province alloc] init] ;
            province.provinceId  = [(NSDictionary *)dic validStringValueForKey:PARA_PROVINCE_ID];
            province.provinceName = [(NSDictionary *)dic validStringValueForKey:PARA_PROVINCE_NAME];
            
            NSArray *sourceCityList = [dic validArrayValueForKey:PARA_CITY_LIST];
            NSMutableArray *targetCityList = [NSMutableArray array];
            for (id sourceCity in sourceCityList) {
                if ([sourceCity isKindOfClass:[NSDictionary class]] == NO)
                {
                    continue;
                }
                City *city = [[City alloc] init] ;
                city.cityId = [sourceCity validStringValueForKey:PARA_CITY_ID];
                city.cityName = [sourceCity validStringValueForKey:PARA_CITY_NAME];
                [targetCityList addObject:city];
            }
            
            province.cityList = targetCityList;
            
            [targetProvinceList addObject:province];
        }
        
        [[CityManager defaultManager] setProvinceList:targetProvinceList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryUserProvinceList:status:)]) {
                [delegate didQueryUserProvinceList:targetProvinceList status:status];
            }
        });
    }];
}

- (void)parseStaticData:(NSDictionary *)resultDictionary
{
    NSDictionary *dataDic = [resultDictionary validDictionaryValueForKey:PARA_DATA];
    BaseConfigManager *manager = [BaseConfigManager defaultManager];
    //配置信息
    NSDictionary *configDic = [dataDic validDictionaryValueForKey:PARA_CONFIG];
    if (configDic) {
        [manager setHasGetConfig:YES];
        
        id list = [configDic validArrayValueForKey:PARA_IOS_INTEGRAL_KEY];
        if ([list isKindOfClass:[NSArray class]]) {
            [manager setIapProductIdList:list];
        }
        
        int intIsShowVoucher = [configDic validIntValueForKey:PARA_SHOW_COUPON];
        [manager setIsShowVoucher:(intIsShowVoucher == 1)];
        
        NSString *payHelpUrl = [configDic validStringValueForKey:PARA_HELP_URL];
        [manager setPayHelpUrl:payHelpUrl];
        
        NSString *startupImageUrl = [configDic validStringValueForKey:PARA_START_UP_IMAGE];
        [manager setStartupImageUrl:startupImageUrl];
        
        NSArray *payMethodDicListSource = [configDic validArrayValueForKey:PARA_PAYMENT_METHOD_PAYID];
        NSMutableArray * payMethodList = [NSMutableArray array];
        for (NSDictionary *one in payMethodDicListSource) {
            NSString *payId = [one validStringValueForKey:PARA_PAY_ID];
            NSString *payKey = [one validStringValueForKey:PARA_NAME];
            
            if ([@[PAY_METHOD_WEIXIN,PAY_METHOD_ALIPAY_CLIENT,PAY_METHOD_ALIPAY_WAP,PAY_METHOD_UNION_CLIENT] containsObject:payKey]) {
                PayMethod *method = [[PayMethod alloc] init] ;
                method.payId = payId;
                method.payKey = payKey;
                [payMethodList addObject:method];
            }
        }
        [manager setPayMethodList:payMethodList];

        NSDictionary *updateProfile = [configDic validDictionaryValueForKey:PARA_UPDATE_PROFILE];
        
        [manager setOnLineAppVersion:[updateProfile validStringValueForKey:PARA_IOS_APP_VERSION]];
        BOOL isMustUpdateApp = ([updateProfile validIntValueForKey:PARA_IS_FORCED] != 0);
        NSString *mustUpdateAppVersion = [updateProfile validStringValueForKey:PARA_LAST_VERSION];
        NSString *updateAppMessage = [updateProfile validStringValueForKey:PARA_MESSAGE];
        [manager setIsMustUpdateApp:isMustUpdateApp];
        [manager setMustUpdateAppVersion:mustUpdateAppVersion];
        [manager setUpdateAppMessage:updateAppMessage];
        
        [manager setInReviewVersion:[updateProfile validStringValueForKey:PARA_IOS_IN_REVIEW_VERSION]];
        [manager setCoachInReviewUrl:[updateProfile validStringValueForKey:PARA_COACH_IN_REVIEW_URL]];
        [manager setIsCheckNewVersion:[updateProfile validBoolValueForKey:PARA_IS_CHECK_NEW_VERSION]];
        [manager setIsShowThirdPartyLogin:[updateProfile validBoolValueForKey:PARA_IS_SHOW_THIRD_PARTY_LOGIN]];
        
        NSString *cityIdListString = [configDic validStringValueForKey:PARA_COACH_OPEN_CITY_IDS];
        [[BaseConfigManager defaultManager] setCoachOpenCityIdList:[cityIdListString componentsSeparatedByString:@","]];
    }
    
    NSDictionary *linkDic = [dataDic validDictionaryValueForKey:PARA_LINKS_MODULES];
    [[BaseConfigManager defaultManager] setCouponRuleUrl:[linkDic validStringValueForKey:PARA_COUPON_RULE_URL]];
    [[BaseConfigManager defaultManager] setCreditRuleUrl:[linkDic validStringValueForKey:PARA_CREDIT_RULE_URL]];
    [[BaseConfigManager defaultManager] setCoachRecruitUrl:[linkDic validStringValueForKey:PARA_COACH_RECRUIT_URL]];
    
    [[BaseConfigManager defaultManager] setGroupBuyUrl:[linkDic validStringValueForKey:PARA_GROUP_BUY_URL]];
    
    [[BaseConfigManager defaultManager] setNmqUrl:[linkDic validStringValueForKey:PARA_NMQ_URL]];
    [[BaseConfigManager defaultManager] setUserProtocolUrl:[linkDic validStringValueForKey:PARA_USER_PROTOCOL_URL]];
    
    [[BaseConfigManager defaultManager] setRefundRuleUrl:[linkDic validStringValueForKey:PARA_REFUND_RULE_URL]];
    [[BaseConfigManager defaultManager] setUserMoneyRuleUrl:[linkDic validStringValueForKey:PARA_USER_MONEY_RULE_URL]];
    [[BaseConfigManager defaultManager] setUserCardUrl:[linkDic validStringValueForKey:PARA_USER_CARD_URL]];
    [manager setSignInRuleUrl:[linkDic validStringValueForKey:PARA_SIGNIN_RULE_URL]];
    [manager setCourtJoinInstructionUrl:[linkDic validStringValueForKey:PARA_COURT_JOIN_INSTRUCTION_URL]];
    
    
    NSDictionary *keywordDic = [dataDic validDictionaryValueForKey:PARA_KEYWORD_MODULES];
    
    [[BaseConfigManager defaultManager] setRecommendDescription:[keywordDic validStringValueForKey:PARA_RECOMMEND_DESCRIPTION]];
    [[BaseConfigManager defaultManager] setRecommendRemark:[keywordDic validStringValueForKey:PARA_RECOMMEND_REMARK]];
    [[BaseConfigManager defaultManager] setCommentDescription:[keywordDic validStringValueForKey:PARA_COMMENT_DESCRIPTION]];
    
    [[BaseConfigManager defaultManager] setForumSearchDataVersion:[keywordDic validStringValueForKey:PARA_FORUM_SEARCH_DATA_VER]];
    
    //城市列表
    [[CityManager defaultManager] setCityList:[self parseCityList:[dataDic validArrayValueForKey:PARA_CITIES]]];
    
    //场馆的项目
    NSArray *categoryList = [dataDic validArrayValueForKey:PARA_CATEGORIES];
    NSMutableArray *categories = [NSMutableArray array];
    for (id dic in categoryList) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            BusinessCategory *category = [[BusinessCategory alloc] init] ;
            category.businessCategoryId  = [(NSDictionary *)dic validStringValueForKey:PARA_CATEGORY_ID];
            category.name = [(NSDictionary *)dic validStringValueForKey:PARA_CATEGORY_NAME];
            category.totalCount = [(NSDictionary *)dic validIntValueForKey:PARA_COUNT];
            category.canOrderCount = [(NSDictionary *)dic validIntValueForKey:PARA_CAN_ORDER_COUNT];
            category.imageUrl = [(NSDictionary *)dic validStringValueForKey:PARA_IMAGE_URL];
            category.activeImageUrl = [(NSDictionary *)dic validStringValueForKey:PARA_ACTIVE_IMAGE_URL];
            category.smallImageUrl = [(NSDictionary *)dic validStringValueForKey:PARA_SMALL_IMAGE_URL];
            [categories addObject:category];
        }
    }
    [[BusinessCategoryManager defaultManager] setDefaultAllCategories:categories];
    
    //运动圈的项目
    id projectListSource = [dataDic validArrayValueForKey:PARA_PROJECT];
    NSMutableArray *projectListTarget = [NSMutableArray array];
    if ([projectListSource isKindOfClass:[NSArray class]]) {
        for (id onePorjectSource in projectListSource) {
            if ([onePorjectSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            CircleProject *project = [[CircleProject alloc] init];
            project.proId = [onePorjectSource validStringValueForKey:PARA_PRO_ID];
            project.proName = [onePorjectSource validStringValueForKey:PARA_PRO_NAME];
            [projectListTarget addObject:project];
        }
        [[CircleProjectManager defaultManager] setCircleProjectList:projectListTarget];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_QUERY_STATIC_DATA object:nil userInfo:nil];
}

static int retryTimes = 0;
- (void)queryStaticData:(id<BaseServiceDelegate>)delegate
{
    if (self.isLoadingStaticData || retryTimes > 20) {
        return ;
    }
    self.isLoadingStaticData = YES;
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_STATIC_DATA forKey:PARA_ACTION];
    [inputDic setValue:@"2" forKey:PARA_FROM];
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [paths objectAtIndex:0];
        NSString *filtPath = [NSString stringWithFormat:@"%@/static_data.plist", documentDir];
        
        NSString *status = nil;
        BOOL isSuccess = NO;
        
        BOOL hasReadLocal = NO;

        status = [resultDictionary validStringValueForKey:PARA_STATUS];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            isSuccess = YES;
            retryTimes = 0;
            [resultDictionary writeToFile:filtPath atomically:YES];
            [self parseStaticData:resultDictionary];
        } else {
            if (hasReadLocal == NO) {
                hasReadLocal = YES;
                resultDictionary = [NSDictionary dictionaryWithContentsOfFile:filtPath];
                [self parseStaticData:resultDictionary];
            }
            
            [self performSelector:@selector(queryStaticData:) withObject:delegate afterDelay:(2+retryTimes)];
            retryTimes++;
        }
        
        self.isLoadingStaticData = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //开子线程下载搜索数据
            if ([status isEqualToString:STATUS_SUCCESS]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self saveSearchStaticData:resultDictionary];
                });
            }
            
            if ([delegate respondsToSelector:@selector(didQueryStaticData:resultDictionary:)]) {
                [delegate didQueryStaticData:status resultDictionary:resultDictionary];
            }
        });
    }];
}

- (void)saveSearchStaticData:(NSDictionary *)resultDictionary{
    NSString *cityID = [CityManager readCurrentCityId];
    NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
    NSArray *searchArray = [data validArrayValueForKey:VALUE_ACTION_SEARCH_STATIC_DATA];
    NSDictionary *searchDic = nil;
    for (NSDictionary *dic in searchArray) {
        NSString *searchCityID = [dic validStringValueForKey:PARA_CITY_ID];
        if ([searchCityID isEqualToString:cityID]) {
            searchDic = [NSDictionary dictionaryWithDictionary:dic];
        }
    }
    
    NSString *version = [searchDic validStringValueForKey:PARA_VERSION];
    NSString *zipFile = [searchDic validStringValueForKey:PARA_ZIPFILE];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:PARA_SEARCHCITYID] isEqualToString:cityID] || ![[[NSUserDefaults standardUserDefaults] objectForKey:PARA_SEARCHVERSION] isEqualToString:version]) {
        
        [[BusinessSearchDataManager defaultManager] DownloadTextFile:zipFile cityID:cityID];
        
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:PARA_SEARCHVERSION];
        [[NSUserDefaults standardUserDefaults] setObject:cityID forKey:PARA_SEARCHCITYID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

static int QydTokenRetryTimes = 0;
- (void)getQydTokenWithDevice:(NSString *)deviceId
                userId:(NSString *)userId
           loginEncode:(NSString *)loginEncode
                     complete:(void(^)(NSString *status,NSString* msg, int expireTime))complete{
    
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_QYD_TOKEN forKey:PARA_ACTION];
        [inputDic setValue:deviceId forKey:PARA_DEVICE_ID];
        
        if([userId length] > 0) {
            [inputDic setValue:userId forKey:PARA_USER_ID];
            [inputDic setValue:loginEncode forKey:PARA_LOGIN_ENCODE];
        }
        
//        //如有相同的进程正在请求，则忽略
//        if ([AppGlobalDataManager defaultManager].isProcessingToken == YES && QydTokenRetryTimes == 0) {
//            HDLog(@"is processing another token request");
//            return;
//        }
        
        //必须一一对应
        [AppGlobalDataManager defaultManager].isProcessingToken = YES;
            [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
                
                NSDictionary *resultDictionary = response.jsonResult;
                NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
                NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
                int expireTime = 3600;
                
                if ([status isEqualToString:STATUS_SUCCESS] || [status isEqualToString:STATUS_LOGIN_ENCODE_ERROR]) {
                    NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
                    NSString *token = [data validStringValueForKey:PARA_VALUE];
                    [AppGlobalDataManager defaultManager].qydToken = token;
                    
                    expireTime = [data validIntValueForKey:PARA_EXPIRES];
                    int serverTimeInt = [data validIntValueForKey:PARA_SERVER_TIME];
                    
                    if(serverTimeInt != 0) {
                        NSDate *localTime = [NSDate date];
                        NSDate *serverTime = [NSDate dateWithTimeIntervalSince1970:serverTimeInt];
                        double timeDifference = serverTime.timeIntervalSince1970 - localTime.timeIntervalSince1970;
                        HDLog(@"time diff:%@", [@(timeDifference) stringValue]);
                        if (timeDifference > 2 * 60 || timeDifference < - 20 * 60) { //误差超过2分钟，则记录误差
                            [[AppGlobalDataManager defaultManager] setTimeDifference:timeDifference];
                        } else {
                            [[AppGlobalDataManager defaultManager] setTimeDifference:0];
                        }
                    }
                    
                    //因为退出登录时需要调用接口，所以这里开始解封。通知会保证线程不会打断
                    [AppGlobalDataManager defaultManager].isProcessingToken = NO;
                    QydTokenRetryTimes = 0;
                } else {
                    QydTokenRetryTimes ++;
                    
                    // 没有网络或者重试次数超过15次
                    if (QydTokenRetryTimes > 15 || status == nil) {
                        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
                            [self getQydTokenWithDevice:deviceId userId:userId loginEncode:loginEncode complete:complete];
                    });
                }
                
                if([status isEqualToString:STATUS_LOGIN_ENCODE_ERROR]) {
                    //这里发通知才最快清空用户信息，此时拿到的token已经是退出登录的token
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_LOGIN_ENCODE_ERROR object:nil];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(complete){
                        complete(status,msg,expireTime);
                    }
                });
            }];
}

@end
