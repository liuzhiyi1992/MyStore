//
//  FavourableActivityCell.m
//  Sport
//
//  Created by haodong  on 14/11/7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "FavourableActivityCell.h"
#import "UIView+Utils.h"
#import "FavourableActivity.h"
#import "NSString+Utils.h"
#import "UIBlueRoundStokeButton.h"

@interface FavourableActivityCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) CGFloat tableViewOffsetShifting;
@property (weak, nonatomic) IBOutlet UIBlueRoundStokeButton *nameButton;
@end

@implementation FavourableActivityCell


+ (NSString*)getCellIdentifier
{
    return @"FavourableActivityCell";
}

+ (id)createCell
{
    FavourableActivityCell *cell = [super createCell];
    [cell.lineImageView setImage:[SportImage lineImage]];
    cell.nameButton.userInteractionEnabled = NO;
    //[cell.nameBackgroundImageView setImage:[SportImage blueFrameButtonImage]];
//    [cell.finishInputButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    return cell;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

+ (CGFloat)getCellHeight
{
    return 43.0;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (![self.inviteCodeTextField isFirstResponder]) {
        return;
    }
    //解析通知
    NSDictionary* info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [value getValue:&keyboardRect];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect convertRect = [self convertRect:self.inviteCodeTextField.bounds toView:window];
    
    if(keyboardRect.origin.y < CGRectGetMaxY(convertRect)) {//键盘遮住textField
        CGFloat margin = 30;
        CGFloat diff = CGRectGetMaxY(convertRect) - keyboardRect.origin.y + margin;
        
        UIView *suspensionView = (UIView *)self.superview.superview.superview.superview;
        CGRect suspensionViewFrame = suspensionView.frame;
        suspensionViewFrame.origin.y -= diff;
        
        [UIView animateWithDuration:0.4 animations:^{
            [suspensionView setFrame:suspensionViewFrame];
        }completion:^(BOOL finished) {
            self.tableViewOffsetShifting = diff;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if(self.tableViewOffsetShifting > 0) {
        UIView *suspensionView = (UIView *)self.superview.superview.superview.superview;
        CGRect suspensionViewFrame = suspensionView.frame;
        suspensionViewFrame.origin.y = 0;
        [UIView animateWithDuration:0.4 animations:^{
            [suspensionView setFrame:suspensionViewFrame];
        }completion:^(BOOL finished) {
            self.tableViewOffsetShifting = 0;
        }];
    }
}

- (void)updateCellWithActivity:(FavourableActivity *)activity
                     indexPath:(NSIndexPath *)indexPath
                    isSelected:(BOOL)isSelected
{
    
    BOOL isAvailable = (activity.activityStatus != FavourableActivityStatusNotAvailable);
    BOOL isShowInput = (activity.activityType == FavourableActivityTypeInviteCode);
    
    self.indexPath = indexPath;
    
    [self.nameButton setTitle:activity.activityName forState:UIControlStateNormal];

    CGSize size;
    if ([self.nameButton.titleLabel.text respondsToSelector:@selector(sizeWithAttributes:)]) {
        size = [self.nameButton.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.nameButton.titleLabel.font forKey:NSFontAttributeName]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [self.nameButton.titleLabel.text sizeWithFont:self.nameButton.titleLabel.font];
#pragma clang diagnostic pop
    }
    
    CGFloat margin = 20;
    CGFloat mixWidth = 0.35 * self.frame.size.width;
    CGFloat sizeWidth = size.width + margin;
    //iphone6以下机型，有inviteCodeTextField情况下，nameLabel做收缩
    if(isAvailable && isShowInput && (sizeWidth > mixWidth) && ([UIScreen mainScreen].bounds.size.width <= 320)) {
        [self.nameButton updateWidth:mixWidth];
    }else {
        [self.nameButton updateWidth:sizeWidth];
    }
    CGFloat diffValue = CGRectGetMaxX(self.nameButton.frame) + margin - self.inviteCodeTextField.frame.origin.x;
    [self.inviteCodeTextField updateOriginX:CGRectGetMaxX(self.nameButton.frame) + margin];
    [self.inviteCodeTextField updateWidth:self.inviteCodeTextField.frame.size.width - diffValue];
//    [self.nameButton updateWidth:_nameLabel.frame.size.width];
//    [self.nameBackgroundImageView updateWidth:_nameLabel.frame.size.width];
    
    if (isAvailable) {
        self.rightImageView.hidden = NO;
        self.inviteCodeTextField.hidden = NO;
        self.finishInputButton.hidden = NO;
        self.nameButton.enabled = YES;
//        self.nameLabel.textColor = [SportColor defaultColor];
//        [self.nameBackgroundImageView setImage:[SportImage blueFrameButtonImage]];
        
    } else {
        self.rightImageView.hidden = YES;
        self.inviteCodeTextField.hidden = YES;
        self.finishInputButton.hidden = YES;
        self.nameButton.enabled = NO;
//        self.nameLabel.textColor = [SportColor content2Color];
//        [self.nameBackgroundImageView setImage:[SportImage grayFrameButtonImage]];
    }
    
    if (isSelected) {
        [self.rightImageView setImage:[SportImage radioButtonSelectedImage]];
    } else {
        [self.rightImageView setImage:[SportImage radioButtonUnselectedImage]];
    }
    
    if (isShowInput && isAvailable) {
        
        self.inviteCodeTextField.hidden = NO;
        self.finishInputButton.hidden = NO;
        
        if ([activity.activityInviteCode length] > 0) {
            self.inviteCodeTextField.text = activity.activityInviteCode;
            self.inviteCodeTextField.enabled = NO;
            self.finishInputButton.hidden = YES;
            self.inviteCodeTextField.textColor = [SportColor content2Color];
        } else {
            self.inviteCodeTextField.enabled = YES;
            self.finishInputButton.hidden = NO;
            self.inviteCodeTextField.textColor = [SportColor content1Color];
        }
        
    } else {
        self.inviteCodeTextField.hidden = YES;
        self.finishInputButton.hidden = YES;
    }
}

- (IBAction)clickBackgroundButton:(id)sender {
    if (self.finishInputButton.hidden == YES) {
        if ([_delegate respondsToSelector:@selector(didClickFavourableActivityCellBackgroundButton:)]) {
            [_delegate didClickFavourableActivityCellBackgroundButton:_indexPath];
        }
    } else {
        [self.inviteCodeTextField becomeFirstResponder];
    }
}

- (IBAction)clickFinishInputButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickFavourableActivityCellFinishInputButton:text:)]) {
        [_delegate didClickFavourableActivityCellFinishInputButton:_indexPath text:_inviteCodeTextField.text];
    }
}

@end
