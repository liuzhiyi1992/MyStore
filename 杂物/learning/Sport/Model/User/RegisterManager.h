//
//  RegisterManager.h
//  Sport
//
//  Created by haodong  on 13-6-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    VerificationErrorSucc = 0,
    VerificationErrorUnknow = 1,
    VerificationErrorInvalid = 2,
} VerificationErrorCode;

@interface RegisterManager : NSObject

@property (strong, nonatomic) NSDate *sendVerificationTime;

+ (RegisterManager *)defaultManager;

+ (BOOL)saveVerification:(NSString *)verification;
+ (NSString *)readVerification:(NSError **)error;

+ (BOOL)addOneSendVerificationCount:(int)type;
+ (NSUInteger)hasSendVerificationCount:(int)type;

@end
