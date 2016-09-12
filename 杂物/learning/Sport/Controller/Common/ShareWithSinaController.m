//
//  ShareWithSinaController.m
//  Sport
//
//  Created by qiuhaodong on 15/5/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ShareWithSinaController.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "SNSManager.h"

@interface ShareWithSinaController ()
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *imageUrl;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ShareWithSinaController

- (instancetype)initWithContent:(NSString *)content
                          image:(UIImage *)image
                       imageUrl:(NSString *)imageUrl
{
    self = [super init];
    if (self) {
        self.content = content;
        self.image = image;
        self.imageUrl = imageUrl;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"分享到微博";
    [self createLeftTopButton:@"取消"];
    [self createRightTopButton:@"发送"];
    
    [self.imageView setImage:_image];
    self.contentTextView.text = _content;
    NSUInteger length = [_contentTextView.text length];
    self.countLabel.text = [@(length) stringValue];
}

- (void)clickLeftTopButton:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickRightTopButton:(id)sender
{
    [self send];
}

- (void)send
{
    [self.contentTextView resignFirstResponder];
    
    [SportProgressView showWithStatus:@"正在发送" hasMask:YES];
    if (_image && _imageUrl == nil) {
        [SNSService sendSinaImageWeibo:self image:_image text:_contentTextView.text];
    } else {
        [SNSService sendSinaWeibo:self text:_contentTextView.text imageUrl:_imageUrl isShowSending:NO];
    }
}

- (void)didSendSinaWeibo:(BOOL)succ errorText:(NSString *)errorText
{
    if (succ) {
        [SportProgressView dismiss];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_SHARE_TO_SINA object:nil userInfo:nil];
    } else {
        if (errorText) {
            [SportProgressView dismissWithError:errorText];
        } else {
            [SportProgressView dismissWithError:@"发送失败"];
        }
    }
}

#define MAX_POST_LENGTH 140
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *toBeString = textView.text;
    
    UITextRange *selectedRange = [textView markedTextRange];
    
    //获取高亮部分
    UITextPosition *position = nil;
    if (selectedRange) {
        position = [textView positionFromPosition:selectedRange.start offset:0];
    }
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (toBeString.length > MAX_POST_LENGTH) {
            textView.text = [toBeString substringToIndex:MAX_POST_LENGTH];
            [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_POST_LENGTH]];
        }
        
        int restNumber = MAX_POST_LENGTH - (int)[textView.text length];
        if (restNumber > 0) {
            self.countLabel.text = [@(restNumber) stringValue];
        } else {
            self.countLabel.text = @"0";
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self send];
        return NO;
    }
    
    return YES;
}

@end
