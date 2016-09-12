//
//  EditUserInfoCell.m
//  Sport
//
//  Created by haodong  on 13-7-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "EditUserInfoCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Utils.h"
#import "UIColor+HexColor.h"

@interface EditUserInfoCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UITextView *textView;
@end

@implementation EditUserInfoCell

+ (NSString*)getCellIdentifier
{
    return @"EditUserInfoCell";
}

+ (CGFloat)getCellHeight
{
    return 50;
}

+ (id)createCell
{
    EditUserInfoCell *cell = (EditUserInfoCell *)[super createCell];
    cell.arrowImageView.image = [SportImage arrowRightImage];
    cell.textView = [cell createTextView];
    [cell.contentView addSubview:cell.textView];
    return cell;
}

#define X_TEXT_VIEW     86
#define WIDTH_TEXT_VIEW ([UIScreen mainScreen].bounds.size.width - X_TEXT_VIEW - 37)
#define SPACE   6

- (void)updateCellWith:(NSString *)title
                 value:(NSString *)value
             indexPath:(NSIndexPath *)indexPath
                isLast:(BOOL)isLast
{
    self.titleLabel.text = title;
    self.indexPath = indexPath;
    
    NSString *showValue = value;
    if (value == nil || [value length] == 0) {
        showValue = @"未设置";
        self.valueLabel.textColor = [UIColor hexColor:@"aaaaaa"];
    } else {
        showValue = value;
        self.valueLabel.textColor = [UIColor hexColor:@"222222"];
    }
    self.valueLabel.text = showValue;
    self.textView.text = showValue;
    CGFloat cellHeight = 50;
    
    CGSize texViewSize = [self.textView sizeThatFits:CGSizeMake(WIDTH_TEXT_VIEW, 200)];
    if (texViewSize.height > 40) { //大于一行
        self.valueLabel.hidden = YES;
        self.textView.hidden = NO;
        
        [self.textView updateOriginY:SPACE];
        [self.textView updateHeight:texViewSize.height];
        
        cellHeight = SPACE + texViewSize.height + SPACE;
    } else {
        self.valueLabel.hidden = NO;
        self.textView.hidden = YES;
        
        cellHeight = 50;
    }
    
    [self updateHeight:cellHeight];
    
    UIImage *image = nil;
    if (indexPath.row == 0 && isLast) {
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
}

- (UITextView *)createTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(X_TEXT_VIEW, 0, WIDTH_TEXT_VIEW, 200)] ;
    textView.backgroundColor = [UIColor clearColor];
    [textView setTextColor:[SportColor content1Color]];
    textView.font = [UIFont systemFontOfSize:14];
    textView.userInteractionEnabled = NO;
    textView.scrollEnabled = NO;
    textView.editable = NO;
    if ([textView respondsToSelector:@selector(setSelectable:)]) {
        textView.selectable = NO;
    }
    return textView;
}

@end
