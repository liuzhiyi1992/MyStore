//
//  MainController.h
//  Sport
//
//  Created by xiaoyang on 16/5/11.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CityManager.h"
#import "CourtJoinListCell.h"
#import "MainHeaderView.h"
#import "CityListView.h"

@class SignIn;
@interface MainController : SportController<CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,CityManagerDelegate,CourtJoinListCellDelegate,MainHeaderViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *customTitleView;
@property (weak, nonatomic) IBOutlet UIButton *cityButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchButtonBackgroundImageView;
@property (strong, nonatomic) SignIn *signIn;
@end
