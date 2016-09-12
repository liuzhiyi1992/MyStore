  //
//  CoachFeedbackController.m
//  Sport
//
//  Created by 江彦聪 on 15/7/27.
//  Copyright (c) 2015年 : . All rights reserved.
//

#import "CoachFeedbackController.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "CoachService.h"
#import "UserManager.h"


@interface CoachFeedbackController () <CoachServiceDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (copy, nonatomic) NSString* orderId;
@property (copy, nonatomic) NSString* coachId;
@property (copy, nonatomic) NSString* coachName;
@property (weak, nonatomic) IBOutlet UILabel *coachNameLabel;
@end

@implementation CoachFeedbackController

-(id)initWithOrderId:(NSString *)orderId
             coachId:(NSString *)coachId
           coachName:(NSString *)coachName
{
    self = [super init];
    if (self) {
        self.orderId = orderId;
        self.coachId = coachId;
        self.coachName = coachName;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"投诉";
    self.coachNameLabel.text = self.coachName;
    [self.coachNameLabel sizeToFit];

    [self createRightTopButton:@"确定"];
    
    //[self createRightTopNavyBlueButton:[SportImage markButtonImage]];
}

//- (void)clickRightTopNavyBlueButton:(id)sender
//{
//    [self send];
//}

- (void)clickRightTopButton:(id)sender
{
    [self send];
}

- (void)send
{
    if ([self.contentTextView.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入内容"];
        return;
    }
    
    [_contentTextView resignFirstResponder];
    [SportProgressView showWithStatus:DDTF(@"kSubmitting")];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [CoachService sendCoachComplain:self coachId:self.coachId content:self.contentTextView.text userId:user.userId orderId:self.orderId];
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeHolderLabel.hidden = YES;

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSUInteger length = [textView.text length];
    
    if (length == 0) {
        self.placeHolderLabel.hidden = NO;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)didSendCoachComplain:(NSString *)status
                         msg:(NSString *)msg;
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"提交成功"];
        
        [self performSelector:@selector(popController) withObject:nil afterDelay:1];
        
        } else {
        [SportProgressView dismissWithError:msg];
    }
}

-(void)popController
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
