//
//  SportAddMinusView.m
//  Sport
//
//  Created by 江彦聪 on 16/8/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportPlusMinusView.h"
@interface SportPlusMinusView()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@end

@implementation SportPlusMinusView


+ (SportPlusMinusView *)createSportPlusMinusViewWithMaxNumber:(int) maxNumber
                                                    minNumber:(int) minNumber {
    SportPlusMinusView *view = [self createSportPlusMinusView];
    view.minNumber = minNumber;
    view.maxNumber = maxNumber;
    return view;
}

+ (SportPlusMinusView *)createSportPlusMinusView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportPlusMinusView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0)
    {
        return nil;
    }
    SportPlusMinusView *view = [topLevelObjects objectAtIndex:0];

    view.numberTextField.layer.borderColor = [UIColor hexColor:@"dddddd"].CGColor;
    view.numberTextField.layer.borderWidth = 0.5;
    view.numberTextField.layer.cornerRadius = 10.0;
    view.numberTextField.layer.masksToBounds = YES;
    view.numberTextField.inputAccessoryView = [view getNumberToolbar];
    view.numberTextField.delegate = view;
    
    return view;
}

-(void)doneWithNumberPad{
    [self.numberTextField resignFirstResponder];

}

- (UIToolbar *)getNumberToolbar
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.translucent = YES;
    
    [numberToolbar setBarTintColor:[UIColor colorWithRed:206.0/255.0 green:211.0/255.0 blue:215.0/255.0 alpha:1]];
    
    
    //numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)clickMinusButton:(id)sender {
    if (self.countNumber > self.minNumber) {
        self.countNumber --;
    }
    
    [self updateMinusButtonAndPlusButton];
}

- (IBAction)clickPlusButton:(id)sender {
    if (self.countNumber < self.maxNumber) {
        self.countNumber++;;
    }
    
    [self updateMinusButtonAndPlusButton];
}

- (void)updateMinusButtonAndPlusButton
{
    if (self.countNumber <= self.minNumber) {
        self.minusButton.enabled = NO;
        self.countNumber = self.minNumber;
    } else {
        self.minusButton.enabled = YES;
    }
    
    if (self.countNumber >= self.maxNumber) {
        self.plusButton.enabled = NO;
        self.countNumber = self.maxNumber;
    } else {
        self.plusButton.enabled = YES;
    }
    
    if ([_delegate respondsToSelector:@selector(updateSelectNumber:)]) {
        [_delegate updateSelectNumber:self.countNumber];
    }
}

//如果更新了最大值，需要刷新UI
-(void) setMaxNumber:(int)maxNumber {
    if (_maxNumber == maxNumber){
        return;
    }
    
    _maxNumber = maxNumber;
    
    [self updateMinusButtonAndPlusButton];
}

-(void) setMinNumber:(int)minNumber {
    if (_minNumber == minNumber) {
        return;
    }
    _minNumber = minNumber;
    
    [self updateMinusButtonAndPlusButton];
}

- (void)setCountNumber:(int)number {
    _countNumber = number;
    self.numberTextField.text = [@(_countNumber) stringValue];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([aString length] == 0) {
        aString = @"0";
    }
    _countNumber = [aString intValue];
    
    textField.text = [@(_countNumber) stringValue];
    [self updateMinusButtonAndPlusButton];
    return NO;
}

@end
