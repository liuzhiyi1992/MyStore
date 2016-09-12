//
//  JudgeImageView.m
//  Coach
//
//  Created by quyundong on 15/6/30.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import "JudgeImageView.h"
@interface JudgeImageView()
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *ImageViews;
@end

@implementation JudgeImageView
+ (JudgeImageView *)createJudgeImageView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JudgeImageView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    JudgeImageView *view = [topLevelObjects objectAtIndex:0];
    
    return view;
}
-(void)updateViewWithMark:(float)mark{
    
    for(UIImageView *imageView in self.ImageViews) {
            [imageView setClipsToBounds:YES];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
        float result = mark-imageView.tag;
        if (result >= 1) {
            imageView.image = [UIImage imageNamed:@"mark_score_10@2x.png"];
        }else if(result <= 0){
            imageView.image = [UIImage imageNamed:@"mark_score_00@2x.png"];
        }else{
            imageView.image = [UIImage imageNamed:@"mark_score_05@2x.png"];
        }
    }
    
}
- (IBAction)clickJudgeButton:(UIButton *)sender {
    int rank = (int)sender.tag+1;
    if ([_delegate respondsToSelector:@selector(didClickJudgeButtonWithRank:)]) {
        [_delegate didClickJudgeButtonWithRank:rank];
    }
}

@end
