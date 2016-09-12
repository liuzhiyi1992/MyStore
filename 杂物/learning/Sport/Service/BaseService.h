//
//  BaseService.h
//  Sport
//
//  Created by haodong  on 13-8-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@protocol BaseServiceDelegate <NSObject>
@optional
- (void)didQueryCityList:(NSArray *)cityList
                  status:(NSString *)status;
- (void)didFeedback:(NSString *)status msg:(NSString *)msg;

- (void)didQueryConfigData:(NSString *)status;

- (void)didQueryUserProvinceList:(NSArray *)provinceList
                          status:(NSString *)status;

- (void)didQueryStaticData:(NSString *)status resultDictionary:(NSDictionary *)resultDictionary;

- (void)didGetQydToken:(NSString *)status
                      msg:(NSString *)msg
                   expire:(int)expireTime;

//- (void)didGetUserToken:(NSString *)status
//                      msg:(NSString *)msg
//                    token:(NSString *)token
//                   expire:(int)expireTime;

@end

@interface BaseService : NSObject

+ (BaseService *)defaultService;

- (void)queryCityList:(id<BaseServiceDelegate>)delegate;

- (void)feedback:(id<BaseServiceDelegate>)delegate
         content:(NSString *)content
          userId:(NSString *)userId
            type:(int)type;

//- (void)queryConfigData:(id<BaseServiceDelegate>)delegate;

- (void)queryUserProvinceList:(id<BaseServiceDelegate>)delegate;

- (void)queryStaticData:(id<BaseServiceDelegate>)delegate;

- (void)getQydTokenWithDevice:(NSString *)deviceId
                       userId:(NSString *)userId
                  loginEncode:(NSString *)loginEncode
                     complete:(void(^)(NSString *status,NSString* msg, int expireTime))complete;

//- (void)getUserToken:(id<BaseServiceDelegate>)delegate
//              device:(NSString *)deviceId
//              userId:(NSString *)userId
//         loginEncode:(NSString *)loginEncode;
@end
