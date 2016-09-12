//
//  MainService.h
//  Sport
//
//  Created by xiaoyang on 16/6/8.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainControllerCategory, SignIn;

@protocol MainServiceDelegate <NSObject>
@optional

- (void)didQueryIndexWithAdList:(NSArray *)adList
                   mainControllerCategory:(MainControllerCategory *)mainControllerCategory
                             businessList:(NSArray *)businessList
                            courtJoinList:(NSArray *)courtJoinList
                                   signIn:(SignIn *)signIn
                            currentCityId:(NSString *)currentCityId
                                   status:(NSString *)status
                                      msg:(NSString *)msg;


@end

@interface MainService : NSObject

+ (void)queryIndex:(id<MainServiceDelegate>)delegate
          UserId:(NSString *)userId
          cityId:(NSString *)cityId
        latitude:(NSString *)latitude
       longitude:(NSString *)longitude
        categoryId:(NSString *)categoryId;

@end
