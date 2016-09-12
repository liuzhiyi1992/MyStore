//
//  CourtJoinListController.h
//  Sport
//
//  Created by xiaoyang on 16/5/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UIView+Utils.h"

@interface CourtJoinListController : SportController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

- (id)initWithCourtJoinListControllerWithDate:(NSDate *)date;
@end
