//
//  ForumCell.h
//  Sport
//
//  Created by haodong  on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Forum;

@interface ForumCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oftenImageView;

- (void)updateCellWithForum:(Forum *)forum
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast;

@end
