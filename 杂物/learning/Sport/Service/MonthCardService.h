//
//  MonthCardService.h
//  Sport
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
#import "MonthCard.h"

@class MonthCardCourse;
@class Business;
@class ProductInfo;
@class BusinessPhoto;
@class Order;
@class MonthCardAssistent;


@protocol MonthCardServiceDelegate <NSObject>
@optional

//- (void)didQueryBusinessDetail:(Business *)business
//                        status:(NSString *)status
//                           msg:(NSString *)msg;

- (void)didGetVenuesList:(NSArray *)businesses
                    page:(NSUInteger)page
                    status:(NSString *)status
                     msg:(NSString *)msg;

- (void)didGetCourseList:(NSArray *)courses
                    page:(NSUInteger)page
                  status:(NSString *)status
                     msg:(NSString *)msg;

- (void)didVenuesInfo:(Business *)business
      monthCardStatus:(int)monthCardStatus
               status:(NSString *)status
                  msg:(NSString *)msg;

- (void)didGetRecommendCourseList:(NSArray *)courses
                    page:(NSUInteger)page
                  status:(NSString *)status
                     msg:(NSString *)msg;

-(void)didUploadAvatar:(BusinessPhoto *)photo
                status:(NSString *)status
                   msg:(NSString *)msg;

-(void)didGetQrCode:(NSString *)qrCode
             status:(NSString *)status
                msg:(NSString *)msg;

-(void)didGetMonthCardInfo:(MonthCard *)card
                    status:(NSString *)status
                       msg:(NSString *)msg;

- (void)didAddMonCardOrder:(Order *)order
                    status:(NSString *)status
                       msg:(NSString *)msg;

- (void)didCourseInfo:(MonthCardCourse *)course
               status:(NSString *)status
                  msg:(NSString *)msg;

- (void)didBookCourse:(NSString *)status
                  msg:(NSString *)msg;

- (void)didCheckCourseStatus:(int)courseStatus
                      status:(NSString *)status
                         msg:(NSString *)msg;

- (void)didCardGoodsInfo:(NSString *)name
                 goodsId:(NSString *)goodsId
                   price:(float)price
                  status:(NSString *)status
                     msg:(NSString *)msg;
- (void)didGetRcordVenueList:(NSArray *)venus
                         page:(NSUInteger)page
                       status:(NSString *)status
                          msg:(NSString *)msg;
-(void)didGetSportAssistant:(NSArray *)list
                     status:(NSString *)status
                        msg:(NSString *)msg;

- (void)didMonCardConfirmOrder:(NSString *)status
                           msg:(NSString *)msg
                       goodsId:(NSString *)goodsId
                     goodsName:(NSString *)goodsName
                      onePrice:(float)onePrice
                   totalAmount:(float)totalAmount
                   orderAmount:(float)orderAmount
                  orderPromote:(float)orderPromote
                    activityId:(NSString *)activityId
                  activityList:(NSArray *)activityList
               activityMessage:(NSString *)activityMessage
                   goodsNumber:(NSUInteger)goodsNumber;
 
- (void)didGetRcordCourseList:(NSArray *)courses
                         page:(NSUInteger)page
                       status:(NSString *)status
                          msg:(NSString *)msg;
@end

@interface MonthCardService : NSObject

//场馆列表
+ (void)getVenuesList:(id<MonthCardServiceDelegate>)delegate
           categoryId:(NSString *)categoryId
               cityId:(NSString *)cityId
            regionId:(NSString *)regionId
             latitude:(double)latitude
            longitude:(double)longitude
                count:(int)count
                 page:(int)page;

//课程列表
+ (void)getCourseList:(id<MonthCardServiceDelegate>)delegate
           categoryId:(NSString *)categoryId
               cityId:(NSString *)cityId
            regionId:(NSString *)regionId
                 date:(NSString *)date
             latitude:(double)latitude
            longitude:(double)longitude
                count:(int)count
                 page:(int)page;

//场馆信息
+ (void)venuesInfo:(id<MonthCardServiceDelegate>)delegate
        businessId:(NSString *)businessId
        categoryId:(NSString *)categoryId;

//推荐课程
+ (void)getRecommendCourseList:(id<MonthCardServiceDelegate>)delegate
               cityId:(NSString *)cityId
                count:(int)count
                 page:(int)page;

//上传认证头像
+ (void)uploadAvatar:(id<MonthCardServiceDelegate>)delegate
              userId:(NSString *)userId
               image:(UIImage *)image;

//获取二维码信息
+ (void)getQrCode:(id<MonthCardServiceDelegate>)delegate
           userId:(NSString *)userId;

//月卡信息
+ (void)getMonthCardInfo:(id<MonthCardServiceDelegate>)delegate
                  userId:(NSString *)userId;

//生成订单
+ (void)addMonCardOrder:(id<MonthCardServiceDelegate>)delegate
                  phone:(NSString *)phone
            goodsNumber:(NSUInteger)goodsNumber
             activityId:(NSString *)activityId
               couponId:(NSString *)couponId
             ticketType:(NSString *)ticketType
                 cityId:(NSString *)cityId;

//课程信息(移动端不用)
//- (void)courseInfo:(id<MonthCardServiceDelegate>)delegate
//          courseId:(NSString *)courseId;

//课程预订
+ (void)bookCourse:(id<MonthCardServiceDelegate>)delegate
           goodsId:(NSString *)goodsId
            userId:(NSString *)userId;

//课程预约状态监测
+ (void)checkCourseStatus:(id<MonthCardServiceDelegate>)delegate
                   userId:(NSString *)userId
                 courseId:(NSString *)courseId;

//月卡充值商品信息(移动端不用)
//- (void)cardGoodsInfo:(id<MonthCardServiceDelegate>)delegate;

//月卡充值订单确认
+ (void)monCardConfirmOrder:(id<MonthCardServiceDelegate>)delegate
                goodsNumber:(NSUInteger)goodsNumber;

//运动助手
+ (void)sportAssistant:(id<MonthCardServiceDelegate>)delegate
                userId:(NSString *)userId;

//运动记录的场馆列表
+ (void)sportRecordVenues:(id<MonthCardServiceDelegate>)delegate
                   userId:(NSString *)userId
                     page:(NSUInteger)page
                    count:(NSUInteger)count;

//运动记录的课程列表
+ (void)sportRecordCourse:(id<MonthCardServiceDelegate>)delegate
                   userId:(NSString *)userId
                     page:(NSUInteger)page
                    count:(NSUInteger)count;

@end
