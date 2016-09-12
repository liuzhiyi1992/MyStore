//
//  EditLikeSportCell.m
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "EditLikeSportCell.h"

@interface  EditLikeSportCell()
@property (retain,nonatomic) NSIndexPath *indexPath;
@end

@implementation EditLikeSportCell

+ (NSString*)getCellIdentifier
{
    return @"EditLikeSportCell";
}

+ (CGFloat)getCellHeight
{
    return 46.0;
}


- (void)updateCellWithSportName:(NSString *)sportName
                     sportLevel:(NSString *)sportLevel
                      indexPath:(NSIndexPath *)indexPath
{
    self.sportNameLabel.text = sportName;
    self.sportLevelLabel.text = sportLevel;
    self.indexPath = indexPath;
}

- (IBAction)clickCancelButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDeleteButton:)]) {
        [_delegate didClickDeleteButton:_indexPath];
    }
}

@end
