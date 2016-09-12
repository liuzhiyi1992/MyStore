//
//  GuidanceView.m
//  Sport
//
//  Created by 冯俊霖 on 15/10/16.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "GuidanceView.h"
@interface GuidanceView()
@end


@implementation GuidanceView

+ (GuidanceView *)createGuidanceView{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GuidanceView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    GuidanceView *view = [topLevelObjects objectAtIndex:0];
    return view;
}

- (IBAction)clickChooseTimeButton:(UIButton *)sender {
    [self removeFromSuperview];
    if ([_delegate respondsToSelector:@selector(didClickGuidanceButton)]) {
        [_delegate didClickGuidanceButton];
    }
}

@end
