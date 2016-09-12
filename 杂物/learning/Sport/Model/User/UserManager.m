//
//  UserManager.m
//  Sport
//
//  Created by haodong  on 13-6-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "UserManager.h"
#import "OpenInfo.h"
#import "RongService.h"
#import "TipNumberManager.h"
#import "UserService.h"
#import "SportUUID.h"
#import "SNSManager.h"
#import "TypeConversion.h"
#import "XHCryptorTools.h"
#import "AppGlobalDataManager.h"
#import "CLLocation+Util.h"

@interface UserManager()
@property (strong, nonatomic) User *currentUser;

@property (strong, nonatomic) CLLocation *userLocation;

@end

#define KEY_SAVE_USER_INFO      @"KEY_SAVE_USER_INFO" //1.991开始弃用，改用KEY_SAVE_USER_INFO_S保存
#define KEY_SAVE_USER_INFO_A    @"KEY_SAVE_USER_INFO_A"

#define LOCAL_AES_KEY   @"j3iygn" //用于加密保存本地数据
#define LOCAL_AES_IV    [@"g7bu2j" dataUsingEncoding:NSUTF8StringEncoding] //用于加密保存本地数据

#define KEY_USER_ID          @"KEY_USER_ID"
#define KEY_PHONE_NUMBER     @"KEY_PHONE_NUMBER"
#define KEY_PASSWORD         @"KEY_PASSWORD"
#define KEY_PAY_PASSWORD      @"KEY_PAYPASSWORD"
#define KEY_NICKNAME         @"KEY_NICKNAME"
#define KEY_AVATAR_URL       @"KEY_AVATAR_URL"
#define KEY_LOGIN_ENCODE     @"KEY_LOGIN_ENCODE"
#define KEY_BIRTHDAY         @"KEY_BIRTHDAY"
#define KEY_GENDER           @"KEY_GENDER"
#define KEY_IM_PASSWORD      @"KEY_IM_PASSWORD"
#define KEY_OPEN_INFO_LIST   @"KEY_OPEN_INFO_LIST"
#define KEY_OPEN_TYPE        @"KEY_OPEN_TYPE"
#define KEY_OPEN_USER_ID     @"KEY_OPEN_USER_ID"
#define KEY_OPEN_NICK_NAME   @"KEY_OPEN_NICK_NAME"
#define KEY_FAVORITE_SPORT_ID_LIST  @"KEY_FAVORITE_SPORT_ID_LIST"
#define KEY_AGE                 @"KEY_AGE"
#define KEY_CITY_ID             @"KEY_CITY_ID"
#define KEY_CITY_NAME           @"KEY_CITY_NAME"
#define KEY_CITY_SIGNTURE       @"KEY_CITY_SIGNTURE"
#define KEY_APPOINTMENT_RATE    @"KEY_APPOINTMENT_RATE"
#define KEY_ACTIVITY_COUNT      @"KEY_ACTIVITY_COUNT"
#define KEY_LEMON_COUNT         @"KEY_LEMON_COUNT"
#define KEY_LIKE_SPORT          @"KEY_LIKE_SPORT"
#define KEY_LIKE_SPORT_LEVEL    @"KEY_LIKE_SPORT_LEVEL"
#define KEY_SPORT_PLAN          @"KEY_SPORT_PLAN"
#define KEY_HAS_PASSWORD        @"KEY_HAS_PASSWORD"
#define KEY_HAS_PAYPASSWORD     @"KEY_HAS_PAYPASSWORD"
#define KEY_USER_LOCATION       @"KEY_USER_LOCATION"
#define KEY_LATITUDE            @"KEY_LATITUDE"
#define KEY_LONGITUDE           @"KEY_LONGITUDE"
#define KEY_MONTH_CARD_INFO                 @"KEY_MONTH_CARD_INFO"
#define KEY_MONTH_CARD_ID                   @"KEY_MONTH_CARD_ID"
#define KEY_MONTH_CARD_NICK_NAME            @"KEY_MONTH_CARD_NICK_NAME"
#define KEY_MONTH_CARD_AVATAR_THUMB_URL     @"KEY_MONTH_CARD_AVATAR_THUMB_URL"
#define KEY_MONTH_CARD_AVATAR_ORIGINAL_URL  @"KEY_MONTH_CARD_AVATAR_ORIGINAL_URL"
#define KEY_MONTH_CARD_STATUS               @"KEY_MONTH_CARD_STATUS"
#define KEY_MONTH_CARD_END_TIME             @"KEY_MONTH_CARD_END_TIME"
#define KEY_RONG_ID             @"KEY_RONG_ID"
#define KEY_RONG_TOKEN          @"KEY_RONG_TOKEN"

#define KEY_LOGIN_ENCODE        @"KEY_LOGIN_ENCODE"
#define KEY_LOGIN_PHONE        @"KEY_LOGIN_PHONE"
#define KEY_PHONE_ENCODE       @"KEY_PHONE_ENCODE"

static UserManager *_globalUserManager = nil;

@implementation UserManager


+ (UserManager *)defaultManager
{
    if (_globalUserManager == nil) {
        _globalUserManager  = [[UserManager alloc] init];
    }
    return _globalUserManager;
}

- (BOOL)saveUserLocation:(CLLocation *)userLocation
{
    if (![userLocation isValid]) {
        return NO;
    }
    
    self.userLocation = userLocation;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"%f", userLocation.coordinate.latitude] forKey:KEY_LATITUDE];
        [dictionary setValue:[NSString stringWithFormat:@"%f", userLocation.coordinate.longitude] forKey:KEY_LONGITUDE];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:dictionary forKey:KEY_USER_LOCATION];
    });
    
    return YES;
}

- (CLLocation *)readUserLocation
{
    if (_userLocation == nil) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:KEY_USER_LOCATION];
        CLLocationDegrees latitude = [[dic valueForKey:KEY_LATITUDE] doubleValue];
        CLLocationDegrees longitude = [[dic valueForKey:KEY_LONGITUDE] doubleValue];
        
        if (latitude == 0 && longitude == 0) {
            return nil;
        }
        
        self.userLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude] ;
    }
    return _userLocation;
}

- (BOOL)saveCurrentUser:(User *)user
{
    self.currentUser = user;
    
    NSMutableDictionary *dic = nil;
    if (user) {
        dic = [NSMutableDictionary dictionary];
        [dic setValue:user.userId forKey:KEY_USER_ID];
        [dic setValue:user.phoneNumber forKey:KEY_PHONE_NUMBER];
        [dic setValue:user.phoneEncode forKey:KEY_PHONE_ENCODE];
        [dic setValue:user.password forKey:KEY_PASSWORD];
        [dic setValue:user.nickname forKey:KEY_NICKNAME];
        [dic setValue:user.avatarUrl forKey:KEY_AVATAR_URL];
        [dic setValue:user.birthday forKey:KEY_BIRTHDAY];
        [dic setValue:user.gender forKey:KEY_GENDER];
        [dic setValue:user.imPassword forKey:KEY_IM_PASSWORD];
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (OpenInfo *info in user.openInfoList) {
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            [infoDic setValue:info.openType forKey:KEY_OPEN_TYPE];
            [infoDic setValue:info.openUserId forKey:KEY_OPEN_USER_ID];
            [infoDic setValue:info.openNickname forKey:KEY_OPEN_NICK_NAME];
            [mutableArray addObject:infoDic];
        }
        [dic setValue:mutableArray forKey:KEY_OPEN_INFO_LIST];
        [dic setValue:user.favoriteSportIdList forKey:KEY_FAVORITE_SPORT_ID_LIST];
        
        [dic setValue:[NSString stringWithFormat:@"%d",(int)user.age] forKey:KEY_AGE];
        [dic setValue:user.cityId forKey:KEY_CITY_ID];
        [dic setValue:user.cityName  forKey:KEY_CITY_NAME];
        [dic setValue:user.signture  forKey:KEY_CITY_SIGNTURE];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)user.appointmentRate]  forKey:KEY_APPOINTMENT_RATE];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)user.activityCount] forKey:KEY_ACTIVITY_COUNT];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)user.lemonCount] forKey:KEY_LEMON_COUNT];
        [dic setValue:user.likeSport  forKey:KEY_LIKE_SPORT];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)user.likeSportLevel] forKey:KEY_LIKE_SPORT_LEVEL];
        [dic setValue:user.sportPlan forKey:KEY_SPORT_PLAN];
        [dic setValue:(user.hasPassWord ? @"1" : @"0") forKey:KEY_HAS_PASSWORD];
        [dic setValue:(user.hasPayPassWord ? @"1" : @"0") forKey:KEY_HAS_PAYPASSWORD];
        
        //月卡信息
        NSDictionary *monthCardInfoDic = [NSMutableDictionary dictionary];
        [monthCardInfoDic setValue:user.monthCard.cardId forKey:KEY_MONTH_CARD_ID];
        [monthCardInfoDic setValue:user.monthCard.nickName forKey:KEY_MONTH_CARD_NICK_NAME];
        [monthCardInfoDic setValue:user.monthCard.avatarThumbURL forKey:KEY_MONTH_CARD_AVATAR_ORIGINAL_URL];
        [monthCardInfoDic setValue:user.monthCard.avatarImageURL forKey:KEY_MONTH_CARD_AVATAR_THUMB_URL];
        [monthCardInfoDic setValue:[@(user.monthCard.cardStatus) stringValue] forKey:KEY_MONTH_CARD_STATUS];
        [monthCardInfoDic setValue:[@([user.monthCard.endTime timeIntervalSince1970]) stringValue] forKey:KEY_MONTH_CARD_END_TIME];
        [dic setValue:monthCardInfoDic forKey:KEY_MONTH_CARD_INFO];
        
        //融云ID
        [dic setValue:user.rongId forKey:KEY_RONG_ID];
        [dic setValue:user.rongToken forKey:KEY_RONG_TOKEN];
    }
    
    return [self secretSetDictionary:dic forKey:KEY_SAVE_USER_INFO_A];
}

- (User *)readCurrentUser
{
    if (_currentUser == nil) {
        
        NSDictionary *dic = nil;
        dic = [[NSUserDefaults standardUserDefaults] valueForKey:KEY_SAVE_USER_INFO];//读取旧版数据
        if (dic) {
            if ([self secretSetDictionary:dic forKey:KEY_SAVE_USER_INFO_A]) {//用新版保存数据
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_SAVE_USER_INFO];//删除旧版数据
            }
        } else {
            dic = [self secretDictionaryForKey:KEY_SAVE_USER_INFO_A];
        }
        
        
        User *user = nil;
        if (dic) {
            user = [[User alloc] init] ;
            user.userId = [dic valueForKey:KEY_USER_ID];
            user.phoneNumber = [dic valueForKey:KEY_PHONE_NUMBER];
            user.phoneEncode = [dic valueForKey:KEY_PHONE_ENCODE];
            user.password = [dic valueForKey:KEY_PASSWORD];
            user.nickname = [dic valueForKey:KEY_NICKNAME];
            user.avatarUrl = [dic valueForKey:KEY_AVATAR_URL];
            user.birthday = [dic valueForKey:KEY_BIRTHDAY];
            user.gender = [dic valueForKey:KEY_GENDER];
            user.imPassword = [dic valueForKey:KEY_IM_PASSWORD];
            
            NSMutableArray *mutableArray = [NSMutableArray array];
            NSArray *openInfoList = [dic objectForKey:KEY_OPEN_INFO_LIST];
            for (NSDictionary *infoDic in openInfoList) {
                OpenInfo *info = [[OpenInfo alloc] init];
                info.openType = [infoDic valueForKey:KEY_OPEN_TYPE];
                info.openUserId = [infoDic valueForKey:KEY_OPEN_USER_ID];
                info.openNickname = [infoDic valueForKey:KEY_OPEN_NICK_NAME];
                [mutableArray addObject:info];
            }
            user.openInfoList = mutableArray;
            
            user.favoriteSportIdList = (NSArray *)[dic objectForKey:KEY_FAVORITE_SPORT_ID_LIST];
            
            user.age = [[dic valueForKey:KEY_AGE] integerValue];
            user.cityId = [dic valueForKey:KEY_CITY_ID];
            user.cityName = [dic valueForKey:KEY_CITY_NAME];
            user.signture = [dic valueForKey:KEY_CITY_SIGNTURE];
            user.appointmentRate = [[dic valueForKey:KEY_APPOINTMENT_RATE] integerValue];
            user.activityCount = [[dic valueForKey:KEY_ACTIVITY_COUNT] integerValue];
            user.lemonCount = [[dic valueForKey:KEY_LEMON_COUNT] integerValue];
            user.likeSport = [dic valueForKey:KEY_LIKE_SPORT];
            user.likeSportLevel = [[dic valueForKey:KEY_LIKE_SPORT_LEVEL] integerValue];
            user.sportPlan = [dic valueForKey:KEY_SPORT_PLAN];
            user.hasPassWord = [[dic valueForKey:KEY_HAS_PASSWORD] isEqualToString:@"1"];
            user.hasPayPassWord = [[dic valueForKey:KEY_HAS_PAYPASSWORD] isEqualToString:@"1"];
            
            //解析月卡信息
            NSDictionary *monthCardInfoDic = [dic objectForKey:KEY_MONTH_CARD_INFO];
            MonthCard *monthCard =[[MonthCard alloc] init] ;
            monthCard.cardId = [monthCardInfoDic valueForKey:KEY_MONTH_CARD_ID];
            monthCard.nickName = [monthCardInfoDic valueForKey:KEY_MONTH_CARD_NICK_NAME];
            monthCard.avatarThumbURL = [monthCardInfoDic valueForKey:KEY_MONTH_CARD_AVATAR_THUMB_URL];
            monthCard.avatarImageURL = [monthCardInfoDic valueForKey:KEY_MONTH_CARD_AVATAR_ORIGINAL_URL];
            monthCard.cardStatus = (int)[[monthCardInfoDic valueForKey:KEY_MONTH_CARD_STATUS] integerValue];
            monthCard.endTime = [NSDate dateWithTimeIntervalSince1970:[[monthCardInfoDic valueForKey:KEY_MONTH_CARD_END_TIME] integerValue]];
            user.monthCard = monthCard;
            
            user.rongId = [dic valueForKey:KEY_RONG_ID];
            user.rongToken = [dic valueForKey:KEY_RONG_TOKEN];
        }
        self.currentUser = user;
    }
    return _currentUser;
}

- (void)clearCurrentUser
{
    [self saveCurrentUser:nil];
}

- (BOOL)secretSetDictionary:(NSDictionary *)dic forKey:(NSString *)key
{
    NSString *string = [TypeConversion toStringFromDictionary:dic];
    NSString *ciphertext = (string ? [XHCryptorTools AESEncryptString:string keyString:LOCAL_AES_KEY iv:LOCAL_AES_IV] : nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:ciphertext forKey:key];
    return [defaults synchronize];
}

- (NSDictionary *)secretDictionaryForKey:(NSString *)key
{
    NSString *ciphertext = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    NSString *string = (ciphertext ? [XHCryptorTools AESDecryptString:ciphertext keyString:LOCAL_AES_KEY iv:LOCAL_AES_IV] : nil);
    NSDictionary *dic = [TypeConversion toDictionaryFromString:string];
    return dic;
}

+ (BOOL)isLogin{
    return ([[[UserManager defaultManager] readCurrentUser].userId length] > 0);
}

#define KEY_PUSH_TOKEN @"KEY_PUSH_TOKEN"
+ (void)savePushToken:(NSString *)pushToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:pushToken forKey:KEY_PUSH_TOKEN];
    [userDefaults synchronize];
}

+ (NSString *)readPushToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pushToken = [userDefaults objectForKey:KEY_PUSH_TOKEN];
    return pushToken;
}

#define KEY_HAS_UPLOAD_PUSH_TOKEN @"KEY_HAS_UPLOAD_PUSH_TOKEN"
+ (void)saveHasUploadPushToken:(BOOL)hasUploadPushToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:hasUploadPushToken forKey:KEY_HAS_UPLOAD_PUSH_TOKEN];
    [userDefaults synchronize];
}

+ (BOOL)readHasUploadPushToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:KEY_HAS_UPLOAD_PUSH_TOKEN];
}

#define KEY_HAS_UPLOAD_DEVICE_ID @"KEY_HAS_UPLOAD_DEVICE_ID"
+ (void)saveHasUploadDeviceId:(BOOL)hasUploadDeviceId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:hasUploadDeviceId forKey:KEY_HAS_UPLOAD_DEVICE_ID];
    [userDefaults synchronize];
}

+ (BOOL)readHasUploadDeviceId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:KEY_HAS_UPLOAD_DEVICE_ID];
}

+ (void)saveLoginEncode:(NSString *)loginEncode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:loginEncode forKey:KEY_LOGIN_ENCODE];
        [userDefaults synchronize];
    });
}

+ (NSString *)readLoginEncode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_LOGIN_ENCODE];
}

#define HAS_SHOW_FIRST_LOGIN_PAGE @"HAS_SHOW_FIRST_LOGIN_PAGE"
+ (void)hasShowFirstLoginPage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:HAS_SHOW_FIRST_LOGIN_PAGE];
        [userDefaults synchronize];
    });
}

+ (BOOL)getFirstLoginPage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:HAS_SHOW_FIRST_LOGIN_PAGE];
}

+ (void)didLoginSuccessWithPhoneNumber:(NSString *) phoneNumber
{
    [self hasShowFirstLoginPage];
    [[RongService defaultService] connectRongIM];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user == nil || user.userId == nil) {
        HDLog(@"Not login.");
        return;
    }
    
    [self saveLoginPhone:phoneNumber];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_DID_LOG_IN object:nil];
    
}

+ (void)didLogOut
{
    [[UserManager defaultManager] saveCurrentUser:nil];
    [SNSManager saveSinaAccessToken:nil];
    
    //清空提示信息
    [[TipNumberManager defaultManager] clearAllCount];

    [[RongService defaultService] disconnect];
    
    [self saveLoginEncode:nil];

    //一定要在清空用户信息之后才更新token, log out的时候会调用网络接口
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_DID_LOG_OUT object:nil userInfo:nil];
}

//登录时记录电话号码
+ (void)saveLoginPhone:(NSString *)phone
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:phone forKey:KEY_LOGIN_PHONE];
        [userDefaults synchronize];
    });
}

+ (NSString *)readLoginPhone
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY_LOGIN_PHONE];
}

#define KEY_IS_CLICKED_SURVEY @"KEY_IS_CLICKED_SURVEY"

+ (void)saveIsClickedSurvey:(BOOL)isClickedSurvey
{
    [[TipNumberManager defaultManager] setIsShowSurveyTips:!isClickedSurvey];
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:KEY_IS_CLICKED_SURVEY];
    [userDefaults synchronize];
}

+ (BOOL)readIsClickedSurvey
{
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    BOOL isClickedSurvey = [userDefaults boolForKey:KEY_IS_CLICKED_SURVEY];
    return isClickedSurvey;
}

@end
