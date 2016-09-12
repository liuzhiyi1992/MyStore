//
//  SearchResultCell.h
//  Sport
//
//  Created by 冯俊霖 on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Business;

@interface SearchResultCell : DDTableViewCell

//- (void)updateCell:(Business *)business
//         indexPath:(NSIndexPath *)indexPath
//            isLast:(BOOL)isLast;

- (void)updateCell:(Business *)business
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
    isShowCategory:(BOOL)isShowCategory
        searchText:(NSString *)searchText;

@end
