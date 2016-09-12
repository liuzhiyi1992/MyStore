//
//  CourtJoinGuideView.m
//  Sport
//
//  Created by 江彦聪 on 16/7/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinGuideView.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"

@interface CourtJoinGuideView()
@property (weak, nonatomic) IBOutlet UIButton *ruleButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end
@implementation CourtJoinGuideView

+ (CourtJoinGuideView *)createCourtJoinGuideView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CourtJoinGuideView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    CourtJoinGuideView *view = [topLevelObjects objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    view.ruleButton.layer.cornerRadius = 5.0;
    view.ruleButton.layer.masksToBounds = YES;

    return view;
}


- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.closeButton.alpha = 0;
    self.ruleButton.alpha = 0;
    self.ruleButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.5 delay:0.06 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.closeButton.alpha = 1;
        self.ruleButton.alpha = 1;
        self.ruleButton.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)clickDismissButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)touchDownBackground:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)clickCourtJoinRuleButton:(id)sender {
    [self removeFromSuperview];
    BaseConfigManager *manager = [BaseConfigManager defaultManager];
    SportWebController *webController = [[SportWebController alloc]initWithUrlString:manager.courtJoinInstructionUrl title:@"什么是球局"];
    [_superController.navigationController pushViewController:webController animated:YES];
}

@end
