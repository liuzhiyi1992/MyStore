//
//  PostCommentCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PostCommentCell.h"
#import "DateUtil.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Utils.h"

@interface PostCommentCell()

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeightConstraint;

@end

@implementation PostCommentCell


+ (id)createCell
{
    PostCommentCell *cell = [super createCell];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"PostCommentCell";
}

// default
+ (CGFloat)getCellHeight
{
    return 110;
}

#define DEFAULT_BOTTOM_MARGIN 10

#define CONSTRAINT_PADDING 20
- (CGFloat)getCellHeightWithTableViewBounds:(CGRect)tableViewBounds
{
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableViewBounds), CGRectGetHeight(self.bounds));
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    //self.contentLabel.text = post.content;
    [self.contentLabel sizeToFit];
    
    CGFloat frameWidth = [UIScreen mainScreen].bounds.size.width - self.contentLeadingConstraint.constant - self.contentTrailingConstraint.constant - CONSTRAINT_PADDING;

    CGSize labelSize = [self.contentLabel sizeThatMyFits:CGSizeMake(frameWidth, 0)];
    
    CGFloat fixMargin = self.contentLabel.frame.origin.y + labelSize.height + DEFAULT_BOTTOM_MARGIN;
    
    return fixMargin;
}


- (void)updateCell:(PostComment *)comment
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    
    UIImage *image = nil;
    if (indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image] ;
    [self setBackgroundView:bv];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:comment.avatar] placeholderImage:[SportImage avatarDefaultImage]];
    
    self.avatarImageView.layer.cornerRadius = 20;
    self.avatarImageView.layer.masksToBounds = YES;
    
    
    self.userNameLabel.text = comment.userName;
    
    if (self.formatter == nil) {
        self.formatter = [[NSDateFormatter alloc]init];
    }
    
    self.createTimeLabel.text = [DateUtil lastUpdateTimeString:comment.createDate formatter:self.formatter];
    
    self.contentLabel.text = comment.content;
    
    CGFloat frameWidth = [UIScreen mainScreen].bounds.size.width - self.contentLeadingConstraint.constant - self.contentTrailingConstraint.constant - CONSTRAINT_PADDING;
    CGSize labelSize = [self.contentLabel sizeThatMyFits:CGSizeMake(frameWidth, 0)];
    self.labelHeightConstraint.constant = labelSize.height;
    [self.contentLabel sizeToFit];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
   [self setNeedsUpdateConstraints];
   [self updateConstraintsIfNeeded];
    
}


//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
//    // need to use to set the preferredMaxLayoutWidth below.
//    [self.contentView updateConstraintsIfNeeded];
//    [self.contentView layoutIfNeeded];
//    
//    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
//    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
//    self.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.contentLabel.frame);
//
//}

- (IBAction)clickAvatarButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPostCommentCellUser:)]) {
        [_delegate didClickPostCommentCellUser:_indexPath];
    }
}

@end
