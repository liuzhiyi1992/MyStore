//
//  PayMethod.h
//  Sport
//
//  Created by haodong  on 15/4/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayMethod : NSObject

@property (copy, nonatomic) NSString *payId;
@property (copy, nonatomic) NSString *payKey;
@property (assign, nonatomic) BOOL isRecommend;

@end
