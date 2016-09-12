//
//  SportPopupView.m
//  Sport
//
//  Created by haodong  on 13-8-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportPopupView.h"
#import "TKAlertCenter.h"

@implementation SportPopupView

+ (void)popupWithMessage:(NSString *)message
{
    [[TKAlertCenter defaultCenter] cleanPostAlertWithMessage:message];
}

@end
