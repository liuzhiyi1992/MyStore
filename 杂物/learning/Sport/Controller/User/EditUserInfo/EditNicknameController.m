//
//  EditNicknameController.m
//  Sport
//
//  Created by haodong  on 13-7-16.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "EditNicknameController.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "SportPopupView.h"

@interface EditNicknameController ()

@property (copy, nonatomic) NSString *nickname;

@end

@implementation EditNicknameController

- (void)viewDidUnload {
    [self setNicknameTextField:nil];
    [self setWriteImageView:nil];
    [super viewDidUnload];
}

- (id)initWithNickname:(NSString *)nickname
{
    self = [super init];
    if (self) {
        self.nickname = nickname;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kNickName");
    self.writeImageView.image = [SportImage penImage];
    self.nicknameTextField.text = _nickname;
    [self.nicknameTextField becomeFirstResponder];
}

- (BOOL)handleGestureNavigate
{
    return [self clickBackButtonFunc];
}

- (BOOL) clickBackButtonFunc
{
    if ([_nicknameTextField.text length] == 0) {
        [SportPopupView popupWithMessage:DDTF(@"kNickNameCannotNull")];
        return NO;
    }
    if ([_nicknameTextField.text length] > 10) {
        [SportPopupView popupWithMessage:DDTF(@"kNickNameCannotLongerThan10")];
        return NO;
    }
    
    if ([_delegate respondsToSelector:@selector(didFinishEditNickName:)]) {
        [_delegate didFinishEditNickName:self.nicknameTextField.text];
    }
    
    return YES;
}

- (void)clickBackButton:(id)sender
{
    if([self clickBackButtonFunc])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickBackButton:nil];
    return YES;
}

@end
