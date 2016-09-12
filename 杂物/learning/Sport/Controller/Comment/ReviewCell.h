//
//  ReviewCell.h
//  Sport
//
//  Created by haodong  on 14/11/4.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol ReviewCellDelegate <NSObject>
@optional
- (void)didClickReviewCellAvatarButton:(NSString *)userId;
- (void)didClickReviewCellImageButton:(NSUInteger)row
                            openIndex:(NSUInteger)openIndex;

@end

@class Review;

@interface ReviewCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *imageHolderView;
@property (assign, nonatomic) id<ReviewCellDelegate> delegate;
- (CGFloat)heightWithReview:(Review *)review;
- (void)updateCellWithReview:(Review *)review
                   index:(NSUInteger)index;
- (void)hiddenUsefulButton;

@end




//@interface ReviewCellManager : NSObject
//
//
//@end