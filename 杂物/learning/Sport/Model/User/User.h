//
//  User.h
//  Sport
//
//  Created by haodong  on 13-6-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenInfo.h"
#import "Activity.h"
#import "UserPhoto.h"
#import "Post.h"
#import "MonthCard.h"

#define GENDER_MALE     @"m"
#define GENDER_FEMALE   @"f"
@class MonthCard;

@interface User : NSObject

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *avatarUrl;
@property (copy, nonatomic) NSString *avatarBigUrl;
@property (strong, nonatomic) NSDate *birthday;
@property (copy, nonatomic) NSString *gender;
@property (strong, nonatomic) NSArray *openInfoList;
@property (strong, nonatomic) NSArray *favoriteSportIdList;

@property (copy, nonatomic) NSString *phoneNumber;
@property (copy, nonatomic) NSString *phoneEncode;
@property (copy, nonatomic) NSString *password;

@property (copy, nonatomic) NSString *imPassword;

@property (assign, nonatomic) NSInteger age;
@property (copy, nonatomic) NSString *cityId;
@property (copy, nonatomic) NSString *cityName;
@property (copy, nonatomic) NSString *signture;
@property (assign, nonatomic) NSInteger appointmentRate; //是服务器赴约次数除以总次数，再乘以100得出来的
@property (assign, nonatomic) NSInteger activityCount;
@property (assign, nonatomic) NSInteger lemonCount;
@property (copy, nonatomic) NSString *likeSport;
@property (assign, nonatomic) NSInteger likeSportLevel;
@property (strong, nonatomic) Activity *currentActivity;
@property (copy, nonatomic) NSString *sportPlan;
@property (copy, nonatomic) NSString *rulesTitle;//等级名称
@property (copy, nonatomic) NSString *rulesLevel;//等级数字表示
@property (copy, nonatomic) NSString *rulesUrl;  //等级详情url
@property (copy, nonatomic) NSString *rulesIsDisplay;
@property (copy, nonatomic) NSString *rulesIconUrl;

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@property (strong, nonatomic) NSArray *albumList;
@property (strong, nonatomic) NSArray *equipmentList;

@property (copy, nonatomic) NSString *distance; // 用于用户列表的显示

@property (assign, nonatomic) int point;
@property (strong, nonatomic) NSArray *businessHistoryList;

@property (assign, nonatomic) BOOL hasPassWord; //是否有密码
@property (assign, nonatomic) BOOL hasPayPassWord; //是否有支付密码

@property (strong, nonatomic) NSArray *oftenGoToForumList; //常去的圈子
@property (strong, nonatomic) Post *lastPost;              //个页面显示的最近一张贴子
@property (assign, nonatomic) NSUInteger postCount;

@property (strong, nonatomic) MonthCard *monthCard;

@property (assign, nonatomic) double balance;   //用户余额

@property (copy, nonatomic) NSString *rongId;
@property (copy, nonatomic) NSString *rongToken;

//courtPool
@property (assign, nonatomic) int courtPoolJoinTimes;//参与拼场次数
@property (assign, nonatomic) int courtPoolMutualTimes;//拼场交互次数(相对于另一用户)


- (UIImage *)defaultAvatar;
- (NSString *)birthdayString;
- (NSString *)genderDescription;
- (NSString *)favoriteSportIdListToString;

- (OpenInfo *)openInfoWithType:(NSString *)openType;

- (void)deleteAlumb:(NSString *)photoId;
- (void)deleteEquipment:(NSString *)photoId;

- (void)addPhotoToAlumb:(UserPhoto *)photo;
- (void)addPhotoToEquipment:(UserPhoto *)photo;

@end
