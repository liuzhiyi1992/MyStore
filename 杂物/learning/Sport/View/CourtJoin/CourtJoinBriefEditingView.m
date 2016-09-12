//
//  CourtJoinBriefEditingView.m
//  Sport
//
//  Created by lzy on 16/6/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinBriefEditingView.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "CourtJoinService.h"
#import "SportProgressView.h"
#import "SponsorCourtJoinEditingView.h"
#import "SportPopupView.h"
#import "NSString+Utils.h"

NSString * const COURTJOIN_DESC_LABEL_DEFAULT_CONTENT = @"暂无球局介绍";
#define MAX_POST_LENGTH 30

@interface CourtJoinBriefEditingView () <UITextViewDelegate>
@property (strong, nonatomic) UIView *cover;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UILabel *textCountLabel;
@property (strong, nonatomic) Order *order;
@property (copy, nonatomic) NSString *validDesc;
@end

@implementation CourtJoinBriefEditingView
+ (CourtJoinBriefEditingView *)createView:(id<CourtJoinBriefEditingViewDelegate>)delegate order:(Order *)order courtJoinDesc:(NSString *)courtJoinDesc {
    CourtJoinBriefEditingView *view = [[NSBundle mainBundle] loadNibNamed:@"CourtJoinBriefEditingView" owner:nil options:nil][0];
    view.delegate = delegate;
    view.order = order;
    [view configureViewWithCourtJoinDesc:courtJoinDesc];
    return view;
}

- (void)configureViewWithCourtJoinDesc:(NSString *)courtJoinDesc {
    _descTextView.layer.borderColor = [UIColor hexColor:@"e6e6e6"].CGColor;
    _descTextView.layer.borderWidth = 0.5f;
    _descTextView.delegate = self;
    if (courtJoinDesc.length > 0 && ![courtJoinDesc isEqualToString:COURTJOIN_DESC_LABEL_DEFAULT_CONTENT]) {
        _descTextView.text = courtJoinDesc;
        _descTextView.textColor = [UIColor hexColor:@"222222"];
        _textCountLabel.text = [NSString stringWithFormat:@"%d", (MAX_POST_LENGTH - (int)_descTextView.text.length)];
    } else {
        _descTextView.text = TEXTVIEW_TEXT_DEFAULT;
        _descTextView.textColor = [UIColor hexColor:@"666666"];
        _textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_POST_LENGTH];
    }
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.cover = [[UIView alloc] initWithFrame:newSuperview.frame];
    [_cover setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.5f]];
    [_cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCover)]];
    [newSuperview addSubview:_cover];
    
    [self updateWidth:0.8 * [[UIScreen mainScreen] bounds].size.width];
    [self setCenter:newSuperview.center];
}

- (void)dismiss {
    [_cover removeFromSuperview];
    [self removeFromSuperview];
}

- (IBAction)clickCancelButton:(id)sender {
    [self dismiss];
}

- (IBAction)clickSubmitButton:(id)sender {
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:nil];
    [self validTextViewInput:_descTextView];
    self.validDesc = @"";
    if (![_descTextView.text isEqualToString:TEXTVIEW_TEXT_DEFAULT]) {
        self.validDesc = _descTextView.text;
    }
    __weak __typeof(self) weakSelf = self;
    [CourtJoinService updateCourtJoinDescWithOrderId:_order.orderId userId:user.userId desc:_validDesc completion:^(NSString *status, NSString *msg, NSString *resultStatus) {
        if ([status isEqualToString:STATUS_SUCCESS] &&
                [_delegate respondsToSelector:@selector(briefEditingViewDidSubmitWithDesc:)]) {
            [_delegate briefEditingViewDidSubmitWithDesc:_validDesc];
            [SportProgressView dismiss];
            [weakSelf dismiss];
        } else {
            [SportProgressView dismissWithError:msg];
        }
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:TEXTVIEW_TEXT_DEFAULT]) {
        textView.text = @"";
        textView.textColor = [UIColor hexColor:@"222222"];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = TEXTVIEW_TEXT_DEFAULT;
        _textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_POST_LENGTH];
        
        textView.textColor = [UIColor hexColor:@"666666"];
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    if (nil == selectedRange) {
        [self validTextViewInput:textView];
    }
}

- (void)validTextViewInput:(UITextView *)textView {
    if ([textView.text isEqualToString:TEXTVIEW_TEXT_DEFAULT]) {
        textView.text = @"";
        _textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_POST_LENGTH];
    }
    NSString *toBeString = textView.text;
    if (toBeString.length > MAX_POST_LENGTH) {
        textView.text = [toBeString substringToIndex:MAX_POST_LENGTH];
        [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_POST_LENGTH]];
    }
    int restNumber = MAX_POST_LENGTH - (int)[textView.text length];
    _textCountLabel.text = [@(restNumber) stringValue];
}

- (NSString *)preProcessInputText:(NSString *)text {
    return [[text stringByTrimmingLeadingWhitespaceAndNewline] stringByTrimmingTrailingWhitespaceAndNewline];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_descTextView resignFirstResponder];
}

- (void)tapCover {
    [_descTextView resignFirstResponder];
}

@end
