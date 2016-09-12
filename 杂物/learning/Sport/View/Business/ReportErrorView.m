//
//  ReportErrorView.m
//  Sport
//
//  Created by lzy on 16/8/11.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "ReportErrorView.h"
#import "BusinessService.h"
#import "Business.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "CityManager.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "SportImage.h"
#import "SportColor.h"
#import "UIView+ExtendTouchArea.h"

#define KEYBOARD_ADAPTIVE_MARGIN 20
#define TAG_CHECKBOX_ITEM_BASCI 10
#define CONTENT_TEXTVIEW_TEXT_DEFAULT @"提供错误信息被趣运动采纳后，您会得到相应的积分奖励(未登录时无法获得奖励)"
#define BUTTON_BORDER_COLOR_DISABLE [UIColor hexColor:@"e1e1e1"]
#define BUTTON_BORDER_COLOR_ENABLE [UIColor hexColor:@"5b73f2"]
#define TEXTVIEW_TEXTCOLOR_DEFAULT [UIColor hexColor:@"aaaaaa"]
#define TEXTVIEW_TEXTCOLOR_INPUTING [UIColor hexColor:@"222222"]
#define MAX_POST_LENGTH 30

@interface ReportErrorView () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *textCountLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *checkBoxButtons;
@property (strong, nonatomic) UIView *cover;
@property (copy, nonatomic) NSString *venuesId;
@property (copy, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSMutableArray *selectedItemIdList;
@property (assign, nonatomic) CGFloat viewOriginY;
@end

@implementation ReportErrorView
+ (ReportErrorView *)showViewWithVenuesId:(NSString *)venuesId
                  categoryId:(NSString *)categoryId {
    ReportErrorView *view = [[NSBundle mainBundle] loadNibNamed:@"ReportErrorView" owner:nil options:nil][0];
    [view configureView];
    [view registeredNotification];
    view.venuesId = venuesId;
    view.categoryId = categoryId;
    [view show];
    return view;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registeredNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (NSMutableArray *)selectedItemIdList {
    if (nil == _selectedItemIdList) {
        _selectedItemIdList = [NSMutableArray array];
    }
    return _selectedItemIdList;
}

- (void)configureView {
    UIImage *heightlightImage = [SportColor createImageWithColor:BUTTON_BORDER_COLOR_ENABLE];
    UIColor *heightlightTitleColor = [UIColor whiteColor];
    _cancelButton.layer.borderWidth = 0.5f;
    _cancelButton.layer.borderColor = BUTTON_BORDER_COLOR_ENABLE.CGColor;
    [_cancelButton setBackgroundImage:heightlightImage forState:UIControlStateHighlighted];
    [_cancelButton setTitleColor:heightlightTitleColor forState:UIControlStateHighlighted];
    [_cancelButton setClipsToBounds:YES];
    
    _submitButton.layer.borderWidth = 0.5f;
    _submitButton.layer.borderColor = BUTTON_BORDER_COLOR_DISABLE.CGColor;
    [_submitButton setClipsToBounds:YES];
    [_submitButton setBackgroundImage:heightlightImage forState:UIControlStateHighlighted];
    [_submitButton setBackgroundImage:[SportColor createImageWithColor:BUTTON_BORDER_COLOR_DISABLE] forState:UIControlStateDisabled];
    [_submitButton setTitleColor:heightlightTitleColor forState:UIControlStateHighlighted];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_submitButton setEnabled:NO];
    
    [_contentTextView.layer setBorderWidth:0.5f];
    [_contentTextView.layer setBorderColor:[UIColor hexColor:@"e6e6e6"].CGColor];
    [_contentTextView setTextColor:[UIColor hexColor:@"aaaaaa"]];
    [_contentTextView setBackgroundColor:[UIColor hexColor:@"f6f6f6"]];
    [_contentTextView setText:CONTENT_TEXTVIEW_TEXT_DEFAULT];
    [_contentTextView setDelegate:self];
    
    _textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_POST_LENGTH];
    [self.layer setCornerRadius:5.f];
    
    //touchExtend
    for (UIButton *button in _checkBoxButtons) {
        [button setTouchExtendInset:UIEdgeInsetsMake(-5, -15, -5, -15)];
    }
}

- (IBAction)clickCheckBoxBotton:(UIButton *)sender {
    [_contentTextView resignFirstResponder];
    sender.selected = !sender.selected;
    NSString *itemId = [NSString stringWithFormat:@"%d", ((int)sender.tag - TAG_CHECKBOX_ITEM_BASCI)];
    if (sender.selected) {
        [self.selectedItemIdList addObject:itemId];
    } else {
        [self removeItemIdFromSelectedItemIdList:itemId];
    }
    [self changeSubmitButtonStatus];
}

- (void)changeSubmitButtonStatus {
    if (_selectedItemIdList.count > 0) {
        [_submitButton setEnabled:YES];
        [_submitButton.layer setBorderColor:BUTTON_BORDER_COLOR_ENABLE.CGColor];
    } else {
        [_submitButton setEnabled:NO];
        [_submitButton.layer setBorderColor:BUTTON_BORDER_COLOR_DISABLE.CGColor];
    }
}

- (void)removeItemIdFromSelectedItemIdList:(NSString *)itemId {
    for (NSString *value in _selectedItemIdList) {
        if ([value isEqualToString:itemId]) {
            [_selectedItemIdList removeObject:value];
            break;
        }
    }
}

- (IBAction)clickCancelButton:(id)sender {
    [self dismiss];
}

- (IBAction)clickSubmitButton:(id)sender {
    //validInput
    NSString *validDesc = @"";
    [self validTextViewInput:_contentTextView];
    if (![_contentTextView.text isEqualToString:CONTENT_TEXTVIEW_TEXT_DEFAULT]) { //no default
        validDesc = _contentTextView.text;
    }
    User *user = [[UserManager defaultManager] readCurrentUser];
    __weak typeof(self) weakSelf = self;
    [SportProgressView showWithStatus:@"提交中" hasMask:YES];
    [BusinessService submitVenuesMistakeWithUserId:user.userId cityId:[CityManager readCurrentCityId] venuesId:_venuesId venuesCatId:_categoryId typeString:[self packageSelectedItemId] content:validDesc completion:^(NSString *status, NSString *msg) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [SportProgressView dismissWithSuccess:@"感谢您的报错，趣运动将尽快审核"];
            [weakSelf dismiss];
        } else {
            [SportProgressView dismissWithError:msg];
        }
    }];
}

- (NSString *)packageSelectedItemId {
    NSString *itemIdString = [_selectedItemIdList componentsJoinedByString:@","];
    return (itemIdString == nil) ? @"" : itemIdString;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self updateCenterX:newSuperview.center.x];
    [self updateCenterY:newSuperview.center.y];
    //cover
    self.cover = [[UIView alloc] initWithFrame:newSuperview.bounds];
    [_cover setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.5f]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCover:)];
    [_cover addGestureRecognizer:tapGesture];
    [newSuperview insertSubview:_cover belowSubview:self];
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

- (void)validTextViewInput:(UITextView *)textView {
    if ([textView.text isEqualToString:CONTENT_TEXTVIEW_TEXT_DEFAULT]) {
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView setTextColor:TEXTVIEW_TEXTCOLOR_INPUTING];
    if ([textView.text isEqualToString:CONTENT_TEXTVIEW_TEXT_DEFAULT]) {
        textView.text = @"";
        _textCountLabel.text = [NSString stringWithFormat:@"%d", MAX_POST_LENGTH];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = CONTENT_TEXTVIEW_TEXT_DEFAULT;
        textView.textColor = TEXTVIEW_TEXTCOLOR_DEFAULT;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    if (nil == selectedRange) {
        [self validTextViewInput:textView];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_contentTextView resignFirstResponder];
}

- (void)clickCover:(id)sender {
    [_contentTextView resignFirstResponder];
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

@end
