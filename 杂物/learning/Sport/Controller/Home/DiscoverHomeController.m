//
//  DiscoverHomeController.m
//  Sport
//
//  Created by xiaoyang on 16/5/10.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DiscoverHomeController.h"
#import "UIScrollView+SportRefresh.h"
#import "UIView+Utils.h"
#import "DiscoverHomeCell.h"
#import "MainController.h"
#import "SportSignInController.h"
#import "CoachListController.h"
#import "ForumHomeController.h"
#import "SportRecordsViewController.h"
#import "CourtJoinListController.h"
#import "DiscoverService.h"
#import "UIImageView+WebCache.h"
#import "Discover.h"
#import "SportPopupView.h"
#import "GoSportUrlAnalysis.h"
#import "SportWebController.h"

@interface DiscoverHomeController ()<DiscoverServiceDelegate>
@property (strong, nonatomic) NSArray *groupDataList;
@property (strong, nonatomic) NSArray *discoverList;

@end

@implementation DiscoverHomeController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_DID_CHANGE_CITY object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeCity)
                                                     name:NOTIFICATION_NAME_DID_CHANGE_CITY
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发现";
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView beginReload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        [self.dataTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
}

- (void)didChangeCity {
    [self loadNewData];
}

- (void)loadNewData {
    [self querydata];
}

- (void)querydata {
    NSString *cityID = [CityManager readCurrentCityId];
    [DiscoverService queryDiscover:self cityId:cityID];
}

- (void)getDataWithDiscoverList:(NSArray *)discoverList status:(NSString *)status msg:(NSString *)msg {
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.discoverList = discoverList;
    }else {
        
        [SportPopupView popupWithMessage:msg];
    }
    
    [self.dataTableView endLoad];
    
    [self.dataTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_discoverList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = _discoverList[section];
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *list = _discoverList[indexPath.section];
    Discover *discover = list[indexPath.row];
    
    DiscoverHomeCell *cell = [DiscoverHomeCell cellWithTableView:tableView];
    BOOL isLast = (indexPath.row == [list count] - 1 ? YES : NO);
    
    [cell updateCell:discover.name  iconImageUrl:discover.imageUrl indexPath:indexPath isLast:isLast];
    
    cell.option=^{
        NSURL *url = [NSURL URLWithString:discover.link];
        if ([GoSportUrlAnalysis isGoSportScheme:url]) {
            [GoSportUrlAnalysis pushControllerWithUrl:url NavigationController:self.navigationController];
        } else {
            SportWebController *controller = [[SportWebController alloc] initWithUrlString:discover.link title:discover.name];
            [self.navigationController pushViewController:controller animated:NO];
        }
    };
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [DiscoverHomeCell getCellHeight];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //加这个东西其实主要为了调背景颜色的
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    v.backgroundColor = [UIColor hexColor:@"f5f5f9"];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[DiscoverHomeCell class]]){
       
        DiscoverHomeCell *discoverHomeCell = (DiscoverHomeCell *)cell;
        if (discoverHomeCell.option){
            discoverHomeCell.option();
        }
    }
    
}

@end
