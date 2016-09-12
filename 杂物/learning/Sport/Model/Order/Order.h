//
//  Order.h
//  Sport
//
//  Created by haodong  on 13-7-23.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtJoin.h"
@class FavourableActivity;

enum {
    OrderStatusUnpaid = 0,     //未支付
    OrderStatusPaid = 1,       //已支付
    OrderStatusCancelled = 2,  //已取消
    OrderStatusUsed = 3,       //已完成
    OrderStatusExpired = 4,    //已过期
    OrderStatusRefund = 5,     //已申请退款
    OrderStatusCardPaid = 6    //会员卡支付
};

typedef NS_ENUM(NSUInteger, CoachOrderStatus) {
    CoachOrderStatusUnpaid = 0,         //待支付
    CoachOrderStatusReadyCoach  = 5,    //待陪练
    CoachOrderStatusCoaching = 10,      //陪练中
    CoachOrderStatusReadyConfirm = 15,  //待确认
    CoachOrderStatusFinished = 20,      //已完成
    CoachOrderStatusCancelled = 25,     //已取消
    CoachOrderStatusUnPaidCancelled = 27, //已取消
    CoachOrderStatusExpired = 30,       //已过期
    CoachOrderStatusRefund = 35,        //已退款
};

enum {
    OrderTypeDefault = 0,                   //场次订单
    OrderTypeSingle = 1,                    //人次订单（分为月卡、非月卡）
    OrderTypePackage = 2,                   //特惠订单
    OrderTypeMembershipCard = 3,            //会员订单
    OrderTypeMembershipCardRecharge = 4,    //会员充值订单
    OrderTypeMonthCardRecharge = 5,         //月卡充值订单
    OrderTypeCoach = 6,                     //教练订单
    OrderTypeCourse = 7,                    //课程订单（分为月卡、非月卡）
    OrderTypeCourtPool = 8,                 //拼场订单
    OrderTypeCourtJoin = 9,                 //球局订单
};

typedef NS_ENUM(NSUInteger, ComplainStatus) {
    ComplainStatusInvalid = 0,
    ComplainStatusValid,
    ComplainStatusAlreadyComplained,
};

typedef NS_ENUM(NSUInteger, CommentStatus) {
    CommentStatusInvalid = 0,
    CommentStatusValid,
    CommentStatusAlreadyComment,
};

typedef NS_ENUM(NSUInteger, refundStatus) {
    RefundStatusUnrefund = 0,
    RefundStatusRefunding = 1,
    RefundStatusAlreadyRefund = 2,
    RefundStatusRefundIn30d = 10,
    RefundStatusExpire = 11,
    RefundStatusMembershipCardRefundDisable = 12,
};

#define GENDER_MALE     @"m"
#define GENDER_FEMALE   @"f"

@interface Order : NSObject

@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *orderNumber;
@property (copy, nonatomic) NSString *orderName;
@property (copy, nonatomic) NSString *consumeCode;
@property (strong, nonatomic) NSDate *createDate;
@property (assign, nonatomic) double amount;   //需要支付的金额 / 同第三方支付金额
@property (copy, nonatomic) NSString *payMethodName;
@property (assign, nonatomic) int status;
@property (copy, nonatomic) NSString *categoryName;
@property (copy, nonatomic) NSString *businessName;
@property (copy, nonatomic) NSString *businessAddress;
@property (copy, nonatomic) NSString *businessPhone;
@property (strong, nonatomic) NSDate *useDate;
@property (strong, nonatomic) NSArray *productList;
@property (copy, nonatomic) NSString *alipayNotifyUrlString;
@property (copy, nonatomic) NSString *weixinNotifyUrlString;

@property (assign, nonatomic) double totalAmount;    //总金额
@property (assign, nonatomic) double promoteAmount;  //立减的金额
@property (assign, nonatomic) double money;          //使用的余额

@property (copy, nonatomic) NSString *voucherId;
@property (assign, nonatomic) double voucherAmount;  //卡券优惠
@property (assign, nonatomic) double promotionAmount;  //活动优惠

@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *categoryId;

@property (assign, nonatomic) BOOL isShareGiveVoucher;
@property (copy, nonatomic) NSString *shareMessage;

@property (assign, nonatomic) int givePoint;

@property (assign, nonatomic) int type;

@property (assign, nonatomic) int count;                //人次订单用到的数目
@property (copy, nonatomic) NSString *goodsName;      //人次订单用到的商品名
@property (copy, nonatomic) NSString *useDescription; //人次订单用到
@property (assign, nonatomic) double singlePrice;       //人次订单用的单价

@property (assign, nonatomic) BOOL canWriteReview;

@property (strong, nonatomic) NSArray *favourableActivityList; //优惠活动列表
@property (copy, nonatomic) NSString *selectedFavourableActivityId;

@property (copy, nonatomic) NSString *detailUrl;

@property (assign, nonatomic) BOOL canRefund; //是否能够退款
@property (assign, nonatomic) int refundStatus;

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@property (assign, nonatomic) double userBalance; //用户总余额

@property (copy, nonatomic) NSString *cardNumber;     //会员订单-卡号
@property (copy, nonatomic) NSString *cardBalance;    //会员订单-卡内的余额
@property (copy, nonatomic) NSString *cardPhone;      //会员订单-手机号
@property (copy, nonatomic) NSString *cardHolder;     //会员订单-持卡人
@property (assign, nonatomic) double cardAmount;      //会员订单-扣费金额

@property (strong, nonatomic) NSDate *lastRefundTime; //最后退款时间

@property (copy, nonatomic) NSString *coachId;      //教练Id
@property (copy, nonatomic) NSString *coachName;    //教练名字
@property (copy, nonatomic) NSString *coachAvatarUrl;  //教练头像
@property (copy, nonatomic) NSString *coachPhone;   //教练手机
@property (assign, nonatomic) BOOL isCoachAudit;      //教练是否通过认证
@property (assign, nonatomic) int  coachAge;          //教练年龄
@property (assign, nonatomic) int  coachHeight;       //教练身高
@property (assign, nonatomic) int  coachWeight;       //教练重量
@property (copy, nonatomic) NSString* coachGender;       //教练性别
@property (strong, nonatomic) NSDate *coachStartTime; //陪练开始时间
@property (strong, nonatomic) NSDate *coachEndTime; //陪练结束时间
@property (assign, nonatomic) int coachDuration;       //陪练时长
@property (copy, nonatomic) NSString *coachCategory; //陪练项目
@property (copy, nonatomic) NSString *coachAddress;    //陪练地点
@property (assign, nonatomic) int coachStatus;
@property (assign, nonatomic) BOOL isCoachCanCancel;     //是否可以取消预约
@property (assign, nonatomic) int complainedStatus;  //投诉状态  (0不可用投诉, 1可用投诉, 2已经投诉过了)
@property (assign, nonatomic) int commentStatus;     //评论状态 (0不可以评价, 1可以评价, 2已经评价过了)
@property (assign, nonatomic) BOOL isClubPay;       //是否动Club支付
@property (strong, nonatomic) NSDate *courseStartTime; //课程开始时间
@property (strong, nonatomic) NSDate *courseEndTime; //陪练结束时间
@property (copy, nonatomic) NSString *shareUrl;
@property (copy, nonatomic) NSString *logoUrl;
@property (copy, nonatomic) NSString *title;  //订单列表－订单标题约练 (教练名 + 性别) 课程 (课程名) 其他 (场馆名称)
@property (copy, nonatomic) NSString *iconURL; //订单列表－订单图标
@property (copy, nonatomic) NSString *fieldNo; //订单列表－场地商品
@property (assign, nonatomic) int timeRange;  //订单列表－－时间（约练才有：1上午 2下午 3晚上）
@property (strong, nonatomic) NSDate *startTime; // 开始时间 课程商品： 课程开始时间 人次商品： 没有 约练商品： 约练的开始时间 场次商品： 开始时间（有多个就是第一个的开始时间）
@property (strong, nonatomic) NSDictionary *shareInfo;
@property (assign, nonatomic) int surveySwitchFlag;

@property (copy, nonatomic) NSString *shareBtnMsg;

@property (copy, nonatomic) NSString *clubEndTime;
@property (strong, nonatomic) NSArray *payMethodList;
@property (assign, nonatomic) int monthRefundTimes;
@property (strong, nonatomic) NSString *refundUrl;
@property (strong, nonatomic) CourtJoin *courtJoin;
@property (assign, nonatomic) BOOL isCourtJoinParent;

//保险
@property (copy, nonatomic) NSString *insuranceContent;
@property (copy, nonatomic) NSString *insuranceUrl;
@property (copy, nonatomic) NSString *insurancePayTips;

//剩余支付时间(单位：秒)
@property (assign, nonatomic) int payExpireLeftTime;

@property (copy, nonatomic) NSString *payToken;
@property (strong, nonatomic) NSArray *goodsList;  //商品列表
@property (strong, nonatomic) NSArray *qrCodeList;


- (NSString *)orderStatusText;
- (UIColor *)orderStatusTextColor;
- (NSString *)coachOrderStatusText;
- (UIColor *)coachOrderStatusTextColor;

- (NSString *)createForwardText;

- (NSDictionary *)createGroup:(BOOL)isShowPrice;
- (NSString *)coachOrderTimeRangeText;
-(NSString *)orderPayMethodString;
- (FavourableActivity *)selectedActivity:(NSString *)selectedActivityId;
@end
