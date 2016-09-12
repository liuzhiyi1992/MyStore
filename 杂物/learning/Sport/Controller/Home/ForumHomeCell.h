//
//  ForumHomeCell.h
//  Sport
//
//  Created by haodong  on 15/5/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface ForumHomeCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)updateCellWithImage:(UIImage *)image
                       name:(NSString *)name
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast;

@end
