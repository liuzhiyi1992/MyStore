//
//  SearchResultController.h
//  Sport
//
//  Created by haodong  on 14-9-12.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BusinessService.h"

@interface SearchResultController : SportController<BusinessServiceDelegate>

- (instancetype)initWithSearchText:(NSString *)searchText;

@end
