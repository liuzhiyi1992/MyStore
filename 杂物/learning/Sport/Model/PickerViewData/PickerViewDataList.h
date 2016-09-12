//
//  PickerViewDataList.h
//  Sport
//
//  Created by xiaoyang on 16/5/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusinessPickerData.h"
#import "DropDownDataManager.h"

@interface PickerViewDataList : NSObject

//统一绑入BusinessPickerData这个数据模型，方便调用
+ (BusinessPickerData *)data;

//当前时间
+ (NSInteger)currentHour;

//把日期转换成要显示的字符串
+ (NSString *)dateFormatTransformToNSString:(NSDate *)date;

@end
