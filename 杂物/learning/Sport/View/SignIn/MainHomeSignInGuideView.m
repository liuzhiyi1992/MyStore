//
//  MainHomeSignInGuideView.m
//  Sport
//
//  Created by lzy on 16/6/27.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "MainHomeSignInGuideView.h"
#import "UIUtils.h"

int const GUIDE_IMAGE_INDEX_MAX = 24;
CGFloat const GUIDE_ANIM_DURATION = 2;
NSString * const KEY_IS_SHOW_SIGN_IN_GUIDE = @"isShowSignInGuide";

@interface MainHomeSignInGuideView ()
@property (weak, nonatomic) IBOutlet UIImageView *animImageView;

@end
@implementation MainHomeSignInGuideView

+ (MainHomeSignInGuideView *)createView {
    MainHomeSignInGuideView *view = [[NSBundle mainBundle]loadNibNamed:@"MainHomeSignInGuideView" owner:nil options:nil][0];
    [view configureView];
    return view;
}

- (void)configureView {
    NSMutableArray *animImageArray = [NSMutableArray array];
    for (int i = 1; i <= GUIDE_IMAGE_INDEX_MAX; i++) {
        NSString *imageName = [NSString stringWithFormat:@"sign_in_guide_image_%d@2x", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *animImage = [UIImage imageWithContentsOfFile:path];
        [animImageArray addObject:animImage];
    }
    [_animImageView setAnimationImages:animImageArray];
    [_animImageView setAnimationDuration:GUIDE_ANIM_DURATION];
    [_animImageView setAnimationRepeatCount:0];
}

- (void)didMoveToSuperview {
    [_animImageView startAnimating];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *currentVersion = [UIUtils getAppVersion];
    NSString *userDefaultKey = [NSString stringWithFormat:@"%@%@", KEY_IS_SHOW_SIGN_IN_GUIDE, currentVersion];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self removeFromSuperview];
}

@end
