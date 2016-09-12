//
//  MembershipCardVerifyManager.h
//  Sport
//
//  Created by 江彦聪 on 15/4/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MembershipCardVerifyManager : NSObject

@property (strong, nonatomic) NSDate *sendVerificationTime;

+ (MembershipCardVerifyManager *)defaultManager;


@end
