//
//  FavourableActivityCell.h
//  Sport
//
//  Created by haodong  on 14/11/7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol FavourableActivityCellDelegate <NSObject>
@optional
- (void)didClickFavourableActivityCellBackgroundButton:(NSIndexPath *)indexPath;
- (void)didClickFavourableActivityCellFinishInputButton:(NSIndexPath *)indexPath text:(NSString *)text;
@end


@class FavourableActivity;;

@interface FavourableActivityCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UIImageView *nameBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *finishInputButton;

@property (assign, nonatomic) id<FavourableActivityCellDelegate> delegate;

- (void)updateCellWithActivity:(FavourableActivity *)activity
                     indexPath:(NSIndexPath *)indexPath
                    isSelected:(BOOL)isSelected;

@end
