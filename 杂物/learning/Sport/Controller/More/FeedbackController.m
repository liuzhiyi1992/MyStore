//
//  FeedbackController.m
//  Sport
//
//  Created by haodong  on 13-10-28.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "FeedbackController.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "UserManager.h"

@interface FeedbackController ()

@property (weak, nonatomic) IBOutlet UILabel *qqGroupTipsLabel;

@end

@implementation FeedbackController

- (void)viewDidUnload {
    [self setContentTextView:nil];
    [self setCountTipsLabel:nil];
    [super viewDidUnload];
}

#define SPACE 16
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kFeedback");
//    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
   
    [self createRightTopButton:@"发送"];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
//    if (screenSize.width == 320)
//    {
//       self.qqGroupTipsLabel.frame=CGRectMake(SPACE, 190, screenSize.width - 2 * SPACE, 50);
//        self.qqGroupTipsLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        self.qqGroupTipsLabel.numberOfLines=0;
//    } else {
//       self.qqGroupTipsLabel.frame=CGRectMake(SPACE, 190, screenSize.width - 2 * SPACE, 15);
//    }
    
    if (screenSize.height > 480) {
        [self.contentTextView becomeFirstResponder];
    }
}

- (IBAction)touchDownBackground:(id)sender {
    HDLog(@"touchDownBackground");
    [self.contentTextView resignFirstResponder];
}

- (void)clickRightTopButton:(id)sender
{
    [self send];
}

- (void)send
{
    if ([self.contentTextView.text length] == 0) {
        [SportPopupView popupWithMessage:DDTF(@"请输入内容")];
        return;
    }
    [_contentTextView resignFirstResponder];
    [SportProgressView showWithStatus:DDTF(@"kSubmitting")];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [[BaseService defaultService] feedback:self
                                   content:_contentTextView.text
                                    userId:user.userId
                                      type:0];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger length = [textView.text length];
    self.countTipsLabel.text = [@(length) stringValue]; //[NSString stringWithFormat:@"%d", length];
}

- (void)didFeedback:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"提交成功"];
        
        [self performSelector:@selector(popController) withObject:nil afterDelay:1];
        
    } else {
        [SportProgressView dismissWithError:@"提交失败"];
    }
}

- (void)popController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
