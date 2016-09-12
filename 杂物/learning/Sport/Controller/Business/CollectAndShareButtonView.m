//
//  CollectAndShareButtonView.m
//  Sport
//
//  Created by haodong  on 15/3/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CollectAndShareButtonView.h"
#import "UIView+Utils.h"
@implementation CollectAndShareButtonView

+ (CollectAndShareButtonView *)createCollectAndShareButtonView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CollectAndShareButtonView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

+ (CollectAndShareButtonView *)createShareButtonView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CollectAndShareButtonView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    CollectAndShareButtonView *view = [topLevelObjects objectAtIndex:0];
    view.leftButton.hidden = YES;
    view.rightButton.hidden = NO;
    [view updateWidth:view.frame.size.width - 16];
    [view.rightButton updateOriginX:view.rightButton.frame.origin.x - 16];
    
    return view;
}


@end
