//
//  HomeController.h
//  Sport
//
//  Created by haodong  on 14-4-24.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "HomeService.h"
#import "SportFilterListView.h"
#import "CityListView.h"
#import "BookHomeCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CityManager.h"
#import "HomeHeaderView.h"
#import "MonthCardService.h"
#import "HomeFooterView.h"
#import "FiltrateButtonView.h"

@interface HomeController : SportController<HomeServiceDelegate, UIScrollViewDelegate, SportFilterListViewDelegate, UITableViewDataSource, UITableViewDelegate, BookHomeCellDelegate, MKMapViewDelegate, CLLocationManagerDelegate, CityManagerDelegate, UIAlertViewDelegate, HomeHeaderViewDelegate,MonthCardServiceDelegate,HomeFooterViewDelegate,FiltrateButtonViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *customTitleView;
@property (weak, nonatomic) IBOutlet UIButton *cityButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchButtonBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *footerImageView;

@end
