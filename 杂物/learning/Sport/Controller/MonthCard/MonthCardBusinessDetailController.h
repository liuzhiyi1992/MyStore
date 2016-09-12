//
//  MonthCardBusinessDetailController.h
//  Sport
//
//  Created by qiuhaodong on 15/6/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "CategoryButtonListView.h"

@interface MonthCardBusinessDetailController : SportController <CategoryButtonListViewDelegate>

- (instancetype)initWithBusinessId:(NSString *)businessId
                        categoryId:(NSString *)categoryId;

@end
