//
//  UIView+CreateViewFromXib.m
//  Sport
//
//  Created by xiaoyang on 16/4/15.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UIView+CreateViewFromXib.h"

@implementation UIView (CreateViewFromXib)

+ (id)createXibView:(NSString *)className
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0)
    {
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

@end
