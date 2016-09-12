//
//  BusinessCategoryManager.h
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_CATEGORY_ID     @"1"
#define DEFAULT_CATEGORY_NAME   @"羽毛球场"

#define MONTHCARD_CATEGORY_ID_ALL @"0"
#define MONTHCARD_CATEGORY_NAME_ALL @"所有项目"

@class BusinessCategory;
@class OtherServiceItem;

@interface BusinessCategoryManager : NSObject
@property (copy, nonatomic) NSString *currentRecordCityId;
@property (strong, nonatomic) NSArray *currentAllCategories;
@property (strong, nonatomic) NSArray *defaultAllCategories;
@property (strong, nonatomic) NSArray *monthCardAllCategories;

+ (BusinessCategoryManager *)defaultManager;

- (NSString *)categoryNameById:(NSString *)categoryId;
- (BusinessCategory *)categoryById:(NSString *)categoryId;
- (NSString *)monthCardCategoryNameById:(NSString *)categoryId;
//- (NSString *)sportNameById:(NSString *)categoryId;
//- (OtherServiceItem *)otherServiceItemById:(NSString *)otherServiceId;

@end
