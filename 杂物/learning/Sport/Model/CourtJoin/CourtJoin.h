//
//  CourtJoin.h
//  Sport
//
//  Created by Huan on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShareContent;
@interface CourtJoin : NSObject
typedef NS_ENUM(NSUInteger, CourtJoinStatus) {
    JoinStatusPooling = 1,  //拼场中
    JoinStatusBegin = 2,    //待开始
    JoinStatusDone = 3,     //已完成
    JoinStatusRefund = 5,   //取消
};

typedef NS_ENUM(NSUInteger, JoinStatus) {
    JoinStatusDisable = 0, //不可加入
    JoinStatusAvailable,    //可加入
};

@property (assign, nonatomic) BOOL sponsorPermission;
@property (assign, nonatomic) BOOL available;

@property (copy, nonatomic) NSString *courtJoinId;   //球局ID
@property (assign, nonatomic) CourtJoinStatus status;
@property (copy, nonatomic) NSString *statusMsg;    //供发起者看
@property (copy, nonatomic) NSString *courtUserId;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *avatarUrl;
@property (copy,nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *phoneNumber;

@property (assign, nonatomic) int alreadyJoinNumber;   //当前人数
@property (assign, nonatomic) int leftJoinNumber;
@property (copy, nonatomic) NSString *leftJoinNumberMsg;
@property (assign, nonatomic) int maximumNumber;
@property (copy, nonatomic) NSString *continuous;  //用于判断球局是否连续时段

@property (strong, nonatomic) NSArray *userList;  //用户列表
@property (copy, nonatomic) NSString *businessName;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *categoryName;
@property (copy, nonatomic) NSString *address;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longtitude;
@property (assign, nonatomic) double price;
@property (strong, nonatomic) NSDate *bookDate;
@property (strong, nonatomic) NSArray *productList;
@property (strong, nonatomic) ShareContent *shareContent;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (copy, nonatomic) NSString *remindTips;
@property (copy, nonatomic) NSString *disableMsg;//球局是否可用提示信息
@property (copy, nonatomic) NSString *courtJoinMsg;//回报提示信息
@property (copy, nonatomic) NSString *joinDescription;//描述

@property (copy,nonatomic) NSString *priceTagMsg; //球局确认订单使用

- (NSDictionary *)createCourtJoinGroup;
@end
