//
//  InputGoodsCountView.m
//  Sport
//
//  Created by haodong  on 15/1/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "InputGoodsCountView.h"
#import <QuartzCore/QuartzCore.h>

@interface InputGoodsCountView()

@property (assign, nonatomic) int count;
@property (assign, nonatomic) int maxCount;
@end

@implementation InputGoodsCountView

+ (InputGoodsCountView *)createInputGoodsCountView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InputGoodsCountView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    InputGoodsCountView *view = [topLevelObjects objectAtIndex:0];
    
    view.frame = [UIScreen mainScreen].bounds;
    
    view.contentHolderView.layer.cornerRadius = 3;
    view.contentHolderView.layer.masksToBounds = YES;
    
    [view.lineImageView setImage:[SportImage lineImage]];
    [view.line2ImageView setImage:[SportImage lineVerticalImage]];
    
    [view.inputBackgroundImageView setImage:[SportImage inputBackgroundWhiteImage]];
    view.contentHolderView.center = CGPointMake(view.center.x, view.center.y - 20);
    ;
    [view.minusButton setBackgroundImage:[SportImage minusButtonImage] forState:UIControlStateNormal];
    [view.plusButton setBackgroundImage:[SportImage plusButtonImage] forState:UIControlStateNormal];
    [view.minusButton setBackgroundImage:[SportImage minusButtonOffImage] forState:UIControlStateDisabled];
    [view.plusButton setBackgroundImage:[SportImage plusButtonOffImage] forState:UIControlStateDisabled];
    
    view.countTextField.delegate = view;
    return view;
}

- (void)updateViewCount:(int)count maxCount:(int)maxCount
{
    self.count = count;
    self.maxCount = maxCount;
    
    [self updateMinusButtonAndPlusButton];
    
    [self updateCoutTextField];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.contentHolderView.alpha = 0;
    self.contentHolderView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.2 delay:0.06 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.contentHolderView.alpha = 1;
        self.contentHolderView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
    }];
}

- (void)updateCoutTextField
{
    self.countTextField.text = [@(_count) stringValue];
}

- (void)updateMinusButtonAndPlusButton
{
    if (_count <= 1) {
        self.minusButton.enabled = NO;
    } else {
        self.minusButton.enabled = YES;
    }
    
    if (_count >= _maxCount) {
        self.plusButton.enabled = NO;
    } else {
        self.plusButton.enabled = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.count = [aString intValue];
    [self updateMinusButtonAndPlusButton];
    return YES;
}

- (IBAction)clickMinusButton:(id)sender {
    self.count = [self.countTextField.text intValue];
    [self.countTextField resignFirstResponder];
    
    if (_count > 1) {
        _count --;
    }
    
    [self updateMinusButtonAndPlusButton];
    
    [self updateCoutTextField];
}

- (IBAction)clickPlusButton:(id)sender {
    self.count = [self.countTextField.text intValue];
    [self.countTextField resignFirstResponder];
    
    if (_count < _maxCount) {
        _count ++;;
    }
    
    [self updateMinusButtonAndPlusButton];
    
    [self updateCoutTextField];
}

- (IBAction)clickCancelButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickInputGoodsCountViewCancelButton)]) {
        [_delegate didClickInputGoodsCountViewCancelButton];
    }

    [self removeFromSuperview];
}

- (IBAction)clickOKButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickInputGoodsCountViewOKButton:)]) {
        [_delegate didClickInputGoodsCountViewOKButton:[_countTextField.text intValue]];
    }
    
    [self removeFromSuperview];
}

- (IBAction)touchDownBackground:(id)sender {
    self.count = [self.countTextField.text intValue];
    if ([_delegate respondsToSelector:@selector(didClickBackground)]) {
        [_delegate didClickBackground];
    }
}

     
@end
