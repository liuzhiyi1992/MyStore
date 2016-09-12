//
//  UserInfoCell.h
//  Sport
//
//  Created by haodong  on 13-8-27.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
typedef void (^SettingItemOption)();
@protocol UserInfoCellDelegate <NSObject>
@optional
- (void)didClickButton:(NSIndexPath *)indexPath value:(NSString *)value;

@end

@interface UserInfoCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *tipsCountButton;
@property (weak, nonatomic) IBOutlet UIImageView *redPointImageView;
@property (weak, nonatomic) IBOutlet UILabel *subValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *orangeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *redNumLab;
@property (nonatomic, copy) SettingItemOption option;


+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (assign, nonatomic) id<UserInfoCellDelegate> delegate;

- (void)updateCell:(NSString *)value
          subValue:(NSString *)subValue
       orangeValue:(NSString *)orangeValue
         iconImage:(UIImage *)iconImage
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
         tipsCount:(NSUInteger)tipsCount
    isShowRedPoint:(BOOL)isShowRedPoint;

@end
