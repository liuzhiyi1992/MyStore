//
//  CoachCollectAndShareView.m
//  Sport
//
//  Created by quyundong on 15/9/6.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachCollectAndShareView.h"

@implementation CoachCollectAndShareView

+ (CoachCollectAndShareView *)createCollectAndShareButtonView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachCollectAndShareView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

@end
