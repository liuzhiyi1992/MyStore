//
//  ShortTipsView.m
//  Sport
//
//  Created by liuzhiyi on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ShortTipsView.h"
#import "UIView+Utils.h"

#define TIME_SLIDE_TEXTLABEL    5.0f
#define TIME_DISPLAY            3.0f

@implementation ShortTipsView

+ (ShortTipsView *)creatShortTipsView {
    return [[NSBundle mainBundle] loadNibNamed:@"ShortTipsView" owner:self options:nil][0];
};

/**
 *  传进来的frame是View透明度从0变1前的初始位置，而非完全显示时的位置
 */
- (void)showWithContent:(NSString *)string frame:(CGRect)frame durationDisplay:(BOOL)durationDisplay holderView:(UIView *)holderView{

    [holderView addSubview:self];
    
    self.frame = frame;
    
    self.alpha = 0;
    NSMutableString *displayString = [NSMutableString stringWithFormat:@" %@", string];
    self.tipsLabel.text = displayString;
    
    //TipsView宽根据内容自适应
    NSDictionary *attribute = @{NSFontAttributeName: self.tipsLabel.font};
    CGFloat dyTextWidth = [displayString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.tipsLabel.frame.size.height) options: NSStringDrawingUsesFontLeading attributes:attribute context:nil].size.width;
    [self.tipsLabel updateWidth:dyTextWidth];
    
    //必须先update下动画的初始位置
    [self.tipsLabel updateOriginX:15];
    
    //超长文字横向滑动时间
    CGFloat duration = TIME_SLIDE_TEXTLABEL;
    //提示条显示时间
    CGFloat displayTime = TIME_DISPLAY;
    
    if(self.tipsLabel.frame.size.width > self.frame.size.width) {
        
        //文字超长的话，显示时间加上文字横向滑动时间
        displayTime += duration;
        
        [UIView animateWithDuration:duration delay:2 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            [self.tipsLabel updateOriginX:self.frame.size.width - self.tipsLabel.frame.size.width];
        } completion:^(BOOL finished) {
        }];
    }
    if(!durationDisplay){
        //出现，消失
        [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            [self sheetIn];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 delay:displayTime options:UIViewAnimationOptionTransitionCurlUp animations:^{
                [self sheetOut];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }];
    }else{
        //出现，不消失
        [UIView animateWithDuration:1 animations:^{
            [self sheetIn];
        }];
        
    }

        
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)sheetIn {
    
    //crangeLocalY
    CGRect tempFrame = self.frame;
    tempFrame.origin.y += self.frame.size.height;
    self.frame = tempFrame;
    
    //crangeAlpha
    self.alpha = 1;
}

- (void)sheetOut {
    
    //crangeLocalY
    CGRect tempFrame = self.frame;
    tempFrame.origin.y -= self.frame.size.height;
    self.frame = tempFrame;
    
    //crangeAlpha
    self.alpha = 0;
}


@end
