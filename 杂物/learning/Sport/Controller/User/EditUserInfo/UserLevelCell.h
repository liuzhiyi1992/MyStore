//
//  UserLevelCell.h
//  Sport
//
//  Created by liuzhiyi on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface UserLevelCell : DDTableViewCell

+ (NSString *)getCellIdentifier;

+ (CGFloat)getCellHeight;

- (void)updateCellWithRulesTitle:(NSString *)rulesTitle rulesIconUrl:(NSString *)rulesIconUrl;

@end
