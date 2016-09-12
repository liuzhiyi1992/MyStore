//
//  UserPostListController.m
//  Sport
//
//  Created by qiuhaodong on 15/5/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UserPostListController.h"
#import "PostListView.h"

@interface UserPostListController ()
@property (strong, nonatomic) PostListView *postListView;
@property (copy, nonatomic) NSString *userId;
@end

@implementation UserPostListController

- (instancetype)initWithUserId:(NSString *)userId
{
    self = [super init];
    if (self) {
        self.userId = userId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_postListView == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.postListView = [PostListView createPostListViewWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height - 20 - 44)
                                                           controller:self
                                                             delegate:nil
                                                                 type:PostListTypeInPerson
                                                            coterieId:nil
                                                               userId:_userId];
        [self.view addSubview:self.postListView];
    }
    [self.postListView beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
