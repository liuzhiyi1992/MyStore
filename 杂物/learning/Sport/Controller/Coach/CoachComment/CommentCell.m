//
//  CommentCell.m
//  Coach
//
//  Created by quyundong on 15/7/23.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "JudgeImageView.h"
#import "DateUtil.h"
#import "UILabel+Utils.h"

@interface CommentCell()
@property (weak, nonatomic) IBOutlet UIView *RankView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTrailingConstraint;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewList;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) Comment *comment;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *creatDateLabel;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (assign, nonatomic) CGFloat labelHeight;
@property (strong,nonatomic) JudgeImageView *markImageView;
@property (assign, nonatomic) NSUInteger imageCount;
@end
@implementation CommentCell

#define TAG_BUTTON_BASE 20
#define TAG_IMAGE_BASE 10
#define MAX_PHOTO_COUNT 4

+ (NSString *)getCellIdentifier
{
    return @"CommentCell";
}

+ (id)createCell
{
    CommentCell *cell = [super createCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.markImageView = [JudgeImageView createJudgeImageView];
    cell.markImageView.frame = CGRectMake(0, 0, 93, 20);
    [cell.RankView addSubview:cell.markImageView];
    return cell;
}


// default
+ (CGFloat)getCellHeight
{
    return 473;
}

- (CGFloat)getCellHeightWithComment:(Comment *)comment
                    tableViewBounds:(CGRect)tableViewBounds
{
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableViewBounds), CGRectGetHeight(self.bounds));
    [self.markImageView updateViewWithMark:comment.commentRank.floatValue];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGFloat height = 65;
    
    CGSize labelSize = CGSizeMake(0, 0);
    CGFloat frameWidth = [UIScreen mainScreen].bounds.size.width - self.labelLeadingConstraint.constant - self.labelTrailingConstraint.constant;
    if ([self.contentLabel.text isEqualToString:@""] == NO) {
        labelSize = [self.contentLabel sizeThatMyFits:CGSizeMake(frameWidth, 0)];
    }
    
    self.labelHeight = labelSize.height;
    height += labelSize.height;
    if (comment.photoList.count != 0) {
        height += self.photoView.bounds.size.height + 12;
    }
    self.labelHeightConstraint.constant = self.labelHeight;

    return height;
}

- (void)updateCell:(Comment *)comment
         indexPath:(NSIndexPath *)indexPath
{
    [self.markImageView updateViewWithMark:comment.commentRank.floatValue];
    self.labelHeightConstraint.constant = self.labelHeight;
    self.indexPath = indexPath;
    self.userNameLabel.text = comment.userName;
    self.contentLabel.text = comment.content;
    self.photoView.hidden = comment.photoList.count != 0?NO:YES;
    self.creatDateLabel.text = [DateUtil stringFromDate:comment.addTime DateFormat:@"yyyy.MM.dd  H:mm"];
    
    for (UIImageView *imageView in self.imageViewList) {
        imageView.hidden = YES;
    }
    
    for (int i = 0; i<comment.photoList.count; i++) {
        
        if (i >= self.imageViewList.count) {
            break;
        }
        
        UIImageView *imageView = self.imageViewList[i];
        imageView.layer.cornerRadius = 3.0f;
        imageView.layer.masksToBounds = YES;
        PostPhoto *photo = comment.photoList[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoThumbUrl] placeholderImage:[SportImage placeHolderImage]];
        imageView.hidden = NO;
    }
    self.imageCount = comment.photoList.count;
    

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded]; // this line is key
}

- (IBAction)clickImageButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    int openIndex = (int)button.tag - TAG_BUTTON_BASE;
    if (openIndex < self.imageCount && [_delegate respondsToSelector:@selector(didClickCommentCellImage:openIndex:)]) {
        [_delegate didClickCommentCellImage:self.indexPath openIndex:openIndex];
    }
}

@end
