//
//  Business.h
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facility.h"
#import "CourseType.h"
#import "BookingStatistics.h"

@class DayBookingInfo;
@class ShareContent;
enum {
    BookingTypeTime = 0,
    BookingTypeSingle = 1,
};

//商品信息
@interface ProductInfo: NSObject

@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *busienssName;
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *categoryName;
@property (copy, nonatomic) NSString *address;
@property (assign, nonatomic) int type;

//场次商品信息（例如羽毛球）
@property (strong, nonatomic) NSArray *timeList;
@property (strong, nonatomic) DayBookingInfo *dayBookingInfo; //改成只持有单日的数据
@property (copy,   nonatomic) NSString *promoteMessage;
@property (copy,   nonatomic) NSString *selectedCourseTypeId;
@property (strong, nonatomic) NSArray *courseTypeList;
@property (assign, nonatomic) int minHour;

//人次商品信息（例如游泳）
@property (strong, nonatomic) NSArray *goodsList;
@property (copy, nonatomic) NSString *useDescription;

- (float)minSinglePrice;

@end


@interface Business : NSObject

@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *name;           //场馆名字
@property (copy, nonatomic) NSString *imageUrl;       //场馆图片
@property (copy, nonatomic) NSString *smallImageUrl;  //场馆小图 （用于列表）
@property (assign, nonatomic) float price;              //价钱     (用于列表)
@property (assign, nonatomic) float promotePrice;       //折后的价钱(用于列表)
@property (copy, nonatomic) NSString *address;        //地址
@property (copy, nonatomic) NSString *telephone;      //电话
@property (assign, nonatomic) double latitude;          //纬度
@property (assign, nonatomic) double longitude;         //经度
@property (assign, nonatomic) BOOL canOrder;            //是否能预订
@property (assign, nonatomic) int orderType;          //预订类型
@property (copy, nonatomic) NSString *cityId;         //城市id
@property (copy, nonatomic) NSString *regionId;       //区域id
@property (strong, nonatomic) NSArray *categoryList;    //项目种类列表
@property (copy, nonatomic) NSString *defaultCategoryId;  //当前选择的种类id
@property (assign, nonatomic) NSUInteger commentCount;  //评论数
@property (assign, nonatomic) BOOL isOften;             //是否常去
@property (copy, nonatomic) NSString *neighborhood;   //商圈
@property (strong, nonatomic) NSArray *promoteList;     //优惠活动列表
@property (assign, nonatomic) BOOL isCollect;           //是否已收藏
@property (copy, nonatomic) NSString *announcement;   //公告
@property (assign, nonatomic) float rating;             //评分
@property (assign, nonatomic) NSUInteger imageCount;    //相册图片数量
@property (assign, nonatomic) NSUInteger mainImageCount;  //场馆主图数量（新增2.10+）

@property (assign, nonatomic) int playHourCount;        //运动小时数(用于个人资料中)

@property (assign, nonatomic) int startHour;            //营业开始时间,用于首页热门球馆
@property (assign, nonatomic) int endHour;              //营业结束时间，用于首页热门球馆

@property (copy, nonatomic) NSString *transitInfo;    //公交
@property (copy, nonatomic) NSString *metroInfo;      //地铁

@property (assign, nonatomic) BOOL canRefund;           //是否退款
@property (copy, nonatomic) NSString *refundMessage;  //退款信息

@property (assign, nonatomic) BOOL isCardUser;          //是否会员

@property (strong, nonatomic) NSArray *facilityList;    //最新的设施列表
@property (strong, nonatomic) NSArray *serviceGroupList;     //最新的服务列表

@property (strong, nonatomic) NSDate *businessDate;     //日期 （用于运动记录）
@property (assign, nonatomic) BOOL isRecommend;         //是否推荐（用于动Club);
@property (copy, nonatomic) NSString *monthCardShareUrl;   //分享的链接(用于动Club)
@property (copy, nonatomic) NSString *moncardNotice;  //用于月卡的温馨提水

@property (assign, nonatomic) int isSupportClub;  //场馆是否支持动club
@property (copy, nonatomic) NSString *idleVenue;  //空闲的场地数量(新增1.9+)
@property (copy, nonatomic) NSString *refundTips;  //退款提示(新增1.9+)

@property (strong, nonatomic) NSArray *parkingLotList; //停车场列表
@property (strong, nonatomic) ShareContent *shareContent;

@end
