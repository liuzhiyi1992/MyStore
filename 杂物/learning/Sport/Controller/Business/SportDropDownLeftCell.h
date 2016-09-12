//
//  SportDropDownLeftCell.h
//  Sport
//
//  Created by 冯俊霖 on 15/10/9.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface SportDropDownLeftCell : DDTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

+ (id)createCell;

- (void)updateCellWithTitle:(NSString *)title;

@end
