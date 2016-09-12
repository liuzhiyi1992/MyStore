//
//  ShareFieldWillingSurveyView.m
//  Sport
//
//  Created by lzy on 16/4/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "ShareFieldWillingSurveyView.h"
#import "UserService.h"
#import "SportPopupView.h"

#define TAG_OFFSET 10
#define REFUSE_SELECT_NUM @"5"

@interface ShareFieldWillingSurveyView() <UserServiceDelegate>
@property (copy, nonatomic) NSString *orderId;
@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *sizeAdaptiveConstraints;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *contentLabel;
@end


@implementation ShareFieldWillingSurveyView
+ (ShareFieldWillingSurveyView *)showWithOrderId:(NSString *)orderId {
    ShareFieldWillingSurveyView *view = [self createShareFieldWillingSurveyView];
    [view fitLayout];
    view.orderId = orderId;
    [view show];
    return view;
}

+ (ShareFieldWillingSurveyView *)createShareFieldWillingSurveyView {
    ShareFieldWillingSurveyView *view = [[NSBundle mainBundle] loadNibNamed:@"ShareFieldWillingSurveyView" owner:nil options:nil][0];
    return view;
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    [window addSubview:self];
    
    self.mainContentView.alpha = 0;
    self.mainContentView.transform = CGAffineTransformMakeScale(0, 0);
    
    //anim
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.mainContentView.alpha = 1;
        self.mainContentView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (IBAction)clickCoverButton:(UIButton *)sender {
    [self userRefuseSurvey];
}

- (IBAction)clickCountButton:(UIButton *)sender {
    [self responseSurveyButton:sender];
}

- (IBAction)clickCancelButton:(UIButton *)sender {
    [self userRefuseSurvey];
}

- (void)responseSurveyButton:(UIButton *)button {
    NSString *selectedNum = [NSString stringWithFormat:@"%ld", (long)(button.tag - TAG_OFFSET)];
    NSLog(@"%@", selectedNum);
    //[UserService submitSurveyShareField:self orderId:_orderId selectedNumber:selectedNum];
}

- (void)userRefuseSurvey {
//    [UserService submitSurveyShareField:self orderId:_orderId selectedNumber:REFUSE_SELECT_NUM];
}

- (void)fitLayout {
    CGFloat scale;
    CGFloat contentFontSize;
    CGFloat mainFontSize;
    CGFloat itemButtonFontSize;
    NSLog(@"%2.f", [UIScreen mainScreen].bounds.size.height);
    if ([UIScreen mainScreen].bounds.size.height == 480) {//i4
        scale = 0.7f;
        mainFontSize = 15.0f;
        contentFontSize = 12.0f;
        itemButtonFontSize = 12.0f;
    } else if ([UIScreen mainScreen].bounds.size.height == 568) {//i5
        scale = 0.8f;
        mainFontSize = 15.0f;
        contentFontSize = 12.0f;
        itemButtonFontSize = 12.0f;
    } else {
        return;
    }
    
    for (NSLayoutConstraint *constraint in _sizeAdaptiveConstraints) {
        constraint.constant = scale * constraint.constant;
    }
    
    for (UILabel *label in _contentLabel) {
        label.font = [UIFont systemFontOfSize:contentFontSize];
    }
    _mainLabel.font = [UIFont boldSystemFontOfSize:mainFontSize];
    
    for (UIButton *btn in _itemButtons) {
        btn.titleLabel.font = [UIFont systemFontOfSize:itemButtonFontSize];
    }
}

- (void)didSubmitSurveyShareField:(NSString *)status msg:(NSString *)msg resMsg:(NSString *)resMsg{
    if (resMsg.length > 0) {
        [SportPopupView popupWithMessage:resMsg];
    }
    [self dismiss];
}

@end
