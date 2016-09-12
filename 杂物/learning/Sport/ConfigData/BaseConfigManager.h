//
//  BaseConfigManager.h
//  Sport
//
//  Created by haodong  on 14-6-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

#define PAY_METHOD_ALIPAY_CLIENT    @"alipay_client"
#define PAY_METHOD_ALIPAY_WAP       @"alipay_wap"
#define PAY_METHOD_WEIXIN           @"weixin"
#define PAY_METHOD_UNION_CLIENT     @"union_client"
#define PAY_METHOD_APPLE_PAY        @"apple_pay"

@interface BaseConfigManager : NSObject

+ (BaseConfigManager *)defaultManager;

@property (assign, nonatomic) BOOL hasGetConfig;

@property (strong, nonatomic) NSArray *iapProductIdList;
@property (assign, nonatomic) BOOL isShowVoucher;
@property (copy, nonatomic) NSString *payHelpUrl;
@property (copy, nonatomic) NSString *startupImageUrl;
@property (strong, nonatomic) NSArray *payMethodList;

@property (copy, nonatomic) NSString *onLineAppVersion;
@property (assign, nonatomic) BOOL isMustUpdateApp;
@property (copy, nonatomic) NSString *mustUpdateAppVersion;
@property (copy, nonatomic) NSString *updateAppMessage;

@property (copy, nonatomic) NSString *couponRuleUrl;

@property (copy, nonatomic) NSString *creditDescription;
@property (copy, nonatomic) NSString *creditRuleUrl;

@property (copy, nonatomic) NSString *recommendDescription;
@property (copy, nonatomic) NSString *recommendRemark;
@property (copy, nonatomic) NSString *commentDescription;

@property (copy, nonatomic) NSString *userProtocolUrl;

@property (copy, nonatomic) NSString *refundRuleUrl;
@property (copy, nonatomic) NSString *userMoneyRuleUrl;
@property (copy, nonatomic) NSString *userCardUrl;


@property (copy, nonatomic) NSString *alipayKeyword;
@property (copy, nonatomic) NSString *wapPaySuccessTitle;
@property (copy, nonatomic) NSString *wapPayFailTitle;

@property (copy, nonatomic) NSString *forumSearchDataVersion;
@property (copy, nonatomic) NSString *moncardIndexUrl;
@property (copy, nonatomic) NSString *moncardHelpUrl;
@property (copy, nonatomic) NSString *moncardCourseUrl;

@property (copy, nonatomic) NSString *coachRecruitUrl;

@property (copy, nonatomic) NSString *groupBuyUrl;

@property (retain, nonatomic) NSArray *coachOpenCityIdList;
@property (retain, nonatomic) NSString *inReviewVersion;
@property (copy, nonatomic) NSString *moncardIntroduceUrl;
@property (copy, nonatomic) NSString *coachInReviewUrl;

@property (copy, nonatomic) NSString *nmqUrl;

@property (assign, nonatomic) BOOL isShowThirdPartyLogin;
@property (assign, nonatomic) BOOL isCheckNewVersion;
@property (copy ,nonatomic) NSString *signInRuleUrl;
@property (copy, nonatomic) NSString *courtJoinInstructionUrl;

+ (BOOL)saveDownloadedStartupImageUrl:(NSString *)downloadedStartupImageUrl;
+ (NSString *)readDownloadedStartupImageUrl;

+ (BOOL)currentVersionIsInReView;

@end
