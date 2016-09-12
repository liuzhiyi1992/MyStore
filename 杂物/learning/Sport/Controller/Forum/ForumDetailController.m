//
//  ForumDetailController.m
//  Sport
//
//  Created by 江彦聪 on 15/5/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumDetailController.h"
#import "Forum.h"
#import "Post.h"
#import "PostPhoto.h"
#import "DateUtil.h"
#import "UserManager.h"
#import "BrowsePhotoView.h"
#import "LoginController.h"

@interface ForumDetailController ()
@property (strong,nonatomic) Forum *forum;
@property (strong, nonatomic) PostListView *postListView;
@end

@implementation ForumDetailController

#define PAGE_START 1
#define COUNT_ONE_PAGE  20


-(id)initWithForum:(Forum *)forum {
    self = [super init];
    if (self) {
        self.forum = forum;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = self.forum.forumName;
    
    //设置圈子详情，帖子列表页面
    if (_postListView == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.postListView = [PostListView createPostListViewWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height - 20 - 44)
                                                           controller:self
                                                             delegate:self
                                                                 type:PostListTypeInCoterie
                                                            coterieId:self.forum.forumId
                                                               userId:nil];
        [self.view addSubview:self.postListView];
    }
    
    [self.postListView beginRefreshing];
    [self createRightTopImageButton:[SportImage writePostButtonImage]];
}

- (void)clickRightTopButton:(id)sender
{
    if ([self isLoginAndShowLoginIfNot] == NO) {
        return;
    }
    
    [MobClickUtils event:umeng_event_forum_detail_click_create];
    NSString *forumId = self.forum.forumId;
    WritePostController *controller = [[WritePostController alloc]initWithForumId:forumId];
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-- WritePostControllerDelegate
-(void)didFinishWritePost
{
    [self.postListView beginRefreshing];

}




@end
