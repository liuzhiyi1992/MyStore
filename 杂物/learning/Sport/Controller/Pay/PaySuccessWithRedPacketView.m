//
//  PaySuccessWithRedPacketView.m
//  Sport
//
//  Created by 冯俊霖 on 15/10/9.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "PaySuccessWithRedPacketView.h"

@interface PaySuccessWithRedPacketView()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *redBacketConstraintWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *redBacketConstraintHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *redBacketConstraintTopY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareButtonConstraintTopY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareButtonConstraintBottomY;

@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundButtonConstraintWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundButtonConstraintHeight;

@end

@implementation PaySuccessWithRedPacketView

+ (PaySuccessWithRedPacketView *)createPaySuccessWithRedPacketView{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PaySuccessWithRedPacketView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    PaySuccessWithRedPacketView *view = [topLevelObjects objectAtIndex:0];
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        view.redBacketConstraintWidth.constant = 256;
        view.redBacketConstraintHeight.constant = 267;
        view.redBacketConstraintTopY.constant = 75;
        view.shareButtonConstraintTopY.constant = 10;
        view.shareButtonConstraintBottomY.constant = 20;
        view.backgroundButtonConstraintWidth.constant = 167;
        view.backgroundButtonConstraintHeight.constant = 218;
    }else if ([UIScreen mainScreen].bounds.size.height == 568){
        view.redBacketConstraintWidth.constant = 256;
        view.redBacketConstraintHeight.constant = 267;
        view.redBacketConstraintTopY.constant = 75 * 568 / 480;
        view.shareButtonConstraintTopY.constant = 10;
        view.shareButtonConstraintBottomY.constant = 20;
        view.backgroundButtonConstraintWidth.constant = 167;
        view.backgroundButtonConstraintHeight.constant = 218;
    }else if ([UIScreen mainScreen].bounds.size.height == 667){
        view.redBacketConstraintWidth.constant = 256 * 375 / 320;
        view.redBacketConstraintHeight.constant = 267 * 375 / 320;
        view.redBacketConstraintTopY.constant = 75 * 667 / 480;
        view.shareButtonConstraintTopY.constant = 20;
        view.shareButtonConstraintBottomY.constant = 30;
        view.backgroundButtonConstraintWidth.constant = 167 * 375 / 320;
        view.backgroundButtonConstraintHeight.constant = 218 * 375 / 320;
    }else{
        view.redBacketConstraintWidth.constant = 256 * 414 / 320;
        view.redBacketConstraintHeight.constant = 267 * 414 / 320;
        view.redBacketConstraintTopY.constant = 75 * 736 / 480;
        view.shareButtonConstraintTopY.constant = 30;
        view.shareButtonConstraintBottomY.constant = 30;
        view.backgroundButtonConstraintWidth.constant = 167 * 414 / 320;
        view.backgroundButtonConstraintHeight.constant = 218 * 414 / 320;
    }
    return view;
}

- (IBAction)clickShareButton:(UIButton *)sender {
    [MobClickUtils event:umeng_event_click_share_red_packet];
    if ([self.delegate respondsToSelector:@selector(didClickShareButton)]) {
        [self.delegate didClickShareButton];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
}
@end
