//
//  ForumEntranceView.h
//  Sport
//
//  Created by qiuhaodong on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class ForumEntrance;

@interface ForumEntranceView : UIView

+ (ForumEntranceView *)createViewWithForumEntrance:(ForumEntrance *)forumEntrance
                                        controller:(UIViewController *)controller;

@end
