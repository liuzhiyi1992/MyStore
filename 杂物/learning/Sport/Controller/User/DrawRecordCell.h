//
//  DrawRecordCell.h
//  Sport
//
//  Created by haodong  on 14/11/21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol DrawRecordCellDelegate <NSObject>
@optional
- (void)didCLickDrawRecordCellConvertButton:(NSIndexPath *)indexPath;
@end

@class DrawRecord;

@interface DrawRecordCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *convertButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (assign, nonatomic) id<DrawRecordCellDelegate> delegate;

- (void)updateCellWithDrawRecord:(DrawRecord *)record
                       indexPath:(NSIndexPath *)indexPath;

@end
