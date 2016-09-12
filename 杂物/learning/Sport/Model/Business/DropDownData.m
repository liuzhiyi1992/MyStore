//
//  DropDownData.m
//  Sport
//
//  Created by qiuhaodong on 16/2/24.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DropDownData.h"

@implementation DropDownData

+ (DropDownData *)createDataWithIdString:(NSString *)idString
                                   value:(NSString *)value
                                 iconUrl:(NSString *)iconUrl
{
    DropDownData *data = [[DropDownData alloc] init];
    data.idString = idString;
    data.value = value;
    data.iconUrl = iconUrl;
    return data;
}

@end
