//
//  CourtJoinInfoCell.h
//  Sport
//
//  Created by 江彦聪 on 16/6/8.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

@interface CourtJoinInfoCell : DDTableViewCell
-(void) updateViewWithTitle:(NSString *)title
                     detail:(NSString *)detail
                isShowArrow:(BOOL) isShowArrow;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end
