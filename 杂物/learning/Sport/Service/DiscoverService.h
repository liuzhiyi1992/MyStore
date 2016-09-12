//
//  DiscoverService.h
//  Sport
//
//  Created by xiaoyang on 16/6/25.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiscoverServiceDelegate <NSObject>
@optional
- (void)getDataWithDiscoverList:(NSArray *)discoverList
                         status:(NSString *)status
                            msg:(NSString *)msg;

@end

@interface DiscoverService : NSObject
+ (void)queryDiscover:(id<DiscoverServiceDelegate>)delegate
               cityId:(NSString *)cityId;

@end
