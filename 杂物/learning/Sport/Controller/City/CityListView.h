//
//  CityListView.h
//  Sport
//
//  Created by haodong  on 14-4-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityCell.h"
#import "BaseService.h"
#import "City.h"

@interface CityListView : UIView<UITableViewDataSource, UITableViewDelegate, CityCellDelegate, BaseServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *tipsBackgroundImageView;

+ (CityListView *)createCityListView;

- (void)show;

@end
