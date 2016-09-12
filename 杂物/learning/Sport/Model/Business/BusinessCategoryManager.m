//
//  BusinessCategoryManager.m
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessCategoryManager.h"
#import "BusinessCategory.h"
#import "SportNetworkContent.h"
#import "OtherServiceItem.h"

static BusinessCategoryManager *_globalBusinessCategoryManager = nil;

@implementation BusinessCategoryManager

+ (BusinessCategoryManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalBusinessCategoryManager == nil) {
            _globalBusinessCategoryManager = [[BusinessCategoryManager alloc] init];
        }
    });

    return _globalBusinessCategoryManager;
}

- (NSString *)monthCardCategoryNameById:(NSString *)categoryId
{
    NSArray *list = ([_monthCardAllCategories count] > 0 ? _monthCardAllCategories : _defaultAllCategories);
    
    if ([categoryId isEqualToString:MONTHCARD_CATEGORY_ID_ALL]) {
        return MONTHCARD_CATEGORY_NAME_ALL;
    }
    
    for (BusinessCategory *category in list) {
        if ([category.businessCategoryId isEqualToString:categoryId]) {
            return category.name;
        }
    }

    return nil;
}


- (NSString *)categoryNameById:(NSString *)categoryId
{
    NSArray *list = ([_currentAllCategories count] > 0 ? _currentAllCategories : _defaultAllCategories);
    
    for (BusinessCategory *category in list) {
        if ([category.businessCategoryId isEqualToString:categoryId]) {
            return category.name;
        }
    }
    
    if ([categoryId isEqualToString:DEFAULT_CATEGORY_ID]) {
        return DEFAULT_CATEGORY_NAME;
    }
    
    return nil;
}

- (BusinessCategory *)categoryById:(NSString *)categoryId
{
    NSArray *list = ([_currentAllCategories count] > 0 ? _currentAllCategories : _defaultAllCategories);
    
    for (BusinessCategory *category in list) {
        if ([category.businessCategoryId isEqualToString:categoryId]) {
            return category;
        }
    }
    return nil;
}

@end
