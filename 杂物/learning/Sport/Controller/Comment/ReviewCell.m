//
//  ReviewCell.m
//  Sport
//
//  Created by haodong  on 14/11/4.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ReviewCell.h"
#import "Review.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Utils.h"
#import "BusinessPhoto.h"
#import "NSString+Utils.h"
#import "BusinessService.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "FastLoginController.h"

#define COMMENT_REPLY_LINE_SPACING 6
#define USEFUL_BUTTON_HEIGHT_DEFAULT 20.f

@interface ReviewCell()
@property (strong, nonatomic) Review *review;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineViewConstraintHeight;
@property (assign, nonatomic) NSUInteger index;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarImageLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarImageWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UIButton *usefulButton;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usefulButtonHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHolderViewFoundationConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyLabelHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *replayViewFoundationConstraint;
@end

@implementation ReviewCell
- (NSDateFormatter *)dateFormatter {
    if (nil == _dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy.MM.dd"];
    }
    return _dateFormatter;
}


#define Y_CONTENT_TEXT_VIEW 30
+ (id)createCell {
    //场馆详情三个预览评论 业务差别大 不应重用此cell
    ReviewCell *cell = [super createCell];
    return cell;
}

- (void)awakeFromNib {
    self.avatarImageView.layer.cornerRadius = 21;
    self.avatarImageView.layer.masksToBounds = YES;
    self.usefulButton.layer.borderWidth = 0.5f;
    self.usefulButton.layer.borderColor = [UIColor hexColor:@"666666"].CGColor;
    [self.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self updateWidth:[UIScreen mainScreen].bounds.size.width];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.avatarBackgroundImageView setImage:[SportImage avatarBackgroundImage]];
}

+ (NSString*)getCellIdentifier
{
    return @"ReviewCell";
}

+ (CGFloat)getCellHeight
{
    return 66.0;
}

#define WIDTH_CONTENT_TEXT_VIEW ([UIScreen mainScreen].bounds.size.width - 100)
+ (UITextView *)createContentTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - WIDTH_CONTENT_TEXT_VIEW) / 2, 0, WIDTH_CONTENT_TEXT_VIEW, 400)] ;
    textView.backgroundColor = [UIColor clearColor];
    [textView setTextColor:[UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1]];
    textView.font = [UIFont systemFontOfSize:14];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.contentInset = UIEdgeInsetsMake(0,-5,0,0);
    if ([textView respondsToSelector:@selector(setSelectable:)]) {
        textView.selectable = NO;
    }
    
    return textView;
}

#define SPACE_BOTTOM 10
- (CGFloat)heightWithReview:(Review *)review
{
    return [self fitHeight];
}

- (void)updateCellWithReview:(Review *)review
                   index:(NSUInteger)index
{
    self.review = review;
    self.index = index;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:review.avatar] placeholderImage:[SportImage avatarDefaultImage]];
    
    _nicknameLabel.text = review.nickName;
    _contentLabel.text = review.content;
    [self updateUsefulButtonImage:review.useful usefulCount:review.usefulCount];
    
    if (review.commentReply.length > 0) {
        NSString *replyString = [NSString stringWithFormat:@"场馆回复:%@", review.commentReply];
        CGSize replyStringSize = [replyString sizeWithMyFont:_contentLabel.font constrainedToSize:CGSizeMake(_contentLabel.frame.size.width, CGFLOAT_MAX)];
        if (replyStringSize.height > 20) {//一行以上
            NSMutableAttributedString *replyAttributeString = [[NSMutableAttributedString alloc] initWithString:replyString];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:COMMENT_REPLY_LINE_SPACING];
            [replyAttributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, replyAttributeString.length)];
            _replyLabel.attributedText = replyAttributeString;
        } else {
            _replyLabel.text = replyString;
        }
        //constraint
        if (nil == _replayViewFoundationConstraint) {
            self.replayViewFoundationConstraint = [NSLayoutConstraint constraintWithItem:_replyView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-4.f];
            [self.contentView addConstraint:_replayViewFoundationConstraint];
        }
        [_replyView setHidden:NO];
    } else {
        //constraint
        if (_replayViewFoundationConstraint) {
            [self.contentView removeConstraint:_replayViewFoundationConstraint];
            self.replayViewFoundationConstraint = nil;
        }
        [_replyView setHidden:YES];
    }
    
    [self updateRating:review.rating];
    self.createTimeLabel.text = [self.dateFormatter stringFromDate:review.createDate];
    
    if ([review.photoList count] > 0) {
        self.imageHolderView.hidden = NO;
        self.imageHolderViewFoundationConstraint.constant = 8.f;//ImageViewHolderView与usefulButton距离
        [self updateImages:review.photoList];
    } else {
        self.imageHolderView.hidden = YES;
        self.imageHolderViewFoundationConstraint.constant = -50.f;
    }
    [self calculateLabelheight];
//    [self fitHeight];
}

- (CGFloat)fitHeight {
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self updateHeight:size.height];
    return size.height;
}

- (CGSize)calculateLabelheight {
    CGSize contentLabelSize = [_contentLabel.text sizeWithMyFont:_contentLabel.font constrainedToSize:CGSizeMake(_contentLabel.frame.size.width, CGFLOAT_MAX)];
    _contentLabelHeightConstraint.constant = contentLabelSize.height;
    CGSize replyLabelSize = [_replyLabel.text sizeWithMyFont:_replyLabel.font constrainedToSize:CGSizeMake(_replyLabel.frame.size.width, CGFLOAT_MAX)];
    _replyLabelHeightConstraint.constant = replyLabelSize.height;
    return replyLabelSize;
}

#define TAG_RATING_BASE 10
- (void)updateRating:(float)rating
{
    //int zsPart = (int)rating;
    
    for (int i = 0 ; i < 5 ; i ++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_RATING_BASE + i];
        if (i < rating) {
            [imageView setImage:[SportImage star1Image]];
        } else {
            [imageView setImage:[SportImage star3Image]];
        }
    }
}

#define TAG_IMAGE_BASE  30
#define TAG_BUTTON_BASE  20
- (void)updateImages:(NSArray *)photoList
{
    for (int i = 0 ; i < 4; i ++) {
        
        UIImageView *imageView = (UIImageView *)[self.imageHolderView viewWithTag:TAG_IMAGE_BASE + i];
        UIButton *button = (UIButton*)[self.imageHolderView viewWithTag:TAG_BUTTON_BASE + i];
        
        if (i < [photoList count]) {
            button.hidden = NO;
            imageView.hidden = NO;
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:YES];

            BusinessPhoto *photo = [photoList objectAtIndex:i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoThumbUrl] placeholderImage:[SportImage placeHolderImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
        } else {
            button.hidden = YES;
            imageView.hidden = YES;
        }
    }
}

- (IBAction)clickAvatarButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickReviewCellAvatarButton:)]) {
        [_delegate didClickReviewCellAvatarButton:_review.userId];
    }
}

- (IBAction)clickImageButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickReviewCellImageButton:openIndex:)]) {
        
        UIButton *button = (UIButton *)sender;
        NSUInteger openIndex = button.tag - TAG_BUTTON_BASE;
        
        [_delegate didClickReviewCellImageButton:self.index
                                       openIndex:openIndex];
    }
}

- (IBAction)clickUsefulButton:(id)sender {
    if (![UserManager isLogin]) {
        FastLoginController *controller = [[FastLoginController alloc] init];
        UIViewController *sponsorController;
        [self findControllerWithResultController:&sponsorController];
        if (sponsorController) {
            [sponsorController.navigationController pushViewController:controller animated:YES];
        }
        return;
    }
    if (_review.useful) {
        //"有用"不能取消
        return;
    }
    //service
    User *user = [[UserManager defaultManager] readCurrentUser];
    __weak __typeof(self) weakSelf = self;
    [BusinessService setCommentUseful:!_review.useful userId:user.userId reviewId:_review.reviewId completion:^(NSString *status, NSString *msg) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            weakSelf.review.useful = !weakSelf.review.useful;
            weakSelf.review.usefulCount ++;
            //Button status
            [weakSelf updateUsefulButtonImage:weakSelf.review.useful usefulCount:weakSelf.review.usefulCount];
        } else {
            [SportPopupView popupWithMessage:msg];
        }
    }];
}

- (void)updateUsefulButtonImage:(BOOL)useful usefulCount:(int)usefulCount {
    //image
    NSString *imageName;
    if (useful) {
        imageName = @"head_shaped_fill";
    } else {
        imageName = @"head_shaped_hollow";
    }
    [_usefulButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    //title
    if (usefulCount > 0) {
        [_usefulButton setTitle:[NSString stringWithFormat:@"%d", usefulCount] forState:UIControlStateNormal];
    } else {
        [_usefulButton setTitle:@"有用" forState:UIControlStateNormal];
    }
}

@end

//@interface ReviewCellManager()
//@property (weak, nonatomic) UITextView *myTextView;
//@end
//
//@implementation ReviewCellManager
//
//- (void)dealloc
//{
//    [_myTextView release];
//    [super dealloc];
//}
//
//static ReviewCellManager *_globalReviewCellManager = nil;
//
//+ (ReviewCellManager *)defaultManager
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (_globalReviewCellManager == nil) {
//            _globalReviewCellManager = [[ReviewCellManager alloc] init];
//            [_globalReviewCellManager initData];
//        }
//    });
//    return _globalReviewCellManager;
//}
//
//- (void)initData
//{
//    self.myTextView = [self createTextView];
//}
//
//- (CGSize)sizeWithText:(NSString *)text
//{
//    _myTextView.text = text;
//    return [_myTextView sizeThatFits:CGSizeMake(MAX_WIDTH_TEXT_VIEW, MAX_HEIGHT_TEXT_VIEW)];
//}
//
//- (UITextView *)createTextView
//{
//    UITextView *textView = [[[UITextView alloc] initWithFrame:CGRectMake((320 - WIDTH_CONTENT_TEXT_VIEW) / 2, 0, WIDTH_CONTENT_TEXT_VIEW, 400)] autorelease];
//    textView.backgroundColor = [UIColor clearColor];
//    [textView setTextColor:[UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1]];
//    textView.font = [UIFont systemFontOfSize:14];
//    textView.scrollEnabled = NO;
//    textView.editable = NO;
//    
//    if ([textView respondsToSelector:@selector(setSelectable:)]) {
//        textView.selectable = NO;
//    }
//    
//    return textView;
//}
//

//@end
