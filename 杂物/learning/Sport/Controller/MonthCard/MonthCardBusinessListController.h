//
//  MonthCardBusinessListController.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "MonthCardVenuesListCell.h"
#import "MonthCardCourseListCell.h"
#import "MonthCardService.h"
#import "SportFilterListView.h"

typedef enum{
    SELECTED_LIST_VENUES = 0,
    SELECTED_LIST_COURSE = 1,
}SELECTED_LIST;

@interface MonthCardBusinessListController : SportController<UITableViewDataSource,UITableViewDelegate,MonthCardServiceDelegate,SportFilterListViewDelegate>

-(id)initWithType:(SELECTED_LIST)type;

@end
