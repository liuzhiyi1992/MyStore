//
//  CityCell.h
//  Sport
//
//  Created by haodong  on 13-8-5.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol CityCellDelegate <NSObject>
@optional
- (void)didClickCityCell:(NSIndexPath *)indexPath;

@end

@interface CityCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (assign, nonatomic) id<CityCellDelegate> delegate;

- (void)updateCell:(NSString *)valueString
         indexPath:(NSIndexPath *)indexPath
        isSelected:(BOOL)isSelected
            isLast:(BOOL)isLast;

@end
