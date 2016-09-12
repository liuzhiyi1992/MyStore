//
//  Voucher.h
//  Sport
//
//  Created by haodong  on 14-5-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

//0未激活1已激活2已使用3已过期4已邦定
typedef enum {
    VoucherStatusNotActive = 0,
    VoucherStatusActive = 1,
    VoucherStatusUsed = 2,
    VoucherStatusInvalid = 3,
    VoucherStatusHasBind = 4,
} VoucherStatus;

typedef enum {
    VoucherTypeDefault = 1,
    VoucherTypeSport = 2
} VoucherType;

@interface Voucher : NSObject

@property (assign, nonatomic) VoucherType type;
@property (copy, nonatomic) NSString *voucherId;
@property (copy, nonatomic) NSString *voucherNumber;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *desc;
//use_end_date
@property (strong, nonatomic) NSDate *validDate;
@property (assign, nonatomic) double amount;
@property (assign, nonatomic) VoucherStatus status;
@property (assign, nonatomic) double minAmount; //能使用代金券的订单的最小金额
@property (assign, nonatomic) double maxAmount;
@property (copy, nonatomic) NSString *disableMessage;
@property (copy, nonatomic) NSString *couponName;
@property (assign, nonatomic) BOOL isEnable; //在使用代金券时判断
@property (strong, nonatomic) NSDate *useStartDate;
@property (assign, nonatomic) int endDate;
@property (copy, nonatomic) NSString *voucherName;       //票券名字
@property (copy, nonatomic) NSString *firstInstruction;  //第一点使用说明
@property (copy, nonatomic) NSString *secondInstruction; //第二点使用说明
@property (copy, nonatomic) NSString *thirdInstruction;  //第三点使用说明

-(BOOL)validToUse:(float)totalAmount;

-(float)minAmountToUse;

@end
