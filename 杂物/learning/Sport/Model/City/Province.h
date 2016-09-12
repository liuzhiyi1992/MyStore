//
//  Province.h
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Province : NSObject

@property (copy, nonatomic) NSString *provinceId;
@property (copy, nonatomic) NSString *provinceName;
@property (strong, nonatomic) NSArray *cityList;

@end
