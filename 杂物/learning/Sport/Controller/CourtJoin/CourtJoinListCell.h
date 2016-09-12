//
//  CourtJoinListCell.h
//  Sport
//
//  Created by xiaoyang on 16/5/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "CourtJoin.h"

@protocol CourtJoinListCellDelegate <NSObject>
@optional
- (void)didClickDetailButton:(NSIndexPath *)indexPath;
- (void)didClickNickNameButton:(NSIndexPath *)indexPath;
@end

@interface CourtJoinListCell : DDTableViewCell
@property (assign, nonatomic) id<CourtJoinListCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *nicknameImageView;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePerPeason;
@property (weak, nonatomic) IBOutlet UILabel *canJoinNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIButton *nicknameButton;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hourLabelLeftConstraint;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;

+ (NSString*)getCellIdentifier;
- (void)updateCellWithCourtJoin:(CourtJoin *)courtJoin indexPath:(NSIndexPath *)indexPath;

@end
