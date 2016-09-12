//
//  BusinessService.h
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@class Business;
@class ProductInfo;
@class GalleryCategory;

@protocol BusinessServiceDelegate <NSObject>

@optional
- (void)didQueryCategories:(NSArray *)categorys
                    status:(NSString *)status;

- (void)didQueryOtherServiceList:(NSArray *)otherServiceList
                          status:(NSString *)status;

- (void)didQueryBusinesses:(NSArray *)businesses
                    status:(NSString *)status
                       msg:(NSString *)msg
                      page:(int)page
           canFiltrateTime:(NSString *)canFiltrateTime
               totalNumber:(NSString *)totalNumber
                      tips:(NSString *)tips;

- (void)didSearchBusinesses:(NSArray *)businesses
                    status:(NSString *)status;

- (void)didQueryBusinessDetail:(Business *)business
                        status:(NSString *)status
                           msg:(NSString *)msg;

- (void)didQueryBookingStatisticsList:(NSArray *)list
                               status:(NSString *)status
                                  msg:(NSString *)msg
                            orderType:(int)orderType
                            goodsList:(NSArray *)goodsList;

/*
- (void)didQueryOneDateBookingInfo:(ProductInfo *)productInfo
                            status:(NSString *)status
                               msg:(NSString *)msg
                          dateList:(NSArray *)dateList
                        isCardUser:(BOOL)isCardUser;
 */

- (void)didGetVenueBookingDate:(ProductInfo *)productInfo
                        status:(NSString *)status
                           msg:(NSString *)msg
                      dateList:(NSArray *)dateList
                    isCardUser:(BOOL)isCardUser
                          tips:(NSString *)tips;

//-(void)didGetCourtPoolListDate:

- (void)didQueryComments:(NSArray *)commentList
            categoryList:(NSArray *)categoryList
              totalCount:(int)totalCount
               totalRank:(double)totalRank
                  status:(NSString *)status
                     msg:(NSString *)msg;

- (void)didSendComment:(NSString *)status msg:(NSString *)msg point:(int)point text:(NSString *)text;
- (void)didAddFavoriteBusiness:(NSString *)status;
- (void)didRemoveFavoriteBusiness:(NSString *)status;
- (void)didQueryFavoriteBusinessList:(NSArray *)businessList
                              status:(NSString *)status;
- (void)didCallBook:(NSString *)status msg:(NSString *)msg;

- (void)didQueryMapBusinessList:(NSArray *)businessList
                         status:(NSString *)status
                            msg:(NSString *)msg
                 centerLatitude:(double)centerLatitude
                centerLongitude:(double)centerLongitude;


- (void)didGetBusinesseAllPhoto:(NSArray *)list
              photoCategoryList:(NSArray *)photoCategoryList
                         status:(NSString *)status
                            msg:(NSString *)msg;

- (void)didGetNearbyVenusWithStatus:(NSString *)status
                                msg:(NSString *)msg
                           business:(Business *)business;
-(void)didGetVenueParkList:(NSArray *)parkList
           trafficInfoList:(NSArray *)trafficInfoList
                    status:(NSString *)status
                       msg:(NSString *)msg;

- (void)didGetVenuesUserRecommendWithStatus:(NSString *)status
                                        msg:(NSString *)msg;
@end

@interface BusinessService : NSObject

//todo 没调用
//+ (void)queryCategories:(id<BusinessServiceDelegate>)delegate
//                 cityId:(NSString *)cityId;

+ (NSURLSessionTask *)queryBusinesses:(id<BusinessServiceDelegate>)delegate
             categoryId:(NSString *)categoryId
                 cityId:(NSString *)cityId
              region_id:(NSString *)regionId
                   sort:(NSString *)sort
           querySupport:(NSString *)querySupport
               latitude:(double)latitude
              longitude:(double)longitude
                  count:(int)count
                   page:(int)page
                   from:(NSString *)from
              queryDate:(NSString *)queryDate
              queryHour:(NSString *)queryHour
            queryNumber:(NSString *)queryNumber;

+ (void)searchBusinesses:(id<BusinessServiceDelegate>)delegate
              searchText:(NSString *)searchText
                  cityId:(NSString *)cityId
                   count:(int)count
                    page:(int)page;

+ (void)queryBusinessDetail:(id<BusinessServiceDelegate>)delegate
                 businessId:(NSString *)businessId
                 categoryId:(NSString *)categoryId
                     userId:(NSString *)userId;

+ (void)queryBookingStatisticsList:(id<BusinessServiceDelegate>)delegate
                        businessId:(NSString *)businessId
                        categoryId:(NSString *)categoryId;

+ (void)getVenueBookingWithBusinessId:(NSString *)businessId
                           categoryId:(NSString *)categoryId
                                 date:(NSDate *)date
                         courseTypeId:(NSString *)courseTypeId
                          queryNumber:(NSString *)queryNumber
                           completion:(void(^)(NSString *status, NSString *msg, ProductInfo *productInfo, NSArray *dateList, BOOL isCardUser, NSString *tips))completion;
 
+ (void)queryComments:(id<BusinessServiceDelegate>)delegate
           businessId:(NSString *)businessId
               userId:(NSString *)userId
                navId:(NSString *)navId
                count:(int)count
                 page:(int)page;

+ (void)sendComment:(id<BusinessServiceDelegate>)delegate
         businessId:(NSString *)businessId
               text:(NSString *)text
             userId:(NSString *)userId
        commentRank:(int)commentRank
            orderId:(NSString *)orderId
         galleryIds:(NSString *)galleryIds;

+ (void)addFavoriteBusiness:(id<BusinessServiceDelegate>)delegate
                 businessId:(NSString *)businessId
                 categoryId:(NSString *)categoryId
                     userId:(NSString *)userId;

+ (void)removeFavoriteBusiness:(id<BusinessServiceDelegate>)delegate
                    businessId:(NSString *)businessId
                    categoryId:(NSString *)categoryId
                        userId:(NSString *)userId;

+ (void)queryFavoriteBusinessList:(id<BusinessServiceDelegate>)delegate
                           userId:(NSString *)userId;

+ (void)callBook:(id<BusinessServiceDelegate>)delegate
           phone:(NSString *)phone
        userName:(NSString *)userName
       startTime:(NSString *)startTime //yyyy-MM-dd HH:mm
         endTime:(NSString *)endTime //yyyy-MM-dd HH:mm
      businessId:(NSString *)bussinessId
      categoryId:(NSString *)categoryId;

+ (void)queryMapBusinessList:(id<BusinessServiceDelegate>)delegate
                      cityId:(NSString *)cityId
                  categoryId:(NSString *)categoryId
              centerLatitude:(double)centerLatitude
             centerLongitude:(double)centerLongitude
                 minLatitude:(double)minLatitude
                 maxLatitude:(double)maxLatitude
                minLongitude:(double)minLongitude
                maxLongitude:(double)maxLongitude;


+ (void)getBusinesseAllPhoto:(id<BusinessServiceDelegate>)delegate
                  businessId:(NSString *)businessId
                  categoryId:(NSString *)categoryId;


+ (void)getNearbyVenues:(id<BusinessServiceDelegate>)delegate
             categoryId:(NSString *)categoryId
                 cityId:(NSString *)cityId
               venuesId:(NSString *)venuesId
              startTime:(NSString *)startTime
                endTime:(NSString *)endTime
                 userId:(NSString *)userId;

+(void)getVenueParkList:(id<BusinessServiceDelegate>)delegate
               venuesId:(NSString *)venues_id
             categoryId:(NSString *)categoryId;

+ (void)getVenuesUserRecommend:(id<BusinessServiceDelegate>)delegate
                    venuesName:(NSString *)venuesName
                  locationName:(NSString *)locationName
                        userId:(NSString *)userId;

+(void)getBusinessGoodsListWithBusinessId:(NSString *)businessId
                                categoryId:(NSString *)categoryId
                                  complete:(void(^)(NSString *status,NSString* msg, NSArray*goodsList ,NSString *guide))complete;

+ (void)setCommentUseful:(BOOL)isUseful
                  userId:(NSString *)userId
                reviewId:(NSString *)reviewId
              completion:(void(^)(NSString *status, NSString *msg))completion;

+ (void)submitVenuesMistakeWithUserId:(NSString *)userId
                               cityId:(NSString *)cityId
                             venuesId:(NSString *)venuesId
                          venuesCatId:(NSString *)venuesCatId
                           typeString:(NSString *)typeString
                              content:(NSString *)content
                           completion:(void(^)(NSString *status, NSString *msg))completion;


@end
