//
//  SportCommonCell.h
//  Sport
//
//  Created by haodong  on 13-7-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol SportCommonCellDelegate <NSObject>
@optional
- (void)didClickSportCommonCell:(NSIndexPath *)indexPath;
@end

@interface SportCommonCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *tipsCountButton;
@property (weak, nonatomic) IBOutlet UIImageView *redPointImageView;

@property (assign, nonatomic) id<SportCommonCellDelegate> delegate;

- (void)updateCell:(NSString *)valueString
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
         tipsCount:(NSUInteger)tipsCount
    isShowRedPoint:(BOOL)isShowRedPoint;

@end


