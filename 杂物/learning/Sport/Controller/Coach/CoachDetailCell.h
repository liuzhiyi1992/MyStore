//
//  CoachDetailCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol CoachDetailCellDelegate <NSObject>

@end

@interface CoachDetailCell : DDTableViewCell

- (void)updateCellWithTitle:(NSString *)title
                    content:(NSString *)content
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast
               contentColor:(UIColor *)contentColor;

@property (assign,nonatomic) id<CoachDetailCellDelegate> delegate;
@end
