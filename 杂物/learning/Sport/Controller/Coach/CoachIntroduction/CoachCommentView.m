//
//  CoachCommentView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachCommentView.h"
#import "CommentCell.h"
#import "UIView+Utils.h"
#import "SportMWPhoto.h"
#import "SportMWPhotoBrowser.h"

@interface CoachCommentView()<CommentCellDelegate>

@property (assign, nonatomic) id<CoachCommentViewDelegate> delegate;
@property (weak, nonatomic) UIViewController *controller;
@property (strong, nonatomic) NSArray *commentList;
@property (strong, nonatomic) CommentCell *commentCell;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;

@end

@implementation CoachCommentView


+ (CoachCommentView *)createViewWithCommentList:(NSArray *)commentList delegate:(id<CoachCommentViewDelegate>)delegate controller:(UIViewController *)controller
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachCommentView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CoachCommentView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    view.controller = controller;
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    view.commentList = commentList;
    [view.dataTableView reloadData];
    [view.dataTableView updateHeight:[view totalHeight]];
    if ([commentList count] > 0) {
        [view updateHeight:view.dataTableView.frame.size.height + view.bottomHolderView.frame.size.height];
    } else {
        [view updateHeight:0];
        view.bottomHolderView.hidden = YES;
    }
    return view;
}

- (CGFloat)heightWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.commentCell == nil) {
        self.commentCell = [CommentCell createCell];
        self.commentCell.delegate = self;
    }
    
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    [self.commentCell updateCell:comment indexPath:indexPath];
    CGFloat height = [self.commentCell getCellHeightWithComment:comment tableViewBounds:self.dataTableView.bounds];
    
    return height + 1;
}

- (CGFloat)totalHeight
{
    CGFloat height = 0;
    for (NSUInteger row = 0 ; row < [self.commentList count]; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        height += [self heightWithIndexPath:indexPath];
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightWithIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [CommentCell getCellIdentifier];
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CommentCell createCell];
        cell.delegate = self;
    }
    
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    [cell updateCell:comment indexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (IBAction)clickMoreButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickCoachCommentViewAllCommentButton)]) {
        [self.delegate didClickCoachCommentViewAllCommentButton];
    }
}

- (void)didClickCommentCellImage:(NSIndexPath *)indexPath openIndex:(int)openIndex
{
    [MobClickUtils event:umeng_event_click_coach_detail_comment_photo];
    
    NSMutableArray *list = [NSMutableArray array];
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    int i = 0;
    for (PostPhoto *photo in comment.photoList) {
        SportMWPhoto *mwPhoto = [SportMWPhoto photoWithURL:[NSURL URLWithString:photo.photoImageUrl]];
        mwPhoto.index = i++;
        [list addObject:mwPhoto];
    }
    SportMWPhotoBrowser *controller = [[SportMWPhotoBrowser alloc] initWithPhotoList:list openIndex:openIndex] ;
    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:controller] ;
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.controller presentViewController:modelNavigationController animated:YES completion:nil];
}

@end
