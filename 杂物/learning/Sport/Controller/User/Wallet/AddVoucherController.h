//
//  AddVoucherController.h
//  Sport
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"

@class Voucher;
@protocol AddVoucherControllerDelegate <NSObject>
@optional

- (void)didAddVoucher:(Voucher *)voucher;

@end

@interface AddVoucherController : SportController
@property (assign, nonatomic) double orderAmount;
@property (copy, nonatomic) NSString *entry;
@property (copy, nonatomic) NSString *goodsIds;
@property (copy, nonatomic) NSString *orderType;
@property (weak, nonatomic) id<AddVoucherControllerDelegate> delegate;
@end
