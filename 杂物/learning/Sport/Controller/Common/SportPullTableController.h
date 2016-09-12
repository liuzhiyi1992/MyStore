//
//  SportPullTableController.h
//  Sport
//
//  Created by haodong  on 13-8-3.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "STableViewController.h"
#import "UIViewController+Sport.h"

//to do 弃用
@interface SportPullTableController : STableViewController


//子类在以下这两个方法里面，写入下拉和上拉要运行的代码
- (void)refreshDataStart;
- (void)loadMorDataStart;

//在下拉和上拉后，并且加载玩数据后要调用以下两个方法来刷新header和footer界面
//[self refreshCompleted];
//[self loadMoreCompleted];
//注意在调用[self loadMoreCompleted]之前设置self.canLoadMore = NO/YES;

//例如在
//- (void)refreshDataStart
//{
//    [[XXX defaultService] quert:xxx delegate:xxx];
//}
//- (void)xxxDelegateMethod
//{
//    self.canLoadMore = YES;
//    [self.tableView reloadData];
//    [self refreshCompleted];
//}

//例如在
//- (void)loadMorDataStart
//{
//    [[XXX defaultService] quert:xxx delegate:xxx];
//}
//- (void)xxxDelegateMethod
//{
//    if (XXX == XXX)
//        self.canLoadMore = NO;
//    else
//        self.canLoadMore = YES;
//    [self.tableView reloadData];
//    [self refreshCompleted];
//}

@end
