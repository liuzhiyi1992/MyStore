//
//  ConfirmPayTypeCell.h
//  Sport
//
//  Created by haodong  on 15/4/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

typedef NS_ENUM(NSInteger,ConfirmPayType){
    ConfirmPayTypeNone = -1,
    ConfirmPayTypeOnline = 0,
    ConfirmPayTypeMembershipCard = 1,
    ConfirmPayTypeClub = 2,
};

@protocol ConfirmPayTypeCellDelegate <NSObject>

- (NSString *)getSelectedMembershipCardNumber;
- (void)setSelectedMembershipCardNumber:(NSString *)cardNumber;

@end


@interface ConfirmPayTypeCell : DDTableViewCell<UITableViewDelegate,UITableViewDataSource>

- (void)updateCellWithType:(ConfirmPayType)type
                isSelected:(BOOL)isSelected
                  subTitle:(NSString *)subTitle
                 indexPath:(NSIndexPath *)indexPath
                    isLast:(BOOL)isLast;

- (void)updateCellWithType:(ConfirmPayType)type
                isSelected:(BOOL)isSelected
                  subTitle:(NSString *)subTitle
                 indexPath:(NSIndexPath *)indexPath
                    isLast:(BOOL)isLast
                  cardList:(NSArray *)list;
@property (strong, nonatomic) NSArray *cardList;
@property (assign, nonatomic) id<ConfirmPayTypeCellDelegate> delegate;

@end
