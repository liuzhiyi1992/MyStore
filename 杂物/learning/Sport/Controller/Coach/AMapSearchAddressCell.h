//
//  AMapSearchAddressCell.h
//  Sport
//
//  Created by 江彦聪 on 15/10/17.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface AMapSearchAddressCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
- (void)updateCellWithTitle:(NSString *)title
                   subTitle:(NSString *)subTitle
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast;
@end
