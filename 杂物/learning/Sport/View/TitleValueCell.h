//
//  TitleValueCell.h
//  Sport
//
//  Created by haodong  on 13-7-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol TitleValueCellDelegate <NSObject>
@optional
- (void)didClickTitleValueCell:(NSIndexPath *)indexPath;
@end


@interface TitleValueCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (assign, nonatomic) id<TitleValueCellDelegate> delegate;

- (void)updateCell:(NSString *)titleString
       valueString:(NSString *)valueString
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@end

