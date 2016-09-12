//
//  MonthCard.h
//  Sport
//
//  Created by 江彦聪 on 15/6/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    CARD_STATUS_INVALID = 0,        //月卡不存在
    CARD_STATUS_VALID = 1,          //可用
    CARD_STATUS_NO_IMAGE = 2,       //没有头像
    CARD_STATUS_FROZEN = 3,         //被冻结
    CARD_STATUS_EXPIRED = 4,        //已过期
    CARD_STATUS_ONCE_PERDAY = 5,    //当天已经预约了或已使用一次
    CARD_STATUS_CANCEL_TRIPLE = 6,  //
}CARD_STATUS;

@interface MonthCard : NSObject
@property (strong, nonatomic) NSString *cardId;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *avatarImageURL;
@property (strong, nonatomic) NSString *avatarThumbURL;
@property (assign, nonatomic) CARD_STATUS cardStatus;
@property (strong, nonatomic) NSDate *endTime;

@end
