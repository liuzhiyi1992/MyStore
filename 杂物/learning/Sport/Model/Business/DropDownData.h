//
//  DropDownData.h
//  Sport
//
//  Created by qiuhaodong on 16/2/24.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropDownData : NSObject

@property (copy, nonatomic) NSString *idString;
@property (copy, nonatomic) NSString *value;
@property (copy, nonatomic) NSString *iconUrl;

+ (DropDownData *)createDataWithIdString:(NSString *)idString
                                   value:(NSString *)value
                                 iconUrl:(NSString *)iconUrl;

@end
