//
//  SportFilterCell.h
//  Sport
//
//  Created by qiuhaodong on 15/7/27.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface SportFilterCell : DDTableViewCell

+ (id)createCellWithHasImage:(BOOL)hasImage;

- (void)updateCellWithImageUrl:(NSString *)imageUrl content:(NSString *)content isSelected:(BOOL)isSelected;

@end
