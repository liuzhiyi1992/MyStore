//
//  UserLevelCell.m
//  Sport
//
//  Created by liuzhiyi on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "UserLevelCell.h"
#import "UIImageView+WebCache.h"

@interface UserLevelCell()

@property (weak, nonatomic) IBOutlet UILabel *rulesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rulesIconImageView;

@end


@implementation UserLevelCell

+ (NSString *)getCellIdentifier {
    return @"UserLevelCell";
}

+ (CGFloat)getCellHeight {
    return 45;
}

- (void)updateCellWithRulesTitle:(NSString *)rulesTitle rulesIconUrl:(NSString *)rulesIconUrl {
    if (rulesTitle.length > 0) {
       self.rulesLabel.text = rulesTitle;
    }
    if(rulesIconUrl.length > 0) {
        [self.rulesIconImageView sd_setImageWithURL:[NSURL URLWithString:rulesIconUrl]];
    }
}

@end
