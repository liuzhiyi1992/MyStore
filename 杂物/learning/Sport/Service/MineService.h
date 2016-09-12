//
//  MineService.h
//  Sport
//
//  Created by 赵梦东 on 15/9/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
@class MineInfo;

@protocol MineServiceDelegate <NSObject>
@optional

- (void)didGetMineInfor:(MineInfo *)info
                 status:(NSString *)status
                    msg:(NSString *)msg ;


@end


@interface MineService : NSObject
+ (void)getMineInfor:(id<MineServiceDelegate>)delegate
               userId:(NSString *)userId;
@end
