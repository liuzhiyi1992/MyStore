//
//  FastOrderEntrance.h
//  Sport
//
//  Created by 江彦聪 on 15/11/3.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FastOrderEntrance : NSObject

@property (copy, nonatomic) NSString *iconUrl;
@property (copy, nonatomic) NSString *businessName;
@property (copy, nonatomic) NSString *detailTimeString;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSDate *bookDate;
@property (strong, nonatomic) NSArray *goodsList;

@end
