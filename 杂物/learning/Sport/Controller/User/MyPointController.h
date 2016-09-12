//
//  MyPointController.h
//  Sport
//
//  Created by haodong  on 14/11/12.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PointService.h"

@interface MyPointController : SportController<UITableViewDataSource, UITableViewDelegate, PointServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *myPointCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (strong, nonatomic) IBOutlet UIView *lineVerticalImageView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (weak, nonatomic) IBOutlet UIView *topHolderView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
