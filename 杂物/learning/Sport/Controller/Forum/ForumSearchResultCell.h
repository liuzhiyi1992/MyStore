//
//  ForumSearchResultCell.h
//  Sport
//
//  Created by haodong  on 15/5/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface ForumSearchResultCell : DDTableViewCell

- (void)updateCellWith:(NSString *)name
                  city:(NSString *)city
             indexPath:(NSIndexPath *)indexPath
                isLast:(BOOL)isLast;

@end
