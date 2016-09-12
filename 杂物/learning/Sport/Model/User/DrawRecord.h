//
//  DrawRecord.h
//  Sport
//
//  Created by haodong  on 14/11/21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawRecord : NSObject

@property (copy, nonatomic) NSString *convertId;
@property (copy, nonatomic) NSString *giftId;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) NSDate *createDate;

@property (assign, nonatomic) int status;

@end
