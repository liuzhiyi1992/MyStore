//
//  MembershipCardRecord.h
//  Sport
//
//  Created by haodong  on 15/4/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    MembershipCardRecordTypeCharge = 6,
    MembershipCardRecordTypeUsed = 7,
} MembershipCardRecordType;


@interface MembershipCardRecord : NSObject
@property (assign, nonatomic) MembershipCardRecordType type;
@property (assign, nonatomic) float amount;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) NSDate *addTime;
@end
