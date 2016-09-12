//
//  MoneyRecordController.h
//  Sport
//
//  Created by haodong  on 15/3/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"
#import "MembershipCardService.h"

typedef enum
{
    RecordTypeMoney = 0,
    RecordTypeMembershipcard = 1,
}RecordType;

@interface MoneyRecordController : SportController<UserServiceDelegate, MembershipCardServiceDelegate>
- (instancetype)initWithMoney:(float)money
                         type:(RecordType)type;

- (instancetype)initWithMoney:(float)money
                   cardNumber:(NSString *)cardNumber
                         type:(RecordType)type
                   cardMobile:(NSString *)cardMobile
                      venueId:(NSString *)venueId;

@end
