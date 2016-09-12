//
//  PostListView.h
//  Sport
//
//  Created by haodong  on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumPostCell.h"
#import "ForumService.h"
#import "NoDataView.h"
@protocol PostListViewDelegate <NSObject>
@optional

@end

@interface PostListView : UIView <ForumPostCellDelegate, ForumServiceDelegate, UITableViewDataSource,UITableViewDelegate,NoDataViewDelegate>
#define COUNT_ONE_PAGE  20
#define PAGE_START      1

@property (assign, nonatomic) NSUInteger finishPage;

+ (PostListView *)createPostListViewWithFrame:(CGRect)frame
                                   controller:(UIViewController *)controller
                                     delegate:(id<PostListViewDelegate>)delegate
                                         type:(PostListType)type
                                    coterieId:(NSString *)coterieId
                                       userId:(NSString *)userId;

- (void)beginRefreshing;

- (void)scrollVIewToTopToYes;
- (void)scrollVIewToTopToNo;



@end
