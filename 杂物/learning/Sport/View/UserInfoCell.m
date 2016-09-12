//
//  UserInfoCell.m
//  Sport
//
//  Created by haodong  on 13-8-27.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "UserInfoCell.h"
#import "UIView+Utils.h"

@interface UserInfoCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (copy, nonatomic) NSString *value;
@end

@implementation UserInfoCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"UserInfoCell";
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [UserInfoCell createCell];
    }
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"UserInfoCell";
}

+ (CGFloat)getCellHeight
{
    return 45.0;
}

+ (id)createCell
{
    UserInfoCell *cell = (UserInfoCell *)[super createCell];
    cell.arrowImageView.image = [SportImage arrowRightImage];
    return cell;
}

- (void)updateCell:(NSString *)value
          subValue:(NSString *)subValue
       orangeValue:(NSString *)orangeValue
         iconImage:(UIImage *)iconImage
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
         tipsCount:(NSUInteger)tipsCount
    isShowRedPoint:(BOOL)isShowRedPoint
{
    self.value = value;
    self.indexPath = indexPath;
    self.iconImageView.image = iconImage;
    self.valueLabel.text = value;
    
    UIImage *image = nil;
    
//    if (isLast) {
//        image = [SportImage whiteImage];
//        self.shadowImageView.hidden = NO;
//    } else {
//        image = [SportImage otherCellTopBackgroundImage];
//        self.shadowImageView.hidden = YES;
//    }
    
    if (indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image] ;
    [self setBackgroundView:bv];
    
    self.redNumLab.hidden= YES;
    self.tipsCountButton.hidden = YES;

    //待付款的时候显示红点
    if (tipsCount > 0) {
        if ([value isEqualToString:@"场馆会员卡"] || [subValue isEqualToString:@"待付款"]) {
            self.tipsCountButton.hidden = NO;
            [self.tipsCountButton setTitle:[NSString stringWithFormat:@"%d",(int)tipsCount] forState:UIControlStateNormal];
        } else {
            self.redNumLab.hidden = NO;
            self.redNumLab.text=[NSString stringWithFormat:@"(%d)",(int)tipsCount];
        }
    }

    
    if (isShowRedPoint) {
        self.redPointImageView.hidden = NO;
        
        CGSize labelSize = [self.valueLabel sizeThatFits:self.valueLabel.frame.size];
        
        self.redPointImageView.frame = CGRectMake(self.valueLabel.frame.origin.x + labelSize.width + 1.0, self.redPointImageView.frame.origin.y, self.redPointImageView.frame.size.width, self.redPointImageView.frame.size.height);
        
    } else {
        self.redPointImageView.hidden = YES;
    }
    
    if ([subValue length] > 0) {
        self.subValueLabel.hidden = NO;
        self.subValueLabel.text = subValue;
    } else {
        self.subValueLabel.hidden = YES;
    }
    
    if ([orangeValue length] > 0) {
        self.orangeValueLabel.hidden = NO;
        self.orangeValueLabel.text = orangeValue;
    } else {
        self.orangeValueLabel.hidden = YES;
    }
    
    if (_redPointImageView.hidden == NO || _tipsCountButton.hidden == NO || _redNumLab.hidden == NO) {
        [self.subValueLabel updateOriginX:self.redNumLab.frame.origin.x - self.subValueLabel.bounds.size.width - 5];
    }else{
        [self.subValueLabel updateOriginX:self.arrowImageView.frame.origin.x - self.subValueLabel.bounds.size.width - 15];
    }
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickButton:value:)]) {
        [_delegate didClickButton:_indexPath value:_value];
    }
}

@end
