//
//  DrawRecordCell.m
//  Sport
//
//  Created by haodong  on 14/11/21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DrawRecordCell.h"
#import "DrawRecord.h"

@interface DrawRecordCell()
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSIndexPath *indexPath;
@end


@implementation DrawRecordCell


+ (NSString*)getCellIdentifier
{
    return @"DrawRecordCell";
}

+ (id)createCell
{
    DrawRecordCell *cell = [super createCell];
    [cell.convertButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
    return cell;
}

- (void)updateCellWithDrawRecord:(DrawRecord *)record
                       indexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    
    self.titleLabel.text = record.desc;
    
    if (_formatter == nil) {
        self.formatter = [[NSDateFormatter alloc] init] ;
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    self.timeLabel.text = [_formatter stringFromDate:record.createDate];
    
    if (record.status == 0) {
        self.statusLabel.hidden = YES;
        self.convertButton.hidden = NO;
    } else {
        self.statusLabel.hidden = NO;
        self.convertButton.hidden = YES;
    }
}

- (IBAction)clickConvertButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didCLickDrawRecordCellConvertButton:)]) {
        [_delegate didCLickDrawRecordCellConvertButton:_indexPath];
    }
}

@end
