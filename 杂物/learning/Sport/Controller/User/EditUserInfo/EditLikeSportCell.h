//
//  EditLikeSportCell.h
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol EditLikeSportCellDelegate <NSObject>
- (void)didClickDeleteButton:(NSIndexPath *)idnexPath;

@end


@interface EditLikeSportCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sportNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportLevelLabel;

@property (assign, nonatomic) id<EditLikeSportCellDelegate> delegate;

- (void)updateCellWithSportName:(NSString *)sportName
                     sportLevel:(NSString *)sportLevel
                      indexPath:(NSIndexPath *)indexPath;

@end
