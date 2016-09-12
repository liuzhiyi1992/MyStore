//
//  ConfirmOrder.h
//  Sport
//
//  Created by 江彦聪 on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
@class CourtJoin;
@interface ConfirmOrder : NSObject

@property (assign, nonatomic) float totalAmount;
@property (assign, nonatomic) float payAmount;
@property (assign, nonatomic) float promoteAmount;
@property (copy, nonatomic) NSString *selectedActivityId;
@property (strong, nonatomic) NSArray *activityList;
@property (assign, nonatomic) float onePrice;
@property (assign, nonatomic) float userMoney;
@property (assign, nonatomic) BOOL canRefund;
@property (copy, nonatomic) NSString *activityMessage;
@property (assign, nonatomic) BOOL isCardUser;
@property (copy, nonatomic) NSString *refundMessage;
@property (assign, nonatomic) BOOL isSupportClub;
@property (assign, nonatomic) int userClubStatus;
@property (copy, nonatomic) NSString *clubDisableMsg;
@property (copy, nonatomic) NSString *noBuyClubMsg;
@property (copy, nonatomic) NSString *noUsedClubOrderMsg;
@property (assign, nonatomic) BOOL isSupportMembershipCard;
@property (strong, nonatomic) NSArray *cardList;
@property (assign, nonatomic) BOOL isIncludeInsurance;
@property (strong, nonatomic) NSArray *insuranceList;
@property (copy, nonatomic) NSString *insuranceTips;
@property (copy, nonatomic) NSString *insuranceUrl;
@property (assign, nonatomic) int insuranceOrderTime;
@property (copy, nonatomic) NSString *insuranceLimitTips;
@property (assign, nonatomic) int ticketNumber;
@end
