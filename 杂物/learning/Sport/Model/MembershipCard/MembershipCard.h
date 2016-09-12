//
//  MembershipCard.h
//  Sport
//
//  Created by haodong  on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,CardStatus) {
    CardStatusUnbind = 0,
    CardStatusBind = 1,
    CardStatusLock = 5,
};

@interface MembershipCard : NSObject

@property (copy, nonatomic) NSString *cardNumber;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *businessName;
@property (assign, nonatomic) float money;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *phoneEncode;
@property (assign, nonatomic) int status; //1:已绑定，0:未绑定 5:锁定
@property (copy, nonatomic) NSString *oldPhone;  //修改手机号码前预留手机号码
@property (copy, nonatomic) NSString *oldPhoneEncode; //修改手机号码前预留手机号码(DEC加密)

@end
