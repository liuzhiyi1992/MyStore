//
//  BusinessManager.m
//  Sport
//
//  Created by haodong  on 13-6-26.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessManager.h"
#import "Business.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"
#import "DayBookingInfo.h"
#import "Court.h"
#import "Product.h"
#import "ProductGroup.h"
#import "BusinessCategory.h"
#import "OtherServiceItem.h"
#import "Goods.h"
#import "Service.h"
#import "ServiceGroup.h"
#import "ParkingLot.h"
#import "ShareContent.h"
#import "SDWebImageDownloader.h"

static BusinessManager *_globalBusinessManager = nil;

@implementation BusinessManager

+ (BusinessManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalBusinessManager == nil) {
            _globalBusinessManager = [[BusinessManager alloc] init];
        }
    });
    return _globalBusinessManager;
}

+ (Business *)businessByOneBusinessJson:(NSDictionary *)dic
{
    if (dic == nil) {
        return nil;
    }
    
    Business *business = [[Business alloc] init];
    business.businessId = [dic validStringValueForKey:PARA_BUSINESS_ID];
    business.name = [dic validStringValueForKey:PARA_NAME];
    business.imageUrl = [dic validStringValueForKey:PARA_IMAGE_URL];
    
    business.smallImageUrl = [dic validStringValueForKey:PARA_INDEX_IMAGE];
    
    business.price = [dic validFloatValueForKey:PARA_PRICE];
    business.promotePrice = [dic validFloatValueForKey:PARA_PROMOTE_PRICE];
    
    business.neighborhood = [dic validStringValueForKey:PARA_SUB_REGION];
    business.address = [dic validStringValueForKey:PARA_ADDRESS];
    business.telephone = [dic validStringValueForKey:PARA_TELEPHONE];
    business.latitude = [[dic validStringValueForKey:PARA_LATITUDE] doubleValue];
    business.longitude = [[dic validStringValueForKey:PARA_LONGITUDE] doubleValue];
    
    business.promoteList = (NSArray *)[dic objectForKey:PARA_PROMOTE_LIST];
    
    id categoryList = [dic objectForKey:PARA_CATEGORIES];
    if ([categoryList isKindOfClass:[NSArray class]]) {
        NSMutableArray *cList = [NSMutableArray array];
        for (id one in categoryList) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            } else {
                BusinessCategory *category = [[BusinessCategory alloc] init] ;
                category.businessCategoryId = [one validStringValueForKey:PARA_CATEGORY_ID];
                category.name = [one validStringValueForKey:PARA_CATEGORY_NAME];
                category.smallImageUrl = [one validStringValueForKey:PARA_SMALL_IMAGE_URL];
                [cList addObject:category];
            }
        }
        business.categoryList = cList;
    }
    
    business.cityId = [(NSDictionary *)dic validStringValueForKey:PARA_CITY_ID];
    business.regionId = [(NSDictionary *)dic validStringValueForKey:PARA_REGION_ID];
    business.defaultCategoryId = [(NSDictionary *)dic validStringValueForKey:PARA_CATEGORY_ID];
    business.commentCount = [(NSDictionary *)dic validIntValueForKey:PARA_COMMENT_COUNT];
    
    business.imageCount = [dic validIntValueForKey:PARA_IMAGE_COUNT];
    business.mainImageCount = [dic validIntValueForKey:PARA_MAIN_IMAGE_COUNT];
    
    
    business.canOrder = [(NSDictionary *)dic validBoolValueForKey:PARA_CAN_ORDER];
    business.orderType = [(NSDictionary *)dic validBoolValueForKey:PARA_ORDER_TYPE];
    
    int intIsOften = [dic validIntValueForKey:PARA_IS_OFTEN];
    business.isOften = (intIsOften != 0);
    
    int intIsCollect = [dic validIntValueForKey:PARA_IS_COLLECT];
    business.isCollect = (intIsCollect != 0);
    
    business.announcement = [dic validStringValueForKey:PARA_NOTICE];
    business.rating = [dic validFloatValueForKey:PARA_COMMENT_AVG];
    
    business.startHour = [dic validIntValueForKey:PARA_START_HOUR];
    business.endHour = [dic validIntValueForKey:PARA_END_HOUR];
    
    business.transitInfo = [dic validStringValueForKey:PARA_TRANSIT_INFO];
    business.metroInfo = [dic validStringValueForKey:PARA_METRO_INFO];
    
    business.canRefund = ([dic validIntValueForKey:PARA_IS_REFUND] != 0);
    business.refundMessage = [dic validStringValueForKey:PARA_REFUND_MESSAGE];
   
    int intIsCardUser = [dic validIntValueForKey:PARA_IS_CARD_USER];
    business.isCardUser = (intIsCardUser != 0);
    
//    NSArray *serviceListSource = [dic validArrayValueForKey:PARA_SERVICE_LIST];
//    NSMutableArray *serverList = [NSMutableArray array];
//    for (NSDictionary *one in serviceListSource) {
//        Facility *facility = [[Facility alloc] init] ;
//        facility.name          = [one validStringValueForKey:PARA_NAME];
//        facility.valueList     = [one validArrayValueForKey:PARA_LIST];
//        facility.imageCount    = [one validIntValueForKey:PARA_IMAGE_COUNT];
//        facility.thumbImageUrl = [one validStringValueForKey:PARA_THUMB_URL];
//        facility.iconImageUrl  = [one validStringValueForKey:PARA_ICON_URL];
//        [serverList addObject:facility];
//    }
//    business.serviceList = serverList;
    
    NSArray *serviceGroupSource = [dic validArrayValueForKey:PARA_SERVICE_LIST];
    NSMutableArray *serviceGroupOfArray = [[NSMutableArray alloc]init];
    //NSMutableArray *arrayOfServiceTitle = [[NSMutableArray alloc]init];
    
    for (NSDictionary *one in serviceGroupSource ){
        ServiceGroup *serviceGroup = [[ServiceGroup alloc]init];
        
        serviceGroup.title = [one validStringValueForKey:PARA_TITLE];
        NSArray *serviceSource = [one validArrayValueForKey:PARA_LIST];
        //[arrayOfServiceTitle addObject:serviceGroup.title];
        
         NSMutableArray *serviceOfArray =[[NSMutableArray alloc]init];
        
        for(NSDictionary *two in serviceSource){
            if (![two isKindOfClass:[NSDictionary class]]) {
                break;
            }
            Service *service = [[Service alloc]init];
            
            service.name=[two validStringValueForKey:PARA_NAME];
            service.content = [two validStringValueForKey:PARA_CONTENT];
            service.isPark = [two validBoolValueForKey:PARA_IS_PARK];
            [serviceOfArray addObject:service];
        }
        serviceGroup.serviceList = serviceOfArray;
       
        [serviceGroupOfArray addObject:serviceGroup];
    }
    business.serviceGroupList = serviceGroupOfArray;
   // business.serviceGroupListTitle =arrayOfServiceTitle;
    
    
    NSArray *facilityListImageSource = [dic validArrayValueForKey:PARA_FACILITY_LIST_IMAGE];
    NSMutableArray *facilityImageList = [NSMutableArray array];
    for (NSDictionary *one in facilityListImageSource) {
        Facility *facility = [[Facility alloc] init];
        facility.name          = [one validStringValueForKey:PARA_NAME];
        facility.imageCount    = [one validIntValueForKey:PARA_IMAGE_COUNT];
        facility.thumbImageUrl = [one validStringValueForKey:PARA_THUMB_URL];
        facility.iconImageUrl  = [one validStringValueForKey:PARA_ICON_URL];
        [facilityImageList addObject:facility];
    }
    business.facilityList = facilityImageList;
    
    business.monthCardShareUrl = [dic validStringValueForKey:PARA_SHARE_URL];
    
    business.moncardNotice = [dic validStringValueForKey:PARA_MONCARD_NOTICE];
    
    business.isSupportClub = [dic validIntValueForKey:PARA_IS_SUPPORT_CLUB];
    
    business.idleVenue = [dic validStringValueForKey:PARA_IDLE_VENUE];
    
    business.refundTips = [dic validStringValueForKey:PARA_REFUND_TIPS];
    
    NSArray *parkListSource = [dic validArrayValueForKey:PARA_PARK_LIST];
    NSMutableArray *parkList = [NSMutableArray array];
    for (NSDictionary *one in parkListSource) {
        ParkingLot *pl = [[ParkingLot alloc] init];
        pl.lat = [one validFloatValueForKey:PARA_LATITUDE];
        pl.lon = [one validFloatValueForKey:PARA_LONGITUDE];
        pl.name = [one validStringValueForKey:PARA_NAME];
        [parkList addObject:pl];
    }
    business.parkingLotList = parkList;
    
    NSDictionary *shareInfo = [dic validDictionaryValueForKey:PARA_SHARE_INFO];
    ShareContent *shareContent = [[ShareContent alloc] init];
    shareContent.title = [shareInfo validStringValueForKey:PARA_TITLE];
    shareContent.subTitle = [shareInfo validStringValueForKey:PARA_CONTENT];
    shareContent.linkUrl = [shareInfo validStringValueForKey:PARA_URL];
    shareContent.imageUrL = [shareInfo validStringValueForKey:PARA_LOGO];
    shareContent.content = [shareInfo validStringValueForKey:PARA_CONTENT];
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    [downloader downloadImageWithURL:[NSURL URLWithString:shareContent.imageUrL]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                // progression tracking code
                            }
                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                               if (image && finished) {
                                   shareContent.thumbImage = image;
                               }
                           }];
    business.shareContent = shareContent;
    
    return  business;
}

+ (NSArray *)businessListByDictionary:(NSDictionary *)dictionary
{
    id dicList = [dictionary objectForKey:PARA_BUSINESSES];
    if ([dicList isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    NSMutableArray *businesses = [NSMutableArray array];
    for (id dic in (NSArray *)dicList) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            Business *business = [self businessByOneBusinessJson:dic];
            [businesses addObject:business];
        }
    }
    return businesses;
}

//复制了上一个，考虑合并
+ (NSArray *)favoriteBusinessListByDictionary:(NSDictionary *)dictionary
{
    id dicList = [dictionary objectForKey:PARA_LIST];
    if ([dicList isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    NSMutableArray *businesses = [NSMutableArray array];
    for (id dic in (NSArray *)dicList) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            Business *business = [self businessByOneBusinessJson:dic];
            [businesses addObject:business];
        }
    }
    return businesses;
}

+ (NSArray *)mapBusinessListByDictionary:(NSDictionary *)dictionary
{
    id dicList = [dictionary objectForKey:PARA_LIST];
    if ([dicList isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    NSMutableArray *businesses = [NSMutableArray array];
    for (id dic in (NSArray *)dicList) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            Business *business = [self businessByOneBusinessJson:dic];
            [businesses addObject:business];
        }
    }
    return businesses;
}

//每个场的产品
+ (Court *)courtByDictionary:(NSDictionary *)oneCourseSource
{
    Court *oneCourseTarget = [[Court alloc] init] ;
    oneCourseTarget.courtId = [oneCourseSource validStringValueForKey:PARA_COURSE_ID];
    oneCourseTarget.name = [oneCourseSource validStringValueForKey:PARA_COURSE_NAME];
    oneCourseTarget.positionName = [oneCourseSource validStringValueForKey:PARA_POSITION_NAME];
    
    //小时列表
    NSArray *itemListSource = [oneCourseSource validArrayValueForKey:PARA_ITEMS];
    NSMutableArray *itemListTarget = [NSMutableArray array];
    for (id oneItemSource in itemListSource) {
        if (! [oneItemSource isKindOfClass:[NSString class]]) {
            continue;
        }
        
        NSArray *valueList = [(NSString *)oneItemSource componentsSeparatedByString:@","];
        if ([valueList count] >= 4) {
            Product *product = [[Product alloc] init] ;
            product.productId = [valueList objectAtIndex:0];
            product.startTime = [valueList objectAtIndex:1];
            product.price = [[valueList objectAtIndex:2] floatValue];
            product.status = [[valueList objectAtIndex:3] intValue];
            product.courtId = oneCourseTarget.courtId;
            if ([oneCourseTarget.positionName length] > 0) {
                product.courtName = [NSString stringWithFormat:@"%@(%@)", oneCourseTarget.name, oneCourseTarget.positionName];
            } else {
                product.courtName = oneCourseTarget.name;
            }
            
            [itemListTarget addObject:product];
        }
        
    }
    oneCourseTarget.productList = itemListTarget;
    
    //打包列表
    id groupListSource = [oneCourseSource objectForKey:PARA_GROUP_LIST];
    NSMutableArray *groupListTarget = [NSMutableArray array];
    for (id oneGroupSource in (NSArray *)groupListSource) {
        if ([oneGroupSource isKindOfClass:[NSDictionary class]] == NO) {
            continue;
        }
        ProductGroup *group = [[ProductGroup alloc] init] ;
        group.groupId = [oneGroupSource validStringValueForKey:PARA_GROUP_ID];
        NSString *goodsIds = [oneGroupSource validStringValueForKey:PARA_GOODS_IDS];
        group.productIdList = [goodsIds componentsSeparatedByString:@","];
        [groupListTarget addObject:group];
    }
    oneCourseTarget.productGroupList = groupListTarget;
    
    return oneCourseTarget;
}

+ (Goods *)goodsByDictionary:(NSDictionary *)dictionary
{
    Goods *goods = [[Goods alloc] init];
    goods.goodsId = [dictionary validStringValueForKey:PARA_GOODS_ID];
    goods.name = [dictionary validStringValueForKey:PARA_GOODS_NAME];
    goods.price = [dictionary validFloatValueForKey:PARA_PRICE];
    goods.promotePrice = [dictionary validFloatValueForKey:PARA_PROMOTE_PRICE];
    goods.totalCount = [dictionary validIntValueForKey:PARA_GOODS_NUMBER];
    goods.limitCount = [dictionary validIntValueForKey:PARA_LIMIT_NUMBER];
    goods.desc = [dictionary validStringValueForKey:PARA_DESCRIPTION];
    goods.detailUrl = [dictionary validStringValueForKey:PARA_DETAIL_URL];
    goods.promoteMessage = [dictionary validStringValueForKey:PARA_PROMOTE_MESSAGE];
    goods.businessName = [dictionary validStringValueForKey:PARA_NAME];
    goods.isSupportClub = [dictionary validStringValueForKey:PARA_IS_SUPPORT_CLUB];
    return goods;
}

+ (NSArray *)venuesListByDictionary:(NSDictionary *)dictionary
{
    id dicList = [dictionary objectForKey:PARA_DATA];
    if ([dicList isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    NSMutableArray *businesses = [NSMutableArray array];
    for (id dic in (NSArray *)dicList) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            Business *business = [self businessByOneMonthCardBusinessJson:dic];
            [businesses addObject:business];
        }
    }
    return businesses;
}


+ (Business *)businessByOneMonthCardBusinessJson:(NSDictionary *)dic
{
    if (dic == nil) {
        return nil;
    }
    
    Business *business = [[Business alloc] init] ;
    business.businessId = [dic validStringValueForKey:PARA_VENUES_ID];
    business.defaultCategoryId = [dic validStringValueForKey:PARA_CATEGORY_ID];
    business.name = [dic validStringValueForKey:PARA_VENUES_NAME];
    business.imageUrl = [dic validStringValueForKey:PARA_IMAGE_URL];
    
    business.smallImageUrl = [dic validStringValueForKey:PARA_INDEX_IMAGE];
    business.neighborhood = [dic validStringValueForKey:PARA_SUB_REGION];
    business.address = [dic validStringValueForKey:PARA_ADDRESS];
    business.telephone = [dic validStringValueForKey:PARA_TELEPHONE];
    business.latitude = [[dic validStringValueForKey:PARA_LATITUDE] doubleValue];
    business.longitude = [[dic validStringValueForKey:PARA_LONGITUDE] doubleValue];
    business.isRecommend =[dic validBoolValueForKey:PARA_IS_RECOMMEND];
    business.businessDate =[dic validDateValueForKey:PARA_BUSINESS_DATE];
    id categoryList = [dic objectForKey:PARA_CATEGORY_LIST];
    if ([categoryList isKindOfClass:[NSArray class]]) {
        NSMutableArray *cList = [NSMutableArray array];
        for (id one in categoryList) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            } else {
                BusinessCategory *category = [[BusinessCategory alloc] init] ;
                category.businessCategoryId = [one validStringValueForKey:PARA_CATEGORY_ID];
                category.imageUrl = [one validStringValueForKey:PARA_IMG_URL];
                [cList addObject:category];
            }
        }
        business.categoryList = cList;
    }
    
    return  business;
}

@end
