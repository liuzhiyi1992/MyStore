//
//  RecommendDetailAlertView.m
//  Sport
//
//  Created by xiaoyang on 16/7/26.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "RecommendDetailAlertView.h"
#import "SportPopupView.h"

@interface RecommendDetailAlertView()
@property (copy, nonatomic) NSString *businessNameTextfieldText;

@end

@implementation RecommendDetailAlertView

+ (RecommendDetailAlertView *)createRecommendDetailAlertView{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RecommendDetailAlertView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    RecommendDetailAlertView *view = [topLevelObjects objectAtIndex:0];
    
    view.frame = [UIScreen mainScreen].bounds;
    view.contentHolderView.layer.cornerRadius = 5;
    view.contentHolderView.layer.masksToBounds = YES;
    
    [view.selectedAddressButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:view.selectedAddressButton.currentTitle];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"666666"] range:strRange];
    
    [view.selectedAddressButton setAttributedTitle:str forState:UIControlStateNormal];
    
    view.addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    view.addressLabel.numberOfLines = 0;
    
    view.submitButton.layer.cornerRadius = 15;
    view.submitButton.layer.masksToBounds = YES;
    
    view.submitButton.enabled = NO;
    
    view.cancelButton.layer.cornerRadius = 15;
    view.cancelButton.layer.masksToBounds = YES;
    [view.cancelButton.layer setBorderWidth:0.5];
    view.cancelButton.layer.borderColor=[UIColor hexColor:@"5b73f2"].CGColor;
    
    view.businessNameTextfieldText = nil;
    
    return view;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];

}

- (IBAction)clickCancelButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)selectedPosition:(id)sender {
    if ([_delegate respondsToSelector:@selector(didSelectedPosition)]) {
        [_delegate didSelectedPosition];
    }
}

- (IBAction)clickSubmitButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickSubmitButtonWithBusinessNameTextfieldText:)]) {
        [_delegate didClickSubmitButtonWithBusinessNameTextfieldText:_businessNameTextfieldText];
    }
    
}

- (IBAction)clickBackground:(id)sender {
    [self.businessNameTextfield resignFirstResponder];
}

#pragma mark - TextFieldDelegate

#define MAX_TEXT_NUMBER   20

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]){
        return YES;
    }
    
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.businessNameTextfield == textField)
    {
        if ([aString length] > MAX_TEXT_NUMBER) {
            textField.text = [aString substringToIndex:MAX_TEXT_NUMBER];

            [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_TEXT_NUMBER]];

            return NO;
        }
        
        self.businessNameTextfieldText = aString;
        if ([_delegate respondsToSelector:@selector(updateTextFieldText:)]) {
            [_delegate updateTextFieldText:aString];
        }

    }
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if ([textField.text length] > MAX_TEXT_NUMBER) {
        textField.text = [textField.text substringToIndex:MAX_TEXT_NUMBER];
        
        [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_TEXT_NUMBER]];
        
    }
    
    self.businessNameTextfieldText = textField.text;
    if ([_delegate respondsToSelector:@selector(updateTextFieldText:)]) {
        [_delegate updateTextFieldText:textField.text];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.businessNameTextfield) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

@end
