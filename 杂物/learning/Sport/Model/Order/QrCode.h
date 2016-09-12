//
//  QrCode.h
//  Sport
//
//  Created by 江彦聪 on 16/8/6.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,QrCodeStatus) {
    QrCodeStatusNew = 0,
    QrCodeStatusUsed = 1,
    QrCodeStatusRefunding = 2,
    QrCodeStatusRefunded = 3,
};
@interface QrCode : NSObject
@property (copy, nonatomic) NSString *code;
@property (assign, nonatomic) QrCodeStatus status;
@property (strong, nonatomic) NSDate *usedTime;

@end
