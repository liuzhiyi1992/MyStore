//
//  SearchBusinessController.h
//  Sport
//
//  Created by haodong  on 13-6-14.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
typedef void(^pushBlock)(NSString *clearWord);

typedef enum {
    ControllerTypeHome = 0,
    ControllerTypeSearchResult = 1,
} ControllerType;

@interface SearchBusinessController : SportController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) ControllerType controllerType;
@property (copy, nonatomic) NSString *transmitSearchText;
@property (copy, nonatomic) pushBlock block;

- (id)initWithControllertype:(ControllerType)controllerType;
@end
