//
//  DiscoverHomeCell.h
//  Sport
//
//  Created by xiaoyang on 16/5/10.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
typedef void (^SettingItemOption)();

@protocol DiscoverHomeCellDelegate <NSObject>
@optional
- (void)didClickButton:(NSIndexPath *)indexPath value:(NSString *)value;

@end

@interface DiscoverHomeCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, copy) SettingItemOption option;
@property (assign, nonatomic) id<DiscoverHomeCellDelegate> delegate;


+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)updateCell:(NSString *)value
         iconImageUrl:(NSString *)iconImageUrl
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@end
