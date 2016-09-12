//
//  MoneyRecord.h
//  Sport
//
//  Created by haodong  on 15/3/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    MoneyRecordTypeUsed = 0,
    MoneyRecordTypeRefund = 1,
} MoneyRecordType;

@interface MoneyRecord : NSObject

@property (assign, nonatomic) MoneyRecordType type;
@property (assign, nonatomic) float money;
@property (strong, nonatomic) NSDate *createTime;
@property (copy, nonatomic) NSString *desc;

@end
