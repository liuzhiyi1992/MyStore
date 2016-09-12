//
//  ServiceSectionHeaderView.m
//  Sport
//
//  Created by xiaoyang on 15/12/18.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "ServiceSectionHeaderView.h"

@implementation ServiceSectionHeaderView


+ (ServiceSectionHeaderView *)createServiceSectionHeaderView    //加载xib
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ServiceSectionHeaderView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    ServiceSectionHeaderView *view = [topLevelObjects objectAtIndex:0];
    return view;
}

+ (CGFloat)height
{
    return 30;
}

@end
