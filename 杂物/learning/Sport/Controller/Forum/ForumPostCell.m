//
//  ForumPostCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumPostCell.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
//#import "BrowsePhotoView.h"
#import "UILabel+Utils.h"

@interface ForumPostCell()

@property (weak, nonatomic) IBOutlet UIImageView *forumIconImage;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIButton *oneImageButton;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UIImageView *commentIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentAmountButton;
@property (assign, nonatomic) int defaultButtomMargin;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oneImageView;
@property (weak, nonatomic) IBOutlet UIView *nightImageView;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *forumNameButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopMarginConstraint;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineViewConstraintHeight;
@property (strong, nonatomic) IBOutlet UIView *cellLineView;

@end

@implementation ForumPostCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#define DEFAULT_BOTTOM_MARGIN 45
#define SPACE 3

#define TAG_BUTTON_BASE 20
#define TAG_IMAGE_BASE 10
#define MAX_PHOTO_COUNT 9
#define CONSTRAINT_PADDING 20


+ (NSString *)getCellIdentifier
{
    return @"ForumPostCell";
}

+ (id)createCellWithCellLineHidden:(BOOL)hidden
{
    ForumPostCell *cell = [super createCell];
    
    cell.lineViewConstraintHeight.constant = 0.5;
    cell.defaultButtomMargin = DEFAULT_BOTTOM_MARGIN;
    [cell.avatarImageView setClipsToBounds:YES];
    [cell.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    cell.avatarImageView.layer.cornerRadius = 20;
    cell.avatarImageView.layer.masksToBounds = YES;
    
    cell.oneImageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.oneImageView.clipsToBounds = YES;
    cell.cellLineView.hidden = hidden;
    return cell;
}


// default
+ (CGFloat)getCellHeight
{
     return 473;
}


- (CGFloat)getCellHeightWithPost:(Post *)post
                               indexPath:(NSIndexPath *)indexPath
                 tableViewBounds:(CGRect)tableViewBounds
{
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableViewBounds), CGRectGetHeight(self.bounds));
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self.contentLabel sizeToFit];
   
    CGSize labelSize = CGSizeMake(0, 0);
    CGFloat frameWidth = [UIScreen mainScreen].bounds.size.width - self.labelLeadingConstraint.constant - self.labelTrailingConstraint.constant;
    if ([self.contentLabel.text isEqualToString:@""] == NO) {

        labelSize = [self.contentLabel sizeThatMyFits:CGSizeMake(frameWidth, 0)];

        //labelSize = [self sizeThatFits:CGSizeMake(self.contentLabel.frame.size.width, 0)];
        
    }
    
    CGFloat fixMargin = self.contentLabel.frame.origin.y + labelSize.height + self.defaultButtomMargin;
    
//    if ([post.photoList count] > 1 && [post.photoList count] < 4) {
//        HDLog(@"margin %f", fixMargin + self.smallImageView.frame.size.height);
//        return fixMargin + self.smallImageView.frame.size.height;
//    }else if([post.photoList count] >= 4 && [post.photoList count] < 7) {
//        HDLog(@"margin %f", fixMargin + self.smallImageView.frame.size.height*2+SPACE*2);
//        return fixMargin + self.smallImageView.frame.size.height*2+SPACE*2;
//    }else {
//        HDLog(@"margin %f width %f", fixMargin + self.smallImageView.frame.size.height*3+SPACE*4,(frameWidth*10/31));
//        return fixMargin + self.smallImageView.frame.size.height*3+SPACE*4;
//    }

    if ([post.photoList count] == 0) {
        return  fixMargin - 5;
    }else if ([post.photoList count] == 1) {
        return  fixMargin + (frameWidth*10/31)*150/100 + SPACE;
    }else {
        NSUInteger factor = [post.photoList count]/3 + (([post.photoList count]%3 == 0)?0:1);
        
        return fixMargin + (frameWidth*10/31)*factor +SPACE*(factor+1);
    }
}

- (void)updateCell:(Post *)post
         indexPath:(NSIndexPath *)indexPath
    isShowForumName:(BOOL)isShowForumName
isShowCommentCount:(BOOL)isShowCommentCount
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    self.post = post;
    
    for (UIView *view in self.nightImageView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.clipsToBounds = YES;
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.hidden = YES;
        }
        
        if ([view isKindOfClass:[UIButton class]]) {
            view.hidden = YES;
        }
    }
    
    self.nightImageView.hidden = YES;
    
    self.oneImageView.hidden = YES;
    self.oneImageButton.hidden = YES;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.post.avatarImageURL] placeholderImage:[SportImage avatarDefaultImage]];
    
    [self updateButtomInfo:isShowForumName
             isShowComment:isShowCommentCount];
    
    [self updateCellTextAndImage];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
}

-(void)updateButtomInfo:(BOOL)isShowForumName
          isShowComment:(BOOL)isShowCommentCount

{
    if (isShowForumName == NO) {
        self.forumNameButton.hidden = YES;
        self.forumIconImage.hidden = YES;
    } else {
        self.forumNameButton.hidden = NO;
        self.forumIconImage.hidden = NO;
        
        [self.forumNameButton setTitle:self.post.forum.forumName forState:UIControlStateNormal];
    }
    
    if (isShowCommentCount == NO) {
        self.commentAmountButton.hidden = YES;
        self.commentIconImageView.hidden = YES;
    }
    else {
        self.commentAmountButton.hidden = NO;
        self.commentIconImageView.hidden = NO;
        
        NSString *displayCommentAmount = nil;
        if (self.post.commentAmount > 99) {
            displayCommentAmount = @"99+";
        }
        else {
            displayCommentAmount = [@(self.post.commentAmount) stringValue];
        }
        
        [self.commentAmountButton setTitle:displayCommentAmount forState:UIControlStateNormal];
    }
    
    NSDate *displayDate = self.post.createTime;
    
    // show post detail, only display create time.
    if (isShowCommentCount == NO && isShowForumName == NO) {
        self.defaultButtomMargin = DEFAULT_BOTTOM_MARGIN - 23;
        displayDate = self.post.createTime;
    } else {
        
        NSComparisonResult result = [self.post.lastUpdateTime compare:self.post.createTime
                                     ];
        if (result == NSOrderedDescending) {
            displayDate = self.post.lastUpdateTime;
        }
        else if (result == NSOrderedAscending){
            displayDate = self.post.createTime;
        }
    }
    
    if (self.formatter == nil) {
        self.formatter = [[NSDateFormatter alloc] init];
    }
    
    self.lastUpdateTimeLabel.text = [DateUtil lastUpdateTimeString:displayDate formatter:self.formatter];

}

-(void)updateCellTextAndImage
{
    if (self.post == nil) {
        return;
    }
    
    self.userNameLabel.text = self.post.userName;
    
    if ([self.post.photoList count] == 1) {
        PostPhoto *photo = self.post.photoList[0];
        [self.oneImageView sd_setImageWithURL:[NSURL URLWithString:photo.photoThumbUrl] placeholderImage:[SportImage businessDefaultImage]];
        self.oneImageView.hidden = NO;
        self.oneImageButton.hidden = NO;
        
    } else if ([self.post.photoList count] > 1){
        
        self.nightImageView.hidden = NO;
        
        BOOL is4ImageView = ([self.post.photoList count] == 4);
        NSUInteger endIndex = is4ImageView?[self.post.photoList count]+1:[self.post.photoList count];
        for (int i = 0; i < endIndex; i++) {
            if (i > MAX_PHOTO_COUNT) {
                break;
            }
            
            //不显示第一行最右边的ImageView
            if (is4ImageView && i == 2) {
                continue;
            }
            
            UIButton *button = (UIButton *)[self.nightImageView viewWithTag:(TAG_BUTTON_BASE + i)];
            if ([button isKindOfClass:[UIButton class]]) {
                button.hidden = NO;
            }
            
            UIImageView *imageView = (UIImageView *)[self.nightImageView viewWithTag:(TAG_IMAGE_BASE + i)];
            if([imageView isKindOfClass:[UIImageView class]]) {
                
                int photoIndex = i;
                if (is4ImageView && i > 2) {
                    photoIndex = i-1;
                }
                
                PostPhoto *photo = self.post.photoList[photoIndex];
                [imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoThumbUrl] placeholderImage:[SportImage businessDefaultImage]];
                imageView.hidden = NO;
            }
        }
    }
    
    self.contentLabel.text = self.post.content;
    //由于lable frame的宽度在不同条件下不固定，这里统一用屏幕宽度减去左右constraint＋padding作为lable frame
    CGFloat frameWidth = [UIScreen mainScreen].bounds.size.width - self.labelLeadingConstraint.constant - self.labelTrailingConstraint.constant;
    
    CGSize labelSize = [self.contentLabel sizeThatMyFits:CGSizeMake(frameWidth, 0)];
    
    self.labelHeightConstraint.constant = labelSize.height;
    if ([self.post.content isEqualToString:@""] == NO) {
        self.imageTopMarginConstraint.constant = 12;
        
    } else {
        self.imageTopMarginConstraint.constant = 8 - labelSize.height;
    }
    
    [self.contentLabel sizeToFit];
}

- (IBAction)clickImageButton:(id)sender {
    [MobClickUtils event:umeng_event_forum_post_list_click_image];
    
    UIButton *button = (UIButton *)sender;
    int openIndex;
    
    if (button.tag == 1) {
        openIndex = 0;
    }else {
        openIndex = (int)button.tag - TAG_BUTTON_BASE;
        
        //处理四张图片的情况
        if ([self.post.photoList count] == 4) {
            if (openIndex > 2) {
                openIndex--;
            }
        }
    }

//    BrowsePhotoView *view = [BrowsePhotoView createBrowsePhotoView];
//    
//    NSMutableArray *list = [NSMutableArray array];
//    
//    for (PostPhoto *photo in self.post.photoList) {
//        [list addObject:photo.photoImageUrl];
//    }
//    
//    [view showImageList:list openIndex:openIndex];
//
    if ([_delegate respondsToSelector:@selector(didClickForumPostImage:openIndex:)]) {
        
        [_delegate didClickForumPostImage:self.indexPath openIndex:openIndex];
    }
    
}
- (IBAction)clickForumButton:(id)sender {
    [MobClickUtils event:umeng_event_forum_post_list_click_forum_name];
    
    if ([_delegate respondsToSelector:@selector(didClickForumButton:)]) {
        [_delegate didClickForumButton:self.indexPath];
    }
    
}

- (IBAction)clickAvatarButton:(id)sender {
    [MobClickUtils event:umeng_event_forum_post_list_click_user];
    
    if ([_delegate respondsToSelector:@selector(didClickAvatarButton:)]) {
        [_delegate didClickAvatarButton:self.indexPath];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded]; // this line is key
}

@end
