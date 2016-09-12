//
//  UserService.m
//  Sport
//
//  Created by haodong  on 13-6-6.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "UserService.h"
#import "RegisterManager.h"
#import "UserManager.h"
#import "DDBase64.h"
#import "SNSManager.h"
#import "TipNumberManager.h"
#import "DesUtil.h"
#import "NSString+Utils.h"
#import "SystemNoticeMessage.h"
#import "SystemNoticeMessageManager.h"
#import "TipNumberManager.h"
#import "Voucher.h"
#import "Business.h"
#import "MoneyRecord.h"
#import "Forum.h"
#import "Post.h"
#import "RongService.h"
#import "SystemMessage.h"
#import "AppGlobalDataManager.h"
#import "AppDelegate.h"
#import "GSNetwork.h"

@implementation UserService

+ (void)registerUser:(id<UserServiceDelegate>)delegate
         phoneNumber:(NSString *)phoneNumber
            password:(NSString *)password
             smsCode:(NSString *)smsCode
{
        //send
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_PHONE_REGISTER forKey:PARA_ACTION];
        [inputDic setValue:phoneNumber forKey:PARA_PHONE];
        [inputDic setValue:@"2.0" forKey:PARA_VER]; //2015-07-27改成DES加密
        [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
        
        [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
        //[inputDic setValue:[DDBase64 encodeBase64String:password] forKey:PARA_PASSWORD];
        
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        //HDLog(@"<registerUser> %@", resultDictionary);
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSString *userId = [data validStringValueForKey:PARA_USER_ID];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didRegisterUser:status:msg:)]) {
                [delegate didRegisterUser:userId status:status msg:msg];
            }
        });
    }];
}

+ (void)unionLogin:(id<UserServiceDelegate>)delegate
            openId:(NSString *)openId
           unionId:(NSString *)unionId
       accessToken:(NSString *)accessToken
          openType:(NSString *)openType
          nickName:(NSString *)nickName
            gender:(NSString *)gender
            avatar:(NSString *)avatar
{
   
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UNION_LOGIN forKey:PARA_ACTION];
    [inputDic setValue:openId forKey:PARA_OPEN_ID];
    [inputDic setValue:accessToken forKey:PARA_ACCESS_TOKEN];
    [inputDic setValue:openType forKey:PARA_OPEN_TYPE];
    
    if (unionId.length > 0) {
        [inputDic setValue:unionId forKey:PARA_UNION_ID];
    }
    if (nickName.length > 0) {
        [inputDic setValue:nickName forKey:PARA_NICK_NAME];
    }

    //2016-6-15 用2.0接口
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    //必须一一对应
    [AppGlobalDataManager defaultManager].isProcessingToken = YES;
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        User *user = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            if ([data validStringValueForKey:PARA_PHONE].length > 0) {
                user = [UserService userByDictionary:data];
                [[UserManager defaultManager] saveCurrentUser:user];
                
                NSString *loginEncode = [data validStringValueForKey:PARA_LOGIN_ENCODE];
                [UserManager saveLoginEncode:loginEncode];
            }
        }
        
        //必须一一对应
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUnionLogin:msg:data:openId:unionId:accessToken:openType:avatar:nickName:gender:)]) {
                [delegate didUnionLogin:status msg:msg data:data openId:openId unionId:unionId accessToken:accessToken openType:openType avatar:avatar nickName:nickName gender:gender];
            }
        });
    }];
}

+ (void)unionPhone:(id<UserServiceDelegate>)delegate phoneNum:(NSString *)phoneNum smsCode:(NSString *)smsCode openId:(NSString *)openId unionId:(NSString *)unionId accessToken:(NSString *)accessToken openType:(NSString *)openType avatar:(NSString *)avatar nickName:(NSString *)nickName gender:(NSString *)gender {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UNION_PHONE forKey:PARA_ACTION];
    [inputDic setValue:phoneNum forKey:PARA_PHONE];
    [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
    //2016-06-15 迁移到2.0
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [inputDic setValue:openId forKey:PARA_OPEN_ID];
    [inputDic setValue:accessToken forKey:PARA_ACCESS_TOKEN];
    [inputDic setValue:openType forKey:PARA_OPEN_TYPE];
    if (avatar.length > 0) {
       [inputDic setValue:avatar forKey:PARA_AVATAR];
    }
    if (nickName.length > 0) {
        [inputDic setValue:nickName forKey:PARA_NICK_NAME];
    }
    if (gender.length > 0) {
        [inputDic setValue:gender forKey:PARA_GENDER];
    }
    
    if (unionId.length > 0) {
        [inputDic setValue:unionId forKey:PARA_UNION_ID];
    }
    
    //必须一一对应
    [AppGlobalDataManager defaultManager].isProcessingToken = YES;
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;

        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSString *umengString;
        User *user = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            user = [UserService userByDictionary:data];
            [[UserManager defaultManager] saveCurrentUser:user];
            
            NSString *loginEncode = [data validStringValueForKey:PARA_LOGIN_ENCODE];
            [UserManager saveLoginEncode:loginEncode];
            umengString = @"登陆成功";
        } else {
            umengString = @"登陆失败";
        }
        //友盟统计
        if ([openType isEqualToString:@"wx"]) {
            [MobClickUtils event:umeng_event_login_for_wx label:umengString];
        } else if ([openType isEqualToString:@"qq"]){
            [MobClickUtils event:umeng_event_login_for_qq label:umengString];
        } else if ([openType isEqualToString:@"sina"]) {
            [MobClickUtils event:umeng_event_login_for_sina label:umengString];
        }
        //必须一一对应
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUnionPhone:msg:)]) {
                [delegate didUnionPhone:status msg:msg];
            }
        });
    }];
}

+ (void)bindPhone:(id<UserServiceDelegate>)delegate
           userId:(NSString *)userId
      phoneNumber:(NSString *)phoneNumber
         password:(NSString *)password
          smsCode:(NSString *)smsCode
{
    //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_BIND_PHONE forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:phoneNumber forKey:PARA_PHONE];
    //2015-07-27改成DES加密
    //2016-06-15 迁移到2.0
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
    
    [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
    //[inputDic setValue:[DDBase64 encodeBase64String:password] forKey:PARA_PASSWORD];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
        //HDLog(@"<bindPhone> %@", resultDictionary);
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            User *user = [[UserManager defaultManager] readCurrentUser];
            user.phoneNumber = phoneNumber;
            [[UserManager defaultManager] saveCurrentUser:user];
            [MobClickUtils event:umeng_event_bind_for_phone label:@"绑定成功"];
        }else {
            [MobClickUtils event:umeng_event_bind_for_phone label:@"绑定失败"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didBindPhone:)]) {
                [delegate didBindPhone:status];
            }
        });
    }];
}


+ (void)unionBind:(id<UserServiceDelegate>)delegate userId:(NSString *)userId openId:(NSString *)openId unionId:(NSString *)unionId accessToken:(NSString *)accessToken openType:(NSString *)openType nickName:(NSString *)nickName {

    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UNION_BIND forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:openId forKey:PARA_OPEN_ID];
    [inputDic setValue:accessToken forKey:PARA_ACCESS_TOKEN];
    [inputDic setValue:openType forKey:PARA_OPEN_TYPE];
    [inputDic setValue:nickName forKey:PARA_NICK_NAME];
    
    if (unionId.length > 0) {
        [inputDic setValue:unionId forKey:PARA_UNION_ID];
    }
    
    [inputDic setValue:@"2.0" forKey:PARA_VER]; //2015-07-27改成DES加密
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        //友盟统计
        NSString *umengString;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            umengString = @"绑定成功";
        }else {
            umengString = @"绑定失败";
        }
        if ([openType isEqualToString:@"wx"]) {
            [MobClickUtils event:umeng_event_bind_for_wx label:umengString];
        } else if ([openType isEqualToString:@"qq"]){
            [MobClickUtils event:umeng_event_bind_for_qq label:umengString];
        } else if ([openType isEqualToString:@"sina"]) {
            [MobClickUtils event:umeng_event_bind_for_sina label:umengString];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUnionBindWithStatus:msg:)]) {
                [delegate didUnionBindWithStatus:status msg:msg];
            }
        });
    }];
     
}

+ (User *)userByDictionary:(NSDictionary *)resultDictionary
{
    User *user = [[User alloc] init] ;
    
    NSDictionary *myRulesDict = [resultDictionary validDictionaryValueForKey:PARA_MY_RULES];
    user.rulesTitle = [myRulesDict validStringValueForKey:PARA_RULES_TITLE];
    user.rulesLevel = [myRulesDict validStringValueForKey:PARA_RULES_LEVEL];
    user.rulesUrl = [myRulesDict validStringValueForKey:PARA_RULES_DETAIL_URL];
    user.rulesIsDisplay = [myRulesDict validStringValueForKey:PARA_RULES_IS_DISPLAY];
    user.rulesIconUrl = [myRulesDict validStringValueForKey:PARA_RULES_ICON_URL];
    
    user.userId = [resultDictionary validStringValueForKey:PARA_USER_ID];
    user.phoneNumber = [resultDictionary validStringValueForKey:PARA_PHONE];
    user.phoneEncode = [resultDictionary validStringValueForKey:PARA_PHONE_ENCODE];
    user.nickname = [resultDictionary validStringValueForKey:PARA_NICK_NAME];

    NSString *birthdayString = [resultDictionary validStringValueForKey:PARA_BIRTHDAY];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *birthday = [dateFormatter dateFromString:birthdayString];
    user.birthday = birthday;
    
    user.gender = [resultDictionary validStringValueForKey:PARA_GENDER];
    user.avatarUrl = [resultDictionary validStringValueForKey:PARA_AVATAR];
    user.avatarBigUrl = [resultDictionary validStringValueForKey:PARA_AVATAR_ORIGINAL];
    
    user.age = [resultDictionary validIntValueForKey:PARA_AGE];
    user.cityName = [resultDictionary validStringValueForKey:PARA_CITY_NAME];
    user.signture = [resultDictionary validStringValueForKey:PARA_SIGNATURE];
    user.appointmentRate = [resultDictionary validIntValueForKey:PARA_APPOINTMENT_RATE];
    user.activityCount = [resultDictionary validIntValueForKey:PARA_APPOINTMENT_TOTAL];
    user.lemonCount = [resultDictionary validIntValueForKey:PARA_INTEGRAL];
    user.likeSport = [resultDictionary validStringValueForKey:PARA_INTERESTED_SPORT];
    user.likeSportLevel = [resultDictionary validIntValueForKey:PARA_INTERESTED_SPORT_LEVEL];
    user.sportPlan = [resultDictionary validStringValueForKey:PARA_SPORT_PLAN];
    
    NSMutableArray *albumListTarget = [NSMutableArray array];
    id albumListSource = [resultDictionary validArrayValueForKey:PARA_GALLERY];
    if ([albumListSource isKindOfClass:[NSArray class]]) {
        for (id one in albumListSource) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            UserPhoto *photo = [[UserPhoto alloc] init] ;
            photo.photoId = [one validStringValueForKey:PARA_ID];
            photo.photoThumbUrl = [one validStringValueForKey:PARA_THUMB_URL];
            photo.photoImageUrl = [one validStringValueForKey:PARA_IMAGE_URL];
            [albumListTarget addObject:photo];
        }
    }
    user.albumList = albumListTarget;
    
    
    NSMutableArray *equipmentListTarget = [NSMutableArray array];
    id equipmentListSource = [resultDictionary validArrayValueForKey:PARA_EQUIPMENT];
    if ([equipmentListSource isKindOfClass:[NSArray class]]) {
        for (id one in equipmentListSource) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            UserPhoto *photo = [[UserPhoto alloc] init] ;
            photo.photoId = [one validStringValueForKey:PARA_ID];
            photo.photoThumbUrl = [one validStringValueForKey:PARA_THUMB_URL];
            photo.photoImageUrl = [one validStringValueForKey:PARA_IMAGE_URL];
            [equipmentListTarget addObject:photo];
        }
    }
    user.equipmentList = equipmentListTarget;
    
    id activityObject = [resultDictionary validDictionaryValueForKey:PARA_ACTIVITY];
    if ([activityObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *activityDic = (NSDictionary *)activityObject;
        Activity *activity = [[Activity alloc] init] ;
        activity.activityId = [activityDic validStringValueForKey:PARA_ACT_ID];
        activity.proName = [activityDic validStringValueForKey:PARA_PRO_NAME];
        activity.startTime = [NSDate dateWithTimeIntervalSince1970:[activityDic validIntValueForKey:PARA_ACT_TIME]];
        activity.address = [activityDic validStringValueForKey:PARA_ACT_ADDRESS];
        user.currentActivity = activity;
    }
    
    NSMutableArray *openInfoListTarget = [NSMutableArray array];
    id openInfoListSource = [resultDictionary validArrayValueForKey:PARA_OPEN_INFO];
    if ([openInfoListSource isKindOfClass:[NSArray class]]) {
        for (id infoSource in openInfoListSource) {
            if ([infoSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            OpenInfo *infoTarget = [[OpenInfo alloc] init];
            infoTarget.openType = [infoSource validStringValueForKey:PARA_OPEN_TYPE];
            infoTarget.openUserId = [infoSource validStringValueForKey:PARA_OPEN_USER_ID];
            infoTarget.openNickname = [infoSource validStringValueForKey:PARA_OPEN_NICK_NAME];
            [openInfoListTarget addObject:infoTarget];
        }
    }
    
    NSMutableArray *favoriteSportIdListTarget = [NSMutableArray array];
    id favoriteSportsSource = [resultDictionary validArrayValueForKey:PARA_FAVORITE_SPORTS];
    if ([favoriteSportsSource isKindOfClass:[NSArray class]]) {
        for (id sportSource in favoriteSportsSource) {
            if ([sportSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            NSString *sportId=[sportSource validStringValueForKey:PARA_CATEGORY_ID];
            [favoriteSportIdListTarget addObject:sportId];
        }
    }

    user.openInfoList = openInfoListTarget;
    user.favoriteSportIdList = favoriteSportIdListTarget;
    
    user.point = [resultDictionary validIntValueForKey:PARA_CREDIT];
    
    NSMutableArray *beenCourtListTarget = [NSMutableArray array];
    id beenCourtListSource = [resultDictionary validArrayValueForKey:PARA_BEEN_COURT_LIST];
    if ([beenCourtListSource isKindOfClass:[NSArray class]]) {
        for (id beenCourtSource in beenCourtListSource) {
            if ([beenCourtSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            
            Business *business = [[Business alloc] init] ;
            business.businessId = [beenCourtSource validStringValueForKey:PARA_BUSINESS_ID];
            business.defaultCategoryId = [beenCourtSource validStringValueForKey:PARA_CATEGORY_ID];
            business.name = [beenCourtSource validStringValueForKey:PARA_NAME];
            //business.neighborhood = [beenCourtSource validStringValueForKey:PARA_SUB_REGION];
            business.neighborhood = [beenCourtSource validStringValueForKey:PARA_SUB_REGION_NAME];
            business.playHourCount = [beenCourtSource validIntValueForKey:PARA_HOUR_CNT];
            
            [beenCourtListTarget addObject:business];
        }
    }
    user.businessHistoryList = beenCourtListTarget;
    
    user.hasPassWord = ([resultDictionary validIntValueForKey:PARA_IS_SETPASSWORD] != 0);
    user.hasPayPassWord = ([resultDictionary validIntValueForKey:PARA_IS_SET_PAYPASSWORD] != 0);
    
    //圈子信息
    NSMutableArray *forumList = [NSMutableArray array];
    for (NSDictionary *one in [resultDictionary validArrayValueForKey:PARA_BEEN_COTERIE]) {
        Forum *forum = [[Forum alloc] init] ;
        forum.forumId = [one validStringValueForKey:PARA_COTERIE_ID];
        forum.forumName = [one validStringValueForKey:PARA_COTERIE_NAME];
        forum.imageUrl = [one validStringValueForKey:PARA_COVER_IMG];
        [forumList addObject:forum];
    }
    user.oftenGoToForumList = forumList;
    NSDictionary *postDic = [resultDictionary validDictionaryValueForKey:PARA_POST];
    if (postDic) {
        user.lastPost = [[Post alloc] init] ;
        user.lastPost.postId = [postDic validStringValueForKey:PARA_POST_ID];
        user.lastPost.coverImageUrl = [postDic validStringValueForKey:PARA_THUMB_URL];
        user.lastPost.content = [postDic validStringValueForKey:PARA_CONTENT];
        user.postCount = [postDic validIntValueForKey:PARA_USER_POST_COUNT];
    }
    
    user.balance = [resultDictionary validDoubleValueForKey:PARA_USER_MONEY];
    user.rongToken = [resultDictionary validStringValueForKey:PARA_IM_TOKEN];
    user.rongId = [resultDictionary validStringValueForKey:PARA_USER_RONG_ID];
    
    [self parseAccessToken:resultDictionary];
    
    return user;
}

+ (void)login:(id<UserServiceDelegate>)delegate
  phoneNumber:(NSString *)phoneNumber
     password:(NSString *)password
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_LOGIN forKey:PARA_ACTION];
    [inputDic setValue:phoneNumber forKey:PARA_PHONE];
    [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
    //[inputDic setValue:[DDBase64 encodeBase64String:password] forKey:PARA_PASSWORD];
   
    //2015-07-27改成DES加密
    //2016-6-15 用2.0接口
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    //必须一一对应
    [AppGlobalDataManager defaultManager].isProcessingToken = YES;
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
      
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        User *user = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            user = [UserService userByDictionary:data];
            [[UserManager defaultManager] saveCurrentUser:user];
            
            NSString *loginEncode = [data validStringValueForKey:PARA_LOGIN_ENCODE];
            [UserManager saveLoginEncode:loginEncode];

        } else {
            if ([msg length] == 0 ) {
                msg = @"网络有点问题，请稍后重试";
            }
        }
        
        //必须一一对应
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didLogin:status:msg:phone:)]) {
                [delegate didLogin:user.userId status:status msg:msg phone:phoneNumber];
            }
        });
    }];
}

+ (void)logout:(id<UserServiceDelegate>)delegate
        userId:(NSString *)userId
{
        //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_LOGOUT forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [AppGlobalDataManager defaultManager].isProcessingToken = YES;

    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        [self parseAccessToken:data];
        
        //这里就要解除isProcessingToken
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
        //执行退出登录
        [UserManager didLogOut];

        dispatch_async(dispatch_get_main_queue(), ^{

            if ([delegate respondsToSelector:@selector(didLogout:)]) {
                [delegate didLogout:status];
            }
        });
    }];
}

+ (void)updateUserInfo:(id<UserServiceDelegate>)delegate
                userId:(NSString *)userId
              nickName:(NSString *)nickName
              birthday:(NSString *)birthday
                gender:(NSString *)gender
                   age:(NSInteger)age
             signature:(NSString *)signature
       interestedSport:(NSString *)interestedSport
  interestedSportLevel:(NSInteger)interestedSportLevel
                cityId:(NSString *)cityId
             sportPlan:(NSString *)sportPlan
              latitude:(double)latitude
             longitude:(double)longitude
{    
          //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UPDATE_USER_INFO forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:nickName  forKey:PARA_NICK_NAME];
    [inputDic setValue:birthday forKey:PARA_BIRTHDAY];
    [inputDic setValue:gender forKey:PARA_GENDER];
    if (age !=0 ) {
        [inputDic setValue:[@(age) stringValue] forKey:PARA_AGE];
    }
    [inputDic setValue:signature forKey:PARA_SIGNATURE];
    [inputDic setValue:interestedSport forKey:PARA_INTERESTED_SPORT];
    if (interestedSportLevel != 0) {
        [inputDic setValue:[@(interestedSportLevel) stringValue] forKey:PARA_INTERESTED_SPORT_LEVEL];
    }
    [inputDic setValue:cityId forKey:PARA_USER_CITY_ID];
    [inputDic setValue:sportPlan forKey:PARA_SPORT_PLAN];
    if (latitude != 0 || longitude != 0) {
        [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
        [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];
    }
    //1.1版本：解决两次urlEncode的问题
    //2.0:更改目录结构
    [inputDic setValue:@"2.0" forKey:PARA_VER];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        int point = [data validIntValueForKey:PARA_CREDIT];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUpdateUserInfo:point:)]) {
                [delegate didUpdateUserInfo:status point:point];
            }
        });
    }];
}

+ (void)updateMyLocation:(id<UserServiceDelegate>)delegate
                  userId:(NSString *)userId
                latitude:(double)latitude
               longitude:(double)longitude
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //send
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_UPDATE_USER_INFO forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
        [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];

    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary  = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUpdateMyLocation:)]) {
                [delegate didUpdateMyLocation:status];
            }
        });
    }];
    });
}

+ (void)upLoadAvatar:(id<UserServiceDelegate>)delegate
              userId:(NSString *)userId
         avatarImage:(UIImage *)avatarImage
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UPLOAD_AVATAR forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    //2.0:更改目录结构
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork postWithBasicUrlString:GS_URL_USER parameters:inputDic image:avatarImage responseHandler: ^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSString *avatar = [data validStringValueForKey:PARA_AVATAR];
        
        int point = [data validIntValueForKey:PARA_CREDIT];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUpLoadAvatar:avatar:point:)]) {
                [delegate didUpLoadAvatar:status avatar:avatar point:point];
            }
        });
    }];

}

+ (void)upLoadGallery:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
                image:(UIImage *)image
                 type:(int)type
                  key:(NSString *)key
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UPLOAD_USER_GALLERY forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%d", type] forKey:PARA_TYPE];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork postWithBasicUrlString:GS_URL_USER parameters:inputDic image:image responseHandler: ^(GSNetworkResponse *response) { 
        NSDictionary *resultDictionary = response.jsonResult;
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSString *photoId = [data validStringValueForKey:PARA_ID];
        NSString *thumbUrl = [data validStringValueForKey:PARA_THUMB_URL];
        NSString *imageUrl = [data validStringValueForKey:PARA_IMAGE_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUpLoadGallery:type:thumbUrl:imageUrl:photoId:key:)]) {
                [delegate didUpLoadGallery:status
                                      type:type
                                  thumbUrl:thumbUrl
                                  imageUrl:imageUrl
                                   photoId:photoId
                                       key:key];
            }
        });
    }];

}

+ (void)deleteGallery:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
              photoId:(NSString *)photoId
                 type:(int)type
{
    //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_DELETE_USER_GALLERY forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:photoId forKey:PARA_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%d", type] forKey:PARA_TYPE];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler: ^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
 
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didDeleteGallery:type:photoId:)]) {
                [delegate didDeleteGallery:status type:type photoId:photoId];
            }
        });
    }];
}

+ (NSURLSessionTask *)upLoadCommonGallery:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
                image:(UIImage *)image
                  key:(NSString *)key
                 completion:(void(^)(NSString *status,NSString* thumbUrl,NSString *imageUrl,NSString *photoId,NSString *key))completion
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_COMMON_UPLOAD_IMAGE forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    NSURLSessionTask * task = [GSNetwork postWithBasicUrlString:GS_URL_INDEX parameters:inputDic image:image responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *photoId = [data validStringValueForKey:PARA_ATTACH_ID];
        NSString *thumbUrl = [data validStringValueForKey:PARA_THUMB_URL];
        NSString *imageUrl = [data validStringValueForKey:PARA_IMAGE_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status,thumbUrl,imageUrl,photoId,key);
        });
    }];
    
    return task;
}

+ (void)deleteCommonGallery:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
              photoId:(NSString *)photoId
{
        //send
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_COMMON_DELETE_IMAGE forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:photoId forKey:PARA_ATTACH_ID];
        
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didDeleteCommonGallery:photoId:)]) {
                    [delegate didDeleteCommonGallery:status photoId:photoId];
                }
            });
        }];
}

+ (void)resetPassword:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
          phoneNumber:(NSString *)phoneNumber
             password:(NSString *)password
              smsCode:(NSString *)smsCode
{
        //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_RESET_PASSWORD forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:phoneNumber forKey:PARA_PHONE];
    [inputDic setValue:@"1.6" forKey:PARA_VER]; //2015-07-27改成DES加密
    [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
    
    [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
    //[inputDic setValue:[DDBase64 encodeBase64String:password] forKey:PARA_PASSWORD];
    
    [AppGlobalDataManager defaultManager].isProcessingToken = YES;
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;

        //HDLog(@"<resetPassword> %@", resultDictionary);

        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSString *loginEncode = [data validStringValueForKey:PARA_LOGIN_ENCODE];
            [UserManager saveLoginEncode:loginEncode];
            [self parseAccessToken:data];
        }
        
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didResetPassword:)]) {
                [delegate didResetPassword:status];
            }
        });
    }];
}

+ (void)changePassword:(id<UserServiceDelegate>)delegate
                userId:(NSString *)userId
           oldPassword:(NSString *)oldPassword
           newPassword:(NSString *)newPassword
{
        //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UPDATE_PASSWORD forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@"1.6" forKey:PARA_VER]; //2015-07-27改成DES加密
    [inputDic setValue:[DesUtil encryptUseDES:oldPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_OLD_PASSWORD];
    [inputDic setValue:[DesUtil encryptUseDES:newPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_NEW_PASSWORD];
    

    [AppGlobalDataManager defaultManager].isProcessingToken = YES;
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            //HDLog(@"<changePassword> %@", resultDictionary);
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            
            NSString *loginEncode = [data validStringValueForKey:PARA_LOGIN_ENCODE];
            [UserManager saveLoginEncode:loginEncode];
            
            [self parseAccessToken:data];
        }
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
       
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didChangePassword:)]) {
                [delegate didChangePassword:status];
            }
        });
    }];
}

+ (void)queryUserProfileInfo:(id<UserServiceDelegate>)delegate
                      userId:(NSString *)userId
{
     NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
     [inputDic setValue:VALUE_ACTION_GET_PROFILE_INFO forKey:PARA_ACTION];
     [inputDic setValue:userId forKey:PARA_USER_ID];
        
     //2015-05-19加版本号1.3，返回来的数据把信息字段都放在data内
     [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        User *user = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            user = [UserService userByDictionary:data];
            
            User *me = [[UserManager defaultManager] readCurrentUser];
            if ([me.userId isEqualToString:user.userId]) {
                [[UserManager defaultManager] saveCurrentUser:user];
                
                //如果融云为第一次加载，则重新连接
                if (![[RongService defaultService] checkRongReady]) {
                    [[RongService defaultService] connectRongIM];
                }
            } else {
                
                //异常情况，退出登录
                 [(AppDelegate *)[[UIApplication sharedApplication] delegate] logoutAndCleanView];
            
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryUserProfileInfo:status:msg:)]) {
                [delegate didQueryUserProfileInfo:user status:status msg:msg];
            }
        });
    }];
}

//+ (void)updatePushToken:(id<UserServiceDelegate>)delegate
//                 userId:(NSString *)userId
//              pushToken:(NSString *)pushToken
//               deviceId:(NSString *)deviceId
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
//        [inputDic setValue:VALUE_ACTION_UPDATE_PUSH_TOKEN forKey:PARA_ACTION];
//        [inputDic setValue:userId forKey:PARA_USER_ID];
//        [inputDic setValue:pushToken forKey:PARA_IOS_PUSH_TOKEN];
//        [inputDic setValue:@"ios" forKeyPath:PARA_DEVICE];
//        [inputDic setValue:deviceId forKeyPath:PARA_DEVICE_ID];
//        
//        NSDictionary *resultDictionary  = [SportNetwrok getJsonWithPrameterDictionary:inputDic];
//        
//        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([delegate respondsToSelector:@selector(didUpdatePushToken:)]) {
//                [delegate didUpdatePushToken:status];
//            }
//        });
//    });
//}

+ (Voucher *)parseOneVoucher:(NSDictionary *)dic
{
    Voucher *voucher = [[Voucher alloc] init] ;
    voucher.voucherId = [dic validStringValueForKey:PARA_COUPON_ID];
    voucher.voucherNumber = [dic validStringValueForKey:PARA_COUPON_SN];
    voucher.amount = [dic validDoubleValueForKey:PARA_COUPON_AMOUNT];
    voucher.title = [dic validStringValueForKey:PARA_COUPON_NAME];
    voucher.desc = [dic validStringValueForKey:PARA_DESCRIPTION];
    voucher.status = [dic validIntValueForKey:PARA_STATUS];
    voucher.minAmount = [dic validDoubleValueForKey:PARA_MIN_AMOUNT];
    voucher.maxAmount = [dic validDoubleValueForKey:PARA_MAX_AMOUNT];
    voucher.validDate = [NSDate dateWithTimeIntervalSince1970:[dic validIntValueForKey:PARA_USE_END_DATE]];
    
    return voucher;
}

+ (void)addSharePhone:(id<UserServiceDelegate>)delegate
                 phone:(NSString *)phone
               userId:(NSString *)userId
                 type:(NSString *)type
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_SHARE_PHONE  forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:phone forKey:PARA_PHONE];
        [inputDic setValue:type forKey:PARA_TYPE];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
//        if ([status isEqualToString:STATUS_SUCCESS]) {
//            
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAddSharePhone:msg:type:)]) {
                [delegate didAddSharePhone:status msg:msg type:type];
            }
        });
    }];
}

+ (void)getMessageCountList:(id<UserServiceDelegate>)delegate
                     userId:(NSString *)userId
                   deviceId:(NSString *)deviceId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_MESSAGE_COUNT_LIST  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [inputDic setValue:@"2.0" forKey:PARA_VER];   //1.94版本必传
    
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        for (NSDictionary *dic in list) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSString *type = [dic validStringValueForKey:PARA_TYPE];
            NSUInteger count = [dic validIntValueForKey:PARA_COUNT];
            
            [[TipNumberManager defaultManager]setMessageCount:[type intValue] count:count];
        }
        //更新首页Tab的红点数
        NSInteger count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
        
        if ([[RongService defaultService] checkRongReady]) {
            [[TipNumberManager defaultManager] setImReceiveMessageCount:count];
        } else {
            [[TipNumberManager defaultManager] setImReceiveMessageCount:0];
        }
        //更新是否显示调查问券红点，如没有点击，则显示
        [[TipNumberManager defaultManager] setIsShowSurveyTips:![UserManager readIsClickedSurvey]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didGetMessageCountList:msg:)]) {
                [delegate didGetMessageCountList:status msg:msg];
            }
        });
        
    }];
}


+ (void)updateMessageCount:(id<UserServiceDelegate>)delegate
                     userId:(NSString *)userId
                  deviceId:(NSString *)deviceId
                      type:(NSString *)type
                     count:(NSUInteger)count
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_UPDATE_MESSAGE_COUNT  forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:deviceId forKey:PARA_DEVICE_ID];
        [inputDic setValue:type forKey:PARA_TYPE];
        [inputDic setValue:[NSString stringWithFormat:@"%d", (int)count] forKey:PARA_COUNT];
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            [[TipNumberManager defaultManager] setMessageCount:[type intValue] count:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didUpdateMessageCount:msg:)]) {
                    [delegate didUpdateMessageCount:status msg:msg];
                }
            });
    }];
}

+ (void)getSMSCode:(id<UserServiceDelegate>)delegate
             phone:(NSString *)phone
       phoneEncode:(NSString *)phoneEncode
              type:(VerifyPhoneType)type
          openType:(NSString *)openType
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_SMS_CODE  forKey:PARA_ACTION];
        if ([phoneEncode length] > 0) {
            //当使用用户本身的phone时使用
            [inputDic setValue:phoneEncode forKey:PARA_PHONE_ENCODE];
        }else {
            //当用户输入的手机号码时使用
            [inputDic setValue:phone forKey:PARA_PHONE];
        }
        
        [inputDic setValue:[NSString stringWithFormat:@"%d", type] forKey:PARA_TYPE];
        if (openType.length > 0) {
            [inputDic setValue:openType forKey:PARA_OPEN_TYPE];
        }
        
        [inputDic setValue:[[UserManager defaultManager] readCurrentUser].userId forKey:PARA_USER_ID];
        [inputDic setValue:@"2.0" forKey:PARA_VER];   //1.94版本必传
    [GSNetwork getWithBasicUrlString:GS_URL_SMS parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *dic = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        int length = 0;
        length = [dic validIntValueForKey:PARA_SMS_CODE_LENGTH];
        
        
        
        if ([status isEqualToString:STATUS_SUCCESS] == NO) {
            if ([msg length] == 0 ) {
                msg = @"网络有点问题，请稍后重试";
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetSMSCode:msg:)]) {
                [delegate didGetSMSCode:status msg:msg];
            }
            
            if ([delegate respondsToSelector:@selector(didGetSMSCode:msg:length:)]) {
                [delegate didGetSMSCode:status msg:msg length:length];
            }
            
        });
    }];
}

+ (void)verifySMSCode:(id<UserServiceDelegate>)delegate
             phone:(NSString *)phone
          phoneEncode:(NSString *)phoneEncode
            SMSCode:(NSString *)SMSCode
              type:(VerifyPhoneType)type
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_VERIFY_SMS_CODE  forKey:PARA_ACTION];
    if ([phoneEncode length] > 0) {
        [inputDic setValue:phoneEncode forKey:PARA_PHONE_ENCODE];
    }else {
        [inputDic setValue:phone forKey:PARA_PHONE];
    }
    [inputDic setValue:SMSCode forKey:PARA_SMS_CODE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", type] forKey:PARA_TYPE];
        
    [GSNetwork getWithBasicUrlString:GS_URL_SMS parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        if ([status isEqualToString:STATUS_SUCCESS] == NO) {
            if ([msg length] == 0 ) {
                msg = @"网络有点问题，请稍后重试";
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didVerifySMSCode:msg:)]) {
                [delegate didVerifySMSCode:status msg:msg];
            }
            
        });
    }];
}

+ (void)quickLogin:(id<UserServiceDelegate>)delegate
             phone:(NSString *)phone
           SMSCode:(NSString *)SMSCode
{
 
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_QUICK_LOGIN  forKey:PARA_ACTION];
    [inputDic setValue:phone forKey:PARA_PHONE];
    [inputDic setValue:SMSCode forKey:PARA_SMS_CODE];
    //2016-6-15 用2.0接口
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    //必须一一对应
    [AppGlobalDataManager defaultManager].isProcessingToken = YES;
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;

        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        User *user = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            user = [UserService userByDictionary:data];
            [[UserManager defaultManager] saveCurrentUser:user];
            NSString *loginEncode = [data validStringValueForKey:PARA_LOGIN_ENCODE];
            [UserManager saveLoginEncode:loginEncode];
        } else {
            if ([msg length] == 0 ) {
                msg = @"网络有点问题，请稍后重试";
            }
        }
        //必须一一对应
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQuickLogin:msg:)]) {
                [delegate didQuickLogin:status msg:msg];
            }
        });
    }];
}

+ (void)setPassword:(id<UserServiceDelegate>)delegate
             userId:(NSString *)userId
           password:(NSString *)password
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SET_PASSWORD  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];

    [inputDic setValue:@"1.6" forKey:PARA_VER]; //2015-07-27改成DES加密
    //[inputDic setValue:[DDBase64 encodeBase64String:password] forKey:PARA_PASSWORD];
    [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
    
    [AppGlobalDataManager defaultManager].isProcessingToken = YES;

    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            
            NSString *loginEncode = [data validStringValueForKey:PARA_LOGIN_ENCODE];
            [UserManager saveLoginEncode:loginEncode];

            [self parseAccessToken:data];
        }
        
        [AppGlobalDataManager defaultManager].isProcessingToken = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didSetPassword:msg:)]) {
                [delegate didSetPassword:status msg:msg];
            }
        });
    }];
}
     

+ (void)getUserMoneyLog:(id<UserServiceDelegate>)delegate
                 userId:(NSString *)userId
                   page:(int)page
                  count:(int)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_USER_MONEY_LOG  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
    [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;

        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSMutableArray *recordList = [NSMutableArray array];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        for (NSDictionary *one in list) {
            MoneyRecord *record = [[MoneyRecord alloc] init] ;
            record.type = [one validIntValueForKey:PARA_TYPE];
            record.money = [one validFloatValueForKey:PARA_MONEY];
            record.createTime =  [NSDate dateWithTimeIntervalSince1970:[one validIntValueForKey:PARA_ADD_TIME]];
            record.desc = [one validStringValueForKey:PARA_DESCRIPTION];
            [recordList addObject:record];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetUserMoneyLog:msg:recordList:)]) {
                [delegate didGetUserMoneyLog:status msg:msg recordList:recordList];
            }
        });
    }];
}


+ (void)resetPayPassword:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
          phoneNumber:(NSString *)phoneNumber
             password:(NSString *)payPassword
              smsCode:(NSString *)smsCode
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_RESET_PAY_PASSWORD forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:phoneNumber forKey:PARA_PHONE_ENCODE];
    [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [inputDic setValue:[DesUtil encryptUseDES:payPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_NEW_PAY_PASSWORD];
    //[inputDic setValue:[DDBase64 encodeBase64String:password] forKey:PARA_PASSWORD];
    
    [GSNetwork getWithBasicUrlString:GS_URL_PAY parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
//        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didResetPayPassword:msg:)]) {
                [delegate didResetPayPassword:status msg:msg];
            }
        });
    }];
}

+ (void)changePayPassword:(id<UserServiceDelegate>)delegate
                userId:(NSString *)userId
           oldPassword:(NSString *)oldPayPassword
           newPassword:(NSString *)newPayPassword
{
         //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UPDATE_PAY_PASSWORD forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [inputDic setValue:[DesUtil encryptUseDES:oldPayPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_OLD_PAY_PASSWORD];
    [inputDic setValue:[DesUtil encryptUseDES:newPayPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_NEW_PAY_PASSWORD];
    
    [GSNetwork getWithBasicUrlString:GS_URL_PAY parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didChangePayPassword:msg:)]) {
                [delegate didChangePayPassword:status msg:msg];
            }
        });
    }];
}


+ (void)setPayPassword:(id<UserServiceDelegate>)delegate
             userId:(NSString *)userId
           password:(NSString *)payPassword
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SET_PAY_PASSWORD forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[DesUtil encryptUseDES:payPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
        
    [GSNetwork getWithBasicUrlString:GS_URL_PAY parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
//        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        if ([status isEqualToString:STATUS_SUCCESS]
            || [status isEqualToString:STATUS_DUPLICATE_PAY_PASSWORD]) {
            User *user = [[UserManager defaultManager] readCurrentUser];
            user.hasPayPassWord = YES;
            [[UserManager defaultManager] saveCurrentUser:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didSetPayPassword:msg:)]) {
                [delegate didSetPayPassword:status msg:msg];
            }
        });
    }];
}

+ (void)verifyPayPassword:(id<UserServiceDelegate>)delegate
                userId:(NSString *)userId
              password:(NSString *)payPassword
{

    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_VERIFY_PAY_PASSWORD  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[DesUtil encryptUseDES:payPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
    
    [GSNetwork getWithBasicUrlString:GS_URL_PAY parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didVerifyPayPassword:msg:payPassword:)]) {
                [delegate didVerifyPayPassword:status msg:msg payPassword:payPassword];
            }
        });
    }];
}

+ (void)getUserInfo:(id<UserServiceDelegate>)delegate
             userId:(NSString *)userId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_USER_INFO  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_V_USER_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            
            User *user = nil;
            if ([status isEqualToString:STATUS_SUCCESS]) {
                user = [UserService userByDictionary:data];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didGetUserInfo:status:msg:)]) {
                    [delegate didGetUserInfo:user status:status msg:msg];
                }
            });
    }];
    

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
//        [inputDic setValue:VALUE_ACTION_GET_USER_INFO  forKey:PARA_ACTION];
//        [inputDic setValue:userId forKey:PARA_USER_ID];
//        
//        NSDictionary *resultDictionary  = [SportNetwrok getJsonWithPrameterDictionary:inputDic];
//        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
//        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
//        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
//        
//        User *user = nil;
//        if ([status isEqualToString:STATUS_SUCCESS]) {
//            user = [UserService userByDictionary:data];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([delegate respondsToSelector:@selector(didGetUserInfo:status:msg:)]) {
//                [delegate didGetUserInfo:user status:status msg:msg];
//            }
//        });
//    });
}

+ (void)userBalance:(id<UserServiceDelegate>)delegate
             userId:(NSString *)userId
{

    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_USER_BALANCE forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        double balance = [data validDoubleValueForKey:PARA_BALANCE];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUserBalance:status:msg:)]) {
                [delegate didUserBalance:balance status:status msg:msg];
            }
        });
    }];
}


+ (void)userIntegral:(id<UserServiceDelegate>)delegate userId:(NSString *)userId {
    
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_USER_INTEGRAL forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        int integral = [data validIntValueForKey:PARA_INTEGRAL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUserIntegral:status:msg:)]) {
                [delegate didUserIntegral:integral status:status msg:msg];
            }
        });
    }];
    
}

//1.9 获取消息列表分类
+ (void)getSystemMessageCategory:(id<UserServiceDelegate>)delegate
                     userId:(NSString *)userId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_SYSTEM_MESSAGE_CATS  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[SportUUID uuid] forKey:PARA_DEVICE_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *messageList = [NSMutableArray array];
        for (NSDictionary *dic in list) {
            SystemMessage *message = [UserService messageByOneMessageDictionary:dic];
            [messageList addObject:message];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didGetSystemMessageCategory:msg:list:   )]) {
                [delegate didGetSystemMessageCategory:status msg:msg list:messageList];
            }
        });
    }];
}

//1.9 获取指定分类下消息
+ (void)getSystemMessageCategoryMessage:(id<UserServiceDelegate>)delegate
                          userId:(NSString *)userId
                                   type:(int)type
                                   page:(int)page
                                  count:(int)count
{

    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_SYSTEM_CAT_MESSAGE  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[@(type) stringValue] forKey:PARA_TYPE];
    
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKeyPath:PARA_PAGE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKeyPath:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *messageList = [NSMutableArray array];
        for (NSDictionary *dic in list) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            SystemMessage *message = [UserService messageByOneMessageDictionary:dic];
            
            [messageList addObject:message];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didGetSystemMessageCategoryMessage:msg:list:page:)]) {
                [delegate didGetSystemMessageCategoryMessage:status msg:msg list:messageList page:page];
            }
        });
    }];
}

+(SystemMessage *) messageByOneMessageDictionary:(NSDictionary *)dic
{
    SystemMessage *message = [[SystemMessage alloc]init];
    message.flag = [dic validIntValueForKey:PARA_FLAG];
    message.type = [dic validIntValueForKey:PARA_TYPE];
    message.iconUrl = [dic validStringValueForKey:PARA_TYPE_ICON];
    message.typeName = [dic validStringValueForKey:PARA_TYPE_NAME];
    message.number = [dic validIntValueForKey:PARA_NUMS];
    message.messageType = [dic validIntValueForKey:PARA_MSG_TYPE];
    
    NSDictionary *extra = [dic validDictionaryValueForKey:PARA_EXTRA];
    
    //文本消息（messageType：0，3，5，6）
    message.message = [extra validStringValueForKey:PARA_MSG];
    message.addTime = [extra validDateValueForKey:PARA_ADD_TIME];
    
    //图文 messageType：1
    //会员体系升级、降级通知消息 messageType：14
    message.title = [extra validStringValueForKey:PARA_TITLE];
    message.content = [extra validStringValueForKey:PARA_CONTENT];
    message.imageUrl = [extra validStringValueForKey:PARA_IMG];
    message.webUrl = [extra validStringValueForKey:PARA_URL];
    message.activityTimeString = [extra validStringValueForKey:PARA_ACT_TIME];
    
    //推荐场馆消息 messageType：2
    message.businessId = [extra validStringValueForKey:PARA_BUSINESS_ID];
    message.categroyId = [extra validStringValueForKey:PARA_CAT_ID];
    
    //运动圈精彩主题消息返回 messageType：15
    message.postId = [extra validStringValueForKey:PARA_POST_ID];
    
    //分类下运动圈回复用户名
    message.fromUser = [extra validStringValueForKey:PARA_FROM_USER];
    

    return message;
}

+ (void) parseAccessToken:(NSDictionary *)data {
    NSDictionary *value = [data validDictionaryValueForKey:PARA_QYD_TOKEN];
    if (value) {
        [AppGlobalDataManager defaultManager].qydToken = [value validStringValueForKey:PARA_VALUE];
        int expireTime = [value validIntValueForKey:PARA_EXPIRES];
        
        //务必在主线程启动Timer
        dispatch_async(dispatch_get_main_queue(), ^{
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] requestAccessTokenWithTimerInterval:REAL_EXPIRE_TIME(expireTime)];
        });
    }
}

@end
