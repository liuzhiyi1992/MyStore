//
//  ServiceCell.m
//  Sport
//
//  Created by haodong  on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ServiceCell.h"
#import "Business.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ServiceCellManager.h"
#import "UIView+Utils.h"
#import "Service.h"

@interface ServiceCell()
@property (strong, nonatomic) UITextView *valueTextView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;

@end

@implementation ServiceCell


#define SPACE 1
+ (id)createCell
{
    ServiceCell *cell = [super createCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.valueTextView = [[ServiceCellManager defaultManager] createTextView];
    [cell.valueTextView updateOriginY:cell.nameLabel.frame.origin.y - 9];
    [cell.contentView addSubview:cell.valueTextView];
    
    //for test
    //cell.valueTextView.backgroundColor = [UIColor blueColor];
    
    return cell;
}

+ (NSString *)getCellIdentifier
{
    return @"ServiceCell";
}

+ (CGFloat)getCellHeightWithService:(Service *)service
{
    CGSize size = [[ServiceCellManager defaultManager] sizeWithText:service.content];
    CGFloat height = 2 * SPACE + size.height;
    return MAX(height, 26);
}

- (void)updateCellWithService:(Service *)service
                    indexPath:(NSIndexPath *)indexPath
                       isLast:(BOOL)isLast
                     canClick:(BOOL)canClick
{
    self.indexPath = indexPath;
    
    self.nameLabel.text = service.name;
    
    NSString *value =  service.content;
    self.valueTextView.text = value;
    self.valueTextView.textColor = [UIColor hexColor:@"222222"];
    CGSize size = [[ServiceCellManager defaultManager] sizeWithText:self.valueTextView.text];
    [self.valueTextView updateHeight:size.height];
    
    CGFloat height = [ServiceCell getCellHeightWithService:service];
    [self updateHeight:height];
    
    [self.contentView bringSubviewToFront:self.holderView];
    
    //增加停车图标
    if (service.isPark) {
        self.detailImageView.hidden = NO;
    }else{
        self.detailImageView.hidden = YES;
    }
}

- (IBAction)clickDetailButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickServiceCellDetailButton:)]) {
        [_delegate didClickServiceCellDetailButton:_indexPath];
    }
}

@end
