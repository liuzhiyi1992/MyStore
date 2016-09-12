//
//  MainControllerCategory.h
//  Sport
//
//  Created by xiaoyang on 16/6/17.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainControllerCategory : NSObject
@property (strong, nonatomic) NSMutableArray *categoryList;
@property (strong, nonatomic) NSMutableArray *willShowCategoryList;
@property (copy, nonatomic) NSString *currentSelectedCategoryName;
@property (copy, nonatomic) NSString *currentSelectedCategoryId;
@property (strong, nonatomic) NSDate *createTime;
@end
