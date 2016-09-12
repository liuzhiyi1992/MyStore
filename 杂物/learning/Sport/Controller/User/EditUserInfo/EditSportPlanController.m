//
//  EditSportPlanController.m
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "EditSportPlanController.h"
#import "SportPopupView.h"

@interface EditSportPlanController ()
@property (assign, nonatomic) int tag;
@property (copy, nonatomic) NSString *content;
@end

@implementation EditSportPlanController

- (void)viewDidUnload {
    [self setContentTextView:nil];
    [self setInputBackgroundImageView:nil];
    [self setTipsLabel:nil];
    [self setCountLabel:nil];
    [super viewDidUnload];
}

- (instancetype)initWithContent:(NSString *)content tag:(int)tag
{
    self = [super init];
    if (self) {
        self.content = content;
        self.tag = tag;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentTextView.text = _content;
    [self.contentTextView becomeFirstResponder];
    [self.inputBackgroundImageView setImage:[SportImage inputBackground3Image]];
    
    self.countLabel.text = [@([_content length]) stringValue];
    self.tipsLabel.text = [NSString stringWithFormat:@"请保持在%d字以内", self.maxLength];
    
    [self createRightTopButton:@"确定"];
}

-(void)clickRightTopButton:(id)sender
{
    [self saveAndBack];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger length = [textView.text length];
    self.countLabel.text = [@(length) stringValue];//[NSString stringWithFormat:@"%d", length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


- (BOOL)handleGestureNavigate
{
    [self saveAndBack];
    return NO;
}

- (void)saveAndBack
{
    if ([self.contentTextView.text length] > _maxLength) {
        [SportPopupView popupWithMessage:[NSString stringWithFormat:@"字数超过%d个", _maxLength]];
        return;
    }
    if ([_delegate respondsToSelector:@selector(didClickEditSportPlanControllerBackButton:tag:)]) {
        [_delegate didClickEditSportPlanControllerBackButton:_contentTextView.text tag:_tag];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
