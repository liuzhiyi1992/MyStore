//
//  CoachHomeMoreView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/20.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachHomeMoreView.h"
#import "TipNumberManager.h"
@interface CoachHomeMoreView()
@property (assign, nonatomic) id<CoachHomeMoreViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *popDownBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *messageCountButton;
@end

@implementation CoachHomeMoreView


+ (CoachHomeMoreView *)createCoachHomeMoreView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachHomeMoreView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CoachHomeMoreView *view = (CoachHomeMoreView *)[topLevelObjects objectAtIndex:0];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height - 64 - 29);
    [view.popDownBackgroundImageView setImage:[SportImage popDownBlueImage]];

    NSInteger count = [TipNumberManager defaultManager].imReceiveMessageCount;
    if (count > 0) {
        view.messageCountButton.hidden = NO;
        [view.messageCountButton setTitle:[NSString stringWithFormat:@"%d", (int)count] forState:UIControlStateNormal];
    } else {
        view.messageCountButton.hidden = YES;
    }
    
    return view;
}

#define TAG_COACHHOMEMOREVIEW   2015072001
+ (void)showInView:(UIView *)view delegate:(id<CoachHomeMoreViewDelegate>)delegate
{
    if (![CoachHomeMoreView removeFromView:view]) {
        CoachHomeMoreView *moreView = [CoachHomeMoreView createCoachHomeMoreView];
        moreView.tag = TAG_COACHHOMEMOREVIEW;
        moreView.delegate = delegate;
        [view addSubview:moreView];
    }
}

+ (BOOL)removeFromView:(UIView *)view
{
    CoachHomeMoreView *moreView = (CoachHomeMoreView *)[view viewWithTag:TAG_COACHHOMEMOREVIEW];
    if (moreView) {
        [moreView removeFromSuperview];
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)touchDownBackground:(id)sender {
    [self hide];
}

- (IBAction)clickMessageButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickCoachHomeMoreViewMessageButton)]) {
        [_delegate didClickCoachHomeMoreViewMessageButton];
    }
    [self hide];
}

- (IBAction)clickMyOrderButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickCoachHomeMoreViewMyOrderButton)]) {
        [_delegate didClickCoachHomeMoreViewMyOrderButton];
    }
    [self hide];
}

- (void)hide
{
    [self removeFromSuperview];
}

@end
