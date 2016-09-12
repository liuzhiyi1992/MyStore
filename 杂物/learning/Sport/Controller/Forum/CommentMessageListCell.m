//
//  CommentMessageListCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CommentMessageListCell.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
#import "NSString+Utils.h"

@interface CommentMessageListCell()
@property (strong, nonatomic) CommentMessage* message;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentContentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIView *postContentView;
@property (weak, nonatomic) IBOutlet UILabel *postContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postBackgroundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageButtonConstraint;
@property (weak, nonatomic) IBOutlet UILabel *onlyTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTraillingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeadingConstraint;
@end

@implementation CommentMessageListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)getCellIdentifier
{
    return @"CommentMessageListCell";
}

+ (id)createCell
{
    CommentMessageListCell *cell = [super createCell];
    [cell.messageButton setBackgroundImage:[SportImage commentMessageLeftImage] forState:UIControlStateNormal];
    
    [cell.postBackgroundImageView setImage:[SportImage commentMessageUpImage]];
    [cell.postImageView setClipsToBounds:YES];
    [cell.postImageView setContentMode:UIViewContentModeScaleAspectFill];
    cell.avatarImageView.layer.cornerRadius = 20;
    cell.avatarImageView.layer.masksToBounds = YES;
    [cell.avatarImageView setClipsToBounds:YES];
    [cell.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    return cell;
}

// default
+ (CGFloat)getCellHeight
{
    return 100;
}

- (CGFloat)getCellHeightWithCommentMessage:(CommentMessage *)message
                       indexPath:(NSIndexPath *)indexPath
                 tableViewBounds:(CGRect)tableViewBounds
{
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableViewBounds), CGRectGetHeight(self.bounds));
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self.commentContentTextView sizeToFit];
    [self.postContentLabel sizeToFit];
    
    CGFloat height = self.postContentView.frame.origin.y + self.postContentView.frame.size.height + 15;
    //CGFloat height = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height + 1;
    
}

- (void)updateCell:(CommentMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    self.message = message;

    [self.messageButton setBackgroundImage:[SportImage commentMessageLeftImage] forState:UIControlStateNormal];
    
    [self.postBackgroundImageView setImage:[SportImage commentMessageUpImage]];
    [self.postImageView setClipsToBounds:YES];
    [self.postImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.avatarImageView.layer.cornerRadius = 20;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.avatarImageView setClipsToBounds:YES];
    [self.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:message.fromUserAvatarUrl] placeholderImage:[SportImage avatarDefaultImage]];
    
    self.userNameLabel.text = message.fromUserName;
    
    self.commentContentTextView.text = message.commentContent;
//    CGSize maxSize = CGSizeMake(self.postContentView.frame.size.width, CGFLOAT_MAX);
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - self.textViewLeadingConstraint.constant - self.textViewTraillingConstraint.constant, CGFLOAT_MAX);
    CGSize requiredSize = [self sizeThatMyFits:maxSize];
    self.textViewHeight.constant = requiredSize.height;
    [self.commentContentTextView sizeToFit];
    
    self.createTimeLabel.text = [DateUtil lastUpdateTimeString:message.createTime formatter:nil];

    if (message.hasAttach) {
        self.postImageView.hidden = NO;
        
        [self.postImageView sd_setImageWithURL:[NSURL URLWithString:message.thumbUrl] placeholderImage:[SportImage businessDefaultImage ]];
        
        self.postContentLabel.text = message.postContent;
        [self.postContentLabel sizeToFit];
        
        self.postContentLabel.hidden = NO;
        self.onlyTextLabel.hidden = YES;
        //self.labelLeftMargin.constant = -73;
        self.imageButtonConstraint.constant = -8;
        
    } else {
        self.postImageView.hidden = YES;
        self.postContentLabel.hidden = YES;
        self.onlyTextLabel.hidden = NO;
        //self.labelLeftMargin.constant = -15;

        self.onlyTextLabel.text = message.postContent;
        [self.onlyTextLabel sizeToFit];
        
        CGFloat diff = self.postImageView.frame.size.height - self.onlyTextLabel.frame.size.height;
        self.imageButtonConstraint.constant = -20 + diff;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    
}

- (IBAction)clickMessageButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickMessageButton:)]) {
        [_delegate didClickMessageButton:self.message];
    }
}
- (IBAction)clickAvatarButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickAvatarButton:)]) {
        [_delegate didClickAvatarButton:_indexPath];
    }
}


static const CGFloat labelPadding = 4;
- (CGSize)sizeThatMyFits:(CGSize)size {
    CGFloat maxHeight = 9999;
//    if (self.numberOfLines > 0) maxHeight = self.font.leading*self.numberOfLines;
    CGSize textSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textSize = [self.commentContentTextView.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:self.commentContentTextView.font}
                                           context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [self.commentContentTextView.text sizeWithFont:self.commentContentTextView.font
                         constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                             lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    
    return CGSizeMake(size.width, (textSize.height + labelPadding * 2));
}

@end
