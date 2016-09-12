//
//  ReviewListController.h
//  Sport
//
//  Created by haodong  on 14/11/5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "ReviewCell.h"
#import "BusinessService.h"

@interface ReviewListController : SportController<ReviewCellDelegate, BusinessServiceDelegate>

- (instancetype)initWithBusinessId:(NSString *)businessId;
@end
