//
//  MembershipCardCell.h
//  Sport
//
//  Created by 江彦聪 on 15/4/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "MembershipCard.h"

@protocol MemberShipCardCellDelegate <NSObject>
@optional

-(void)didClickBindButton:(NSIndexPath *)indexPath;

@end

@interface MembershipCardCell : DDTableViewCell
- (void)updateCellWithCard:(MembershipCard *)card
                isSelected:(BOOL)isSelected
                 indexPath:(NSIndexPath *)indexPath;
+ (CGFloat)getCellHeightWithIndex:(NSIndexPath *)indexPath;

@property (assign,nonatomic) id<MemberShipCardCellDelegate> delegate;

@end
