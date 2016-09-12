//
//  CourtJoinUser.h
//  Sport
//
//  Created by Huan on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourtJoinUser : NSObject
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *avatarUrl;
@property (copy, nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *phoneNumber;
@property (assign, nonatomic) int orderStatus;//0-未支付 1-已支付
@end
