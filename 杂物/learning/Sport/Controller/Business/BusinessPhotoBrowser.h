//
//  BusinessPhotoBrowser.h
//  Sport
//
//  Created by 江彦聪 on 15/5/20.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportMWPhotoBrowser.h"
#import "BusinessService.h"
@class Business;
@interface BusinessPhotoBrowser : SportMWPhotoBrowser<BusinessServiceDelegate>

-(id)initWithOpenIndex:(NSUInteger)index
            businessId:(NSString *)businessId
            categoryId:(NSString *)categoryId
            totalCount:(NSUInteger)totalCount
              business:(Business *)business;

@end
