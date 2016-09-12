//
//  MainService.m
//  Sport
//
//  Created by xiaoyang on 16/6/8.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "MainService.h"
#import "GSNetwork.h"
#import "SportAd.h"
#import "BusinessCategory.h"
#import "BusinessCategoryManager.h"
#import "BusinessManager.h"
#import "CourtJoin.h"
#import "SignIn.h"
#import "MainControllerCategory.h"
#import "CourtJoinService.h"
#import "SignInWeeklyModel.h"
#import "CityManager.h"


@implementation MainService
+ (void)queryIndex:(id<MainServiceDelegate>)delegate
          UserId:(NSString *)userId
          cityId:(NSString *)cityId
        latitude:(NSString *)latitude
         longitude:(NSString *)longitude
          categoryId:(NSString *)categoryId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_INDEX forKey:PARA_ACTION];
    [inputDic setValue:latitude forKey:PARA_LATITUDE];
    [inputDic setValue:longitude forKey:PARA_LONGITUDE];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [inputDic setValue:categoryId forKey:PARA_CAT_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
       
        //总共要接收的数据
        NSMutableArray *adList = [NSMutableArray array];
        NSMutableArray *businessList = [NSMutableArray array];
        NSMutableArray *courtJoinList = [NSMutableArray array];
//        NSString *daySignInStatus = nil;
//        NSMutableArray *fourWeekSignInList = [NSMutableArray array];
        MainControllerCategory *mainControllerCategory = [[MainControllerCategory alloc] init];
        
        //记录网络请求的日期
        mainControllerCategory.createTime = [NSDate date];
        //广告
        NSArray *list1 = [data validArrayValueForKey:PARA_AD_LIST];
        for (id one in list1) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            SportAd *ad = [[SportAd alloc] init];
            ad.adId = [one validStringValueForKey:PARA_AD_ID];
            ad.adLink = [one validStringValueForKey:PARA_AD_LINK];
            ad.adName = [one validStringValueForKey:PARA_AD_NAME];
            ad.imageUrl = [one validStringValueForKey:PARA_IMAGE_URL];
            
            [adList addObject:ad];
        
        }
        if ([status isEqualToString:STATUS_SUCCESS]) {
            //如果没有banner，则补一张默认banner图
            if ([adList count] == 0) {
                SportAd *ad = [[SportAd alloc] init];
                ad.adId = nil;
                ad.adLink = nil;
                ad.adName = nil;
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"default_banner_image.png" ofType:nil];
                ad.imageUrl = [NSString stringWithFormat:@"file://%@", filePath];
                [adList addObject:ad];
            }
        }
                
        //首页推荐场馆
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
        mainControllerCategory.willShowCategoryList = [NSMutableArray array];
        mainControllerCategory.categoryList = [NSMutableArray array];
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
            
             //默认选择的项目
            if (![categoryId isEqualToString:@"-1"] && [one validBoolValueForKey:PARA_IS_CHOOSE_CATEGORY]) {
                mainControllerCategory.currentSelectedCategoryId = category.businessCategoryId;
                mainControllerCategory.currentSelectedCategoryName = category.name;
            }
            
            //要显示的category
            if ([one validBoolValueForKey:PARA_IS_INDEX_CATEGORY]) {
               
                [mainControllerCategory.willShowCategoryList addObject:category];
            }
            
            [mainControllerCategory.categoryList addObject:category];
        }
        
        if (mainControllerCategory.willShowCategoryList.count == 0 || [categoryId isEqualToString:@"-1"]){
            mainControllerCategory.currentSelectedCategoryId = @"-1";
            mainControllerCategory.currentSelectedCategoryName =@"全部";
        }
        
        
        BusinessCategoryManager *manager = [BusinessCategoryManager defaultManager];
        if (![cityId isEqualToString:manager.currentRecordCityId]
            || [manager.currentAllCategories count] <= 0) {
            [manager setCurrentRecordCityId:cityId];
            [manager setCurrentAllCategories:mainControllerCategory.categoryList];
        }
        
        //首页球局列表
        NSArray *list4 = [data validArrayValueForKey:PARA_COURT_JOIN_LIST];
        for (id one in list4) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            
              CourtJoin *courtJoin = [CourtJoinService courtJoinByOneCourtJoinDictionary:one];

            [courtJoinList addObject:courtJoin];

        }

        //打卡
        NSDictionary *signInDict = [data validDictionaryValueForKey:PARA_SIGN_IN];
        SignIn *signIn = [[SignIn alloc] init];
        signIn.versionSignInStatus = [signInDict validIntValueForKey:PARA_VERSION_SIGN_IN_STATUS];
        signIn.daySignInStatus = [signInDict validIntValueForKey:PARA_DAY_SIGNIN_STATUS];
        
        NSArray *weeklySignInArray = [signInDict validArrayValueForKey:PARA_FOUR_WEEK_SIGNIN];
        NSMutableArray *signInWeeklyModelArray = [NSMutableArray array];
        for (NSDictionary *dict in weeklySignInArray) {
            SignInWeeklyModel *signInWeeklyModel = [[SignInWeeklyModel alloc] init];
            signInWeeklyModel.weekSignInTimes = [dict validIntValueForKey:PARA_WEEK_SIGNIN_TIMES];
            signInWeeklyModel.weekName = [dict validStringValueForKey:PARA_WEEK_NAME];
            [signInWeeklyModelArray addObject:signInWeeklyModel];
        }
        signIn.fourWeekSignInList = [NSArray arrayWithArray:signInWeeklyModelArray];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryIndexWithAdList:mainControllerCategory:businessList:courtJoinList:signIn:currentCityId:status:msg:)]){
                
                [delegate didQueryIndexWithAdList:(NSArray *)adList
                                     mainControllerCategory:(MainControllerCategory *)mainControllerCategory
                                               businessList:(NSArray *)businessList
                                              courtJoinList:(NSArray *)courtJoinList
                                                     signIn:(SignIn *)signIn
                                              currentCityId:(NSString *)cityId
                                                     status:(NSString *)status
                                                        msg:(NSString *)msg];
            }
        });
    }];
}
@end
