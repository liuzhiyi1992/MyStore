//
//  ForumEntranceView.m
//  Sport
//
//  Created by qiuhaodong on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumEntranceView.h"
#import "ForumEntrance.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "ForumDetailController.h"

@interface ForumEntranceView()
@property (strong, nonatomic) ForumEntrance *entrance;
@property (weak, nonatomic) UIViewController *controller;
@property (strong, nonatomic) UITextView *contentTextView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ForumEntranceView


#define SPACE 22
+ (ForumEntranceView *)createViewWithForumEntrance:(ForumEntrance *)forumEntrance
                                        controller:(UIViewController *)controller
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ForumEntranceView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    ForumEntranceView *view = [topLevelObjects objectAtIndex:0];
    view.backgroundImageView.image = [SportImage whiteBackgroundImage];
    view.lineImageView.image = [SportImage lineImage];
    view.imageView.layer.cornerRadius = 2;
    view.imageView.layer.masksToBounds = YES;
    
    view.entrance = forumEntrance;
    view.controller = controller;
    
    view.titleLabel.text = forumEntrance.title;
    
    view.contentLabel.text = forumEntrance.content;
    
    if ([forumEntrance.coverImageUrl length] > 0) {
        [view.imageView sd_setImageWithURL:[NSURL URLWithString:forumEntrance.coverImageUrl] placeholderImage:nil];
        view.imageView.clipsToBounds = YES;
        [view.contentLabel updateWidth:[UIScreen mainScreen].bounds.size.width - view.contentLabel.frame.origin.x - SPACE];
        
    } else {
        [view.contentLabel updateOriginX:SPACE];
        [view.contentLabel updateWidth:[UIScreen mainScreen].bounds.size.width - view.contentLabel.frame.origin.x - SPACE];
        CGSize size = [view.contentLabel sizeThatFits:view.contentLabel.frame.size];
        [view.contentLabel updateHeight:size.height];
        [view updateHeight:view.contentLabel.frame.origin.y + view.contentLabel.frame.size.height + 12];
    }
    
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    
    return view;
}

//创建内容TextView
- (UITextView *)createTextView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(SPACE, 55, screenSize.width - 2 * SPACE, 55)];
    textView.backgroundColor = [UIColor clearColor];
    [textView setTextColor:[SportColor content1Color]];
    textView.font = [UIFont systemFontOfSize:14];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    if ([textView respondsToSelector:@selector(setSelectable:)]) {
        textView.selectable = NO;
    }
    return textView;
}

- (IBAction)clickButton:(id)sender {
    if ([self.controller isKindOfClass:NSClassFromString(@"BusinessDetailController")]) {
        [MobClickUtils event:umeng_event_business_detail_click_forum_entrance];
    } else if ([self.controller isKindOfClass:NSClassFromString(@"OrderDetailController")]) {
        [MobClickUtils event:umeng_event_order_detail_click_forum_entrance];
    } else if ([self.controller isKindOfClass:NSClassFromString(@"PayController")]) {
        [MobClickUtils event:umeng_event_pay_success_click_forum_entrance];
    }
    
    Forum *forum = [[Forum alloc] init] ;
    forum.forumId= self.entrance.forumId;
    forum.forumName = self.entrance.forumName;
    ForumDetailController *controller = [[ForumDetailController alloc] initWithForum:forum] ;
    [self.controller.navigationController pushViewController:controller animated:YES];
}

@end
