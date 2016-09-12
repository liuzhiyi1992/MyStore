//
//  OpenInfo.h
//  Sport
//
//  Created by haodong  on 13-8-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

#define OPEN_TYPE_SINA          @"sina"
#define OPEN_TYPE_QQ            @"qq"
#define OPEN_TYPE_WX            @"wx"

@interface OpenInfo : NSObject

@property (copy, nonatomic) NSString *openType;
@property (copy, nonatomic) NSString *openUserId;
@property (copy, nonatomic) NSString *openNickname;

@end
