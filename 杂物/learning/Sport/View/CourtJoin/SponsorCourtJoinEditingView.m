//
//  SponsorCourtJoinEditingView.m
//  Sport
//
//  Created by lzy on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SponsorCourtJoinEditingView.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "CourtJoinService.h"
#import "CourtJoin.h"
#import "SportPopupView.h"
#import "SportProgressView.h"

#define KEYBOARD_ADAPTIVE_MARGIN 20

NSString * const NOTIFICATION_NAME_COURT_JOIN_SUCCESS = @"NOTIFICATION_NAME_COURT_JOIN_SUCCESS";
NSString * const NOTIFICATION_NAME_COURT_JOIN_IMPROVE_PERSONAL_INFO = @"NOTIFICATION_NAME_COURT_JOIN_IMPROVE_PERSONAL_INFO";
NSString * const TEXTVIEW_TEXT_DEFAULT = @"向其他球友介绍一下你的球局吧！\n例如：“已有3人，有高手，有妹子！”";
#define MAX_POST_LENGTH 30

@interface SponsorCourtJoinEditingView () <UITextViewDelegate>
@property (strong, nonatomic) UIView *cover;
@property (weak, nonatomic) IBOutlet UITextField *numOfPeopleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UILabel *textCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxJoinNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *payBackMsgLabel;
@property (assign, nonatomic) CGFloat viewOriginY;

@end

@implementation SponsorCourtJoinEditingView

+ (SponsorCourtJoinEditingView *)showWithOrder:(Order *)order {
    SponsorCourtJoinEditingView *view = [[NSBundle mainBundle] loadNibNamed:@"SponsorCourtJoinEditingView" owner:self options:nil][0];
    [view registeredNotification];
    [view showViewWithOrder:order];
    return view;
}

- (void)registeredNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)resignNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self resignNotification];
}

- (void)showViewWithOrder:(Order *)order {
    self.order = order;
    _numOfPeopleTextField.layer.borderWidth = 0.7f;
    _numOfPeopleTextField.layer.borderColor = [UIColor hexColor:@"dddddd"].CGColor;
    _contentTextView.layer.borderWidth = 0.5f;
    _contentTextView.layer.borderColor = [UIColor hexColor:@"dddddd"].CGColor;
    _contentTextView.text = TEXTVIEW_TEXT_DEFAULT;
    _textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_POST_LENGTH];
    _contentTextView.textColor = [UIColor hexColor:@"aaaaaa"];
    _contentTextView.delegate = self;
    _maxJoinNumLabel.text = [NSString stringWithFormat:@"(最多%d人)", order.courtJoin.maximumNumber];
    _payBackMsgLabel.text = order.courtJoin.courtJoinMsg;
    [self show];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.cover = [[UIView alloc] initWithFrame:newSuperview.bounds];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCover:)];
    [_cover addGestureRecognizer:tapGesture];
    [_cover setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.5f]];
    [newSuperview insertSubview:_cover belowSubview:self];
    
    [self updateWidth:0.8 * [[UIScreen mainScreen] bounds].size.width];
    [self setCenter:newSuperview.center];
}

- (void)show {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.viewOriginY = self.frame.origin.y;
}

- (void)dismiss {
    [_cover removeFromSuperview];
    [self removeFromSuperview];
}

- (IBAction)clickCancelButton:(id)sender {
    [_cover removeFromSuperview];
    [self removeFromSuperview];
}

- (IBAction)clickPlusButton:(id)sender {
    int numberOfPeople = [_numOfPeopleTextField.text intValue];
    //这里有个上限，从接口获取
    if (_order.courtJoin.maximumNumber <= numberOfPeople) {
        return;
    }
    _numOfPeopleTextField.text = [NSString stringWithFormat:@"%d", ++numberOfPeople];
    [self updateButtonStatusWithNum:numberOfPeople];
}

- (IBAction)clickMinusButton:(id)sender {
    int numberOfPeople = [_numOfPeopleTextField.text intValue];
    if (numberOfPeople <= 1) {
        return;
    }
    _numOfPeopleTextField.text = [NSString stringWithFormat:@"%d", --numberOfPeople];
    [self updateButtonStatusWithNum:numberOfPeople];
}

- (void)updateButtonStatusWithNum:(int)numberOfPeople {
    if (_order.courtJoin.maximumNumber <= numberOfPeople) {
        [_plusButton setEnabled:NO];
    } else {
        [_plusButton setEnabled:YES];
    }
    if (numberOfPeople <= 1) {
        [_minusButton setEnabled:NO];
    } else {
        [_minusButton setEnabled:YES];
    }
}

- (void)clickCover:(id)sender {
    [_contentTextView resignFirstResponder];
}

- (IBAction)clickSubmitButton:(id)sender {
    NSString *validDesc = @"";
    [self validTextViewInput:_contentTextView];
    if (![_contentTextView.text isEqualToString:TEXTVIEW_TEXT_DEFAULT]) { //no default
        validDesc = _contentTextView.text;
    }
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"发起请求中" hasMask:YES];
    __weak __typeof(self) weakSelf = self;
    [CourtJoinService sponsorCourtJoinWithUserId:user.userId orderId:_order.orderId phone:user.phoneEncode playersNum:[_numOfPeopleTextField.text intValue] description:validDesc completion:^(NSString *status, NSString *msg, NSString *shareUrl, BOOL isFirstTimeSponsorCourt, ShareContent *shareContent) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [weakSelf dismiss];
            if (isFirstTimeSponsorCourt) {
                [SportProgressView dismiss];
                //ImprovePersonalInfo
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_COURT_JOIN_IMPROVE_PERSONAL_INFO object:nil];
            } else {
                [SportProgressView dismissWithSuccess:@"球局已发布"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_COURT_JOIN_SUCCESS object:nil userInfo:@{PARA_SHARE_CONTENT:shareContent}];
        } else {
            [SportProgressView dismissWithError:msg];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.contentTextView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.textColor = [UIColor hexColor:@"222222"];
    if ([textView.text isEqualToString:TEXTVIEW_TEXT_DEFAULT]) {
        textView.text = @"";
        _textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_POST_LENGTH];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = TEXTVIEW_TEXT_DEFAULT;
        textView.textColor = [UIColor hexColor:@"aaaaaa"];
    }
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

- (void)keyboardWillShow:(NSNotification *)notify {
    NSValue *value = [[notify userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [value CGRectValue];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect windowRect = [self convertRect:_contentTextView.frame toView:window];
    CGFloat diff = CGRectGetMaxY(windowRect) - CGRectGetMinY(keyboardEndFrame);
    if (diff >= 0) {
        [self updateOriginY:self.frame.origin.y - diff - KEYBOARD_ADAPTIVE_MARGIN];
    }
}

- (void)keyboardWillHide {
    [self updateOriginY:_viewOriginY];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
