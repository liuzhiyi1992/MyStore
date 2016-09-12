//
//  SearchResultTableView.h
//  Sport
//
//  Created by 冯俊霖 on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SearchResultTableViewDelegate <NSObject>;
@optional
- (void)didSelectedTableViewCellWithWord:(NSString *)word;
@end

@interface SearchResultTableView : UITableView
@property (assign, nonatomic) id<SearchResultTableViewDelegate>searchDelegate;

+ (SearchResultTableView *)createSearchResultTableView;

- (void)reloadSearchResultTableViewWithText:(NSString *)text;

@end
