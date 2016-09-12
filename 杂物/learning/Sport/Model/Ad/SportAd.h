//
//  SportAd.h
//  Sport
//
//  Created by haodong  on 14-5-4.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SportAd : NSObject

@property (copy, nonatomic) NSString *adId;
@property (copy, nonatomic) NSString *adLink;
@property (copy, nonatomic) NSString *adName;
@property (copy, nonatomic) NSString *imageUrl;

@property (assign, nonatomic) int type;

@end
