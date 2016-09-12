//
//  BusinessCategory.h
//  Sport
//
//  Created by ;  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessCategory : NSObject

@property (copy, nonatomic) NSString *businessCategoryId;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger totalCount;
@property (assign, nonatomic) NSInteger canOrderCount;
@property (copy, nonatomic) NSString *imageUrl;
@property (copy, nonatomic) NSString *activeImageUrl;
@property (copy, nonatomic) NSString *smallImageUrl;
@property (assign, nonatomic) BOOL isSupportClub;
@property (copy, nonatomic) NSString *iconUrl;

- (NSString *)sportName;

@end
