//
//  SignInService.h
//  Sport
//
//  Created by lzy on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@class ShareContent;
@interface SignInService : NSObject

+ (void)getNearbyVenuesWithLatitude:(double)latitude
                          longitude:(double)longitude
                         completion:(void(^)(NSString *status, NSString *msg, NSArray *venuesArray))completion;

+ (void)signInWithUserID:(NSString *)userId
                venuesId:(NSString *)venuesId
              completion:(void(^)(NSString *status, NSString *msg, NSDictionary *data, ShareContent *shareContent))completion;

+ (void)writeSignInDiaryWithUserId:(NSString *)userId
                          signInId:(NSString *)signInId
                           content:(NSString *)content
                         attachIds:(NSString *)attachIds
                         coterieId:(NSString *)coterieId
                        completion:(void(^)(NSString *status, NSString *msg))completion;

+ (void)getSignInDiaryListWithUserId:(NSString *)userId
                                page:(int)page
                               count:(int)count
                          completion:(void(^)(NSString *status, NSString *msg, NSDictionary *data))completion;

+ (void)getSignInRecordsWithUserId:(NSString *)userId
                        completion:(void(^)(NSString *status, NSString *msg, NSArray *weeklyModelArray, NSString *signInTips, NSString *wisdomAuthor, NSString *wisdomContent))completion;

@end
