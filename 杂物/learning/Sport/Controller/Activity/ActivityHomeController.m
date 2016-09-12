//
//  ActivityHomeController.m
//  Sport
//
//  Created by haodong  on 14-2-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ActivityHomeController.h"
#import "ActivityDetailController.h"
#import "MyActivityController.h"
#import "FinishActivityController.h"
#import "UserManager.h"
#import "LoginController.h"
#import "User.h"
#import "UIView+Utils.h"
#import "CircleProjectManager.h"
#import "ActivityManager.h"
#import "ManageActivityController.h"
#import "UserInfoController.h"
#import "SportProgressView.h"
#import "EditUserInfoController.h"

#import "SportPickerController.h"

enum {
    ListTypeActivity = 0,
    ListTypePeople = 1,
};

@interface ActivityHomeController ()<SportPickerControllerDelegate>
@property (strong, nonatomic) NSMutableArray *activityList;
@property (strong, nonatomic) NSMutableArray *peopleList;
@property (strong, nonatomic) UIButton *activityButton;
@property (strong, nonatomic) UIButton *peopleButton;
@property (assign, nonatomic) int listType;

@property (copy, nonatomic) NSString *selectedActivityProId;    //运动项目id
@property (assign, nonatomic) NSInteger selectedActivityThemeId;        //主题id
@property (assign, nonatomic) NSInteger selectedActivitySortId;         //排序id
@property (assign, nonatomic) int activityPage;

@property (copy, nonatomic) NSString *selectedPeopleProId;    //运动项目id
@property (copy, nonatomic) NSString *selectedPeopleGender;   //性别
@property (assign, nonatomic) int peoplePage;

@property (assign, nonatomic) BOOL isLoadingMoreActivity;
@property (assign, nonatomic) BOOL hasMoreActivity;

@property (assign, nonatomic) BOOL isLoadingMoreUser;
@property (assign, nonatomic) BOOL hasMoreUser;

@property (assign, nonatomic) BOOL hasUpdateMyLocation;

@end

#define COUNT_ONE_PAGE 20

@implementation ActivityHomeController

- (void)viewDidUnload {
    [self setPeopleTableView:nil];
    [self setActivityTableView:nil];
    [self setActivityHolderView:nil];
    [self setManageActivityButton:nil];
    [self setCreateActivityButton:nil];
    [self setFilterBackgroundImageView:nil];
    [self setPeopleHolderView:nil];
    [self setActivityCategoryFilterButton:nil];
    [self setActivityThemeFilterButton:nil];
    [self setActivitySortFilterButton:nil];
    [self setPeopleGenderFilterButton:nil];
    [self setPeopleCategoryFilterButton:nil];
    [self setActivityFilterHolderView:nil];
    [self setTipsBackgroundImageView:nil];
    [super viewDidUnload];
}

- (void)createTopTitleView
{
    self.activityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 75, 29)] ;
    [_activityButton setBackgroundImage:[SportImage whiteFrameLeftButtonImage] forState:UIControlStateNormal];
    [_activityButton setBackgroundImage:[SportImage whiteFrameLeftButtonSelectedImage] forState:UIControlStateSelected];
    [_activityButton setTitle:@"活动" forState:UIControlStateNormal];
    [_activityButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_activityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_activityButton setTitleColor:[SportColor defaultColor] forState:UIControlStateSelected];
    [_activityButton addTarget:self action:@selector(clickActivityButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.peopleButton = [[UIButton alloc] initWithFrame:CGRectMake(74, 0, 75, 29)] ;
    [_peopleButton setBackgroundImage:[SportImage whiteFrameRightButtonImage] forState:UIControlStateNormal];
    [_peopleButton setBackgroundImage:[SportImage whiteFrameRightButtonSelectedImage] forState:UIControlStateSelected];
    [_peopleButton setTitle:@"个人" forState:UIControlStateNormal];
    [_peopleButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_peopleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_peopleButton setTitleColor:[SportColor defaultColor] forState:UIControlStateSelected];
    [_peopleButton addTarget:self action:@selector(clickPeopleButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 29)] ;
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:_activityButton];
    [titleView addSubview:_peopleButton];
    self.navigationItem.titleView = titleView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
       // self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)clickActivityButton:(id)sender
{
    _listType = ListTypeActivity;
    _activityButton.selected = YES;
    _peopleButton.selected = NO;
    _activityHolderView.hidden = NO;
    _peopleHolderView.hidden = YES;
   
    [_activityTableView reloadData];
    
    if ([_activityList count] > 0) {
        self.tipsBackgroundImageView.hidden = YES;
    }
}

- (void)clickPeopleButton:(id)sender
{
    _listType = ListTypePeople;
    _activityButton.selected = NO;
    _peopleButton.selected = YES;
    _activityHolderView.hidden = YES;
    _peopleHolderView.hidden = NO;
    
    //test data
//    NSMutableArray *testList = [NSMutableArray array];
//    for (int i =0 ; i < 10; i ++) {
//        User *u = [[[User alloc] init] autorelease];
//        [testList addObject:u];
//    }
//    self.peopleList = testList;
    if (_hasUpdateMyLocation == NO) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([user userId] > 0) {
            CLLocation *location = [[UserManager defaultManager] readUserLocation];
            [UserService updateMyLocation:self
                                   userId:user.userId
                                 latitude:location.coordinate.latitude
                                longitude:location.coordinate.longitude];
        }
    }
    
    [_peopleTableView reloadData];
    
    if ([_peopleList count] > 0) {
        self.tipsBackgroundImageView.hidden = YES;
    }
}

- (void)didUpdateMyLocation:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        _hasUpdateMyLocation = YES;
    }
}

//- (void)createRefreshButton
//{
//    CGFloat pace = 6, width = 61, height = 44;
//    if (DeviceSystemMajorVersion() >= 7) {
//        pace = 16;
//    }
//    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(pace, 0, width, height)] autorelease];
//    [button setImage:[SportImage refreshImage] forState:UIControlStateNormal];
//    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
//    [view addSubview:button];
//    [button addTarget:self action:@selector(clickRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:view] autorelease];
//    self.navigationItem.rightBarButtonItem = buttonItem;
//}
//
//- (void)clickRefreshButton:(id)sender
//{
//    if (_listType == ListTypeActivity) {
//        _activityPage = 1;
//        [self queryActivityData];
//    } else if (_listType == ListTypePeople) {
//        _peoplePage = 1;
//        [self queryUserData];
//    }
//}

- (void)clickRightTopButton:(id)sender
{
    if (_listType == ListTypeActivity) {
        _activityPage = 1;
        [self queryActivityData];
    } else if (_listType == ListTypePeople) {
        _peoplePage = 1;
        [self queryUserData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.peoplePage = 1;
    self.activityPage = 1;
    
    //2014-08-04去掉
    //[[ActivityService defaultService] queryCircleProjectList:nil];
    
    //[self queryActivityData];
    //[self queryUserData];
    [self queryActivityDataNoProgressView];
    [self queryUserDataNoProgressView];
    
    //self.pageBackgroundImageView.image = [SportImage pageBackgroundImage];
    [self createTopTitleView];
    [self clickActivityButton:_activityButton];
    
    //[self createRefreshButton];
    [self createRightTopImageButton:[SportImage refreshImage]];
    
    [self.manageActivityButton setBackgroundImage:[SportImage manageActivityButtonImage] forState:UIControlStateNormal];
    [self.manageActivityButton setBackgroundImage:[SportImage manageActivityButtonSelectedImage] forState:UIControlStateHighlighted];
    
    [self.createActivityButton setBackgroundImage:[SportImage createActivityButtonImage] forState:UIControlStateNormal];
    [self.createActivityButton setBackgroundImage:[SportImage createActivityButtonSelectedImage] forState:UIControlStateHighlighted];
    
    self.filterBackgroundImageView.image = [SportImage activityFilterImage];

    [self.activityTableView updateHeight:[UIScreen mainScreen].bounds.size.height  - 64 - 49];
    [self.peopleHolderView updateHeight:[UIScreen mainScreen].bounds.size.height  - 64 - 49];
    
    self.activityTableView.tableFooterView.hidden = YES;
    self.peopleTableView.tableFooterView.hidden = YES;
    
    self.selectedActivityThemeId = -1;
    
    //test data
//    NSMutableArray *testList = [NSMutableArray array];
//    for (int i =0 ; i < 10; i ++) {
//        Activity *ac = [[[Activity alloc] init] autorelease];
//        [testList addObject:ac];
//    }
//    self.activityList = testList;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkUserInfoFinish];
}


- (void)willShowCurrentController
{
    if ([_activityList count] == 0) {
        [self queryActivityDataNoProgressView];
    }
    if ([_peopleList count] == 0) {
        [self queryUserDataNoProgressView];
    }
    if ([[[CircleProjectManager defaultManager] circleProjectList] count] == 0) {
        //2014-08-04去掉
        //[[ActivityService defaultService] queryCircleProjectList:nil];
    }
    
    [self checkUserInfoFinish];
}

- (void)queryActivityDataNoProgressView
{
    double latitude = [[UserManager defaultManager] readUserLocation].coordinate.latitude;
    double longitude = [[UserManager defaultManager] readUserLocation].coordinate.longitude;
    
    NSString *actNameStr = (_selectedActivityThemeId == -1 ?  nil : [@(_selectedActivityThemeId) stringValue]);
    
    [ActivityService queryActivityList:self
                                  type:ActivityListTypeDefault
                                userId:nil
                        activityStatus:nil
                                 proId:_selectedActivityProId
                               actName:actNameStr
                              latitude:latitude
                             longitude:longitude
                                  sort:[@(_selectedActivitySortId) stringValue]
                                  page:_activityPage
                                 count:COUNT_ONE_PAGE];
}

- (void)queryActivityData
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [self queryActivityDataNoProgressView];
}

- (void)queryUserDataNoProgressView
{
    double latitude = [[UserManager defaultManager] readUserLocation].coordinate.latitude;
    double longitude = [[UserManager defaultManager] readUserLocation].coordinate.longitude;
    [ActivityService queryUserList:self
                          latitude:latitude //23.8
                         longitude:longitude //113.17
                            gender:_selectedPeopleGender
                             proId:_selectedPeopleProId
                              sort:nil
                              page:_peoplePage
                             count:COUNT_ONE_PAGE];
}

- (void)queryUserData
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [self queryUserDataNoProgressView];
}

- (void)didQueryActivityList:(NSArray *)list status:(NSString *)status type:(ActivityListType)type page:(int)page
{
    [SportProgressView dismiss];
    _isLoadingMoreActivity = NO;
    if (_activityPage == 1) {
        self.activityList = [NSMutableArray arrayWithArray:list];
    } else {
        [self.activityList addObjectsFromArray:list];
    }
    
    if ([list count] < COUNT_ONE_PAGE) {
        _hasMoreActivity = NO;
        self.activityTableView.tableFooterView.hidden = YES;
    } else {
        _hasMoreActivity = YES;
        self.activityTableView.tableFooterView.hidden = NO;
    }
    
    [self.activityTableView reloadData];
    if (_activityPage == 1 && [_activityList count] > 0) {
        [self.activityTableView  scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    
    //无数据时的提示
    if ([_activityList count] == 0) {

            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
            if ([status isEqualToString:STATUS_SUCCESS]) {
                [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
            } else {
                [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
            }
        } else {
            [self removeNoDataView];

     }

//        self.tipsBackgroundImageView.hidden = NO;
//        if ([status isEqualToString:STATUS_SUCCESS]) {
//            [self.tipsBackgroundImageView setImage:[SportImage noDataPageImage]];
//        } else {
//            [self.tipsBackgroundImageView setImage:[SportImage networkErrorPageImage]];
//        }
//    } else {
//        self.tipsBackgroundImageView.hidden = YES;
//    }
}

- (void)didQueryUserList:(NSArray *)userList status:(NSString *)status page:(int)page
{
    [SportProgressView dismiss];
    _isLoadingMoreUser = NO;
    
    if (_peoplePage == 1) {
        self.peopleList = [NSMutableArray arrayWithArray:userList];
    } else {
        [self.peopleList addObjectsFromArray:userList];
    }
    
    if ([userList count] < COUNT_ONE_PAGE) {
        _hasMoreUser = NO;
        self.peopleTableView.tableFooterView.hidden = YES;
    } else {
        _hasMoreUser = YES;
        self.peopleTableView.tableFooterView.hidden = NO;
    }
    
    [self.peopleTableView reloadData];
    if (_peoplePage == 1 && [_peopleList count] > 0) {
        [self.peopleTableView  scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    
    //无数据时的提示
    if ([_peopleList count] == 0 && _listType == ListTypePeople) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
        
    }
//        self.tipsBackgroundImageView.hidden = NO;
//        if ([status isEqualToString:STATUS_SUCCESS]) {
//            [self.tipsBackgroundImageView setImage:[SportImage noDataPageImage]];
//        } else {
//            [self.tipsBackgroundImageView setImage:[SportImage networkErrorPageImage]];
//        }
//    } else {
//        self.tipsBackgroundImageView.hidden = YES;
//    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_listType == ListTypeActivity) {
        return [_activityList count];
    } else {
        return [_peopleList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _activityTableView) {
        NSString *identifier = [ActivityCell getCellIdentifier];
        ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [ActivityCell createCell];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        Activity *activity = nil;
        if ([_activityList count] > indexPath.row) {
            activity = [_activityList objectAtIndex:indexPath.row];
        }
        
        [cell updateCell:indexPath activity:activity];
        return cell;
    } else {
        NSString *identifier = [UserCell getCellIdentifier];
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [UserCell createCell];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        User *user = nil;
        if ([_peopleList count] > indexPath.row) {
            user = [_peopleList objectAtIndex:indexPath.row];
        }
        
        [cell updateCellWithUser:user];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_listType == ListTypeActivity) {
        return [ActivityCell getCellHeight];
    } else {
        return [UserCell getCellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _activityTableView) {
        return _activityFilterHolderView.frame.size.height;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _activityTableView) {
        return _activityFilterHolderView;
    } else {
        return [[UIView alloc] initWithFrame:CGRectZero] ;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _peopleTableView) {
        User *user = [_peopleList objectAtIndex:indexPath.row];
        UserInfoController *controller = [[UserInfoController alloc] initWithUserId:user.userId];
      
        [self.navigationController pushViewController:controller animated:YES];
    }
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_listType == ListTypeActivity) {
        static float newOffsetY = 0;
//        static float oldOffsetY = 0;
        newOffsetY = scrollView.contentOffset.y;
//        if (newOffsetY != oldOffsetY ) {
//            if (newOffsetY > oldOffsetY) {//向上
//                self.activityHeaderHolderView.hidden = YES;
//            }else if(newOffsetY < oldOffsetY){//向上
//                self.activityHeaderHolderView.hidden = NO;
//            }
//            oldOffsetY = newOffsetY;
//        }
//        
//        if (newOffsetY >= _activityTableView.contentSize.height - _activityTableView.frame.size.height) {
//            self.activityHeaderHolderView.hidden = YES;
//        }
//        
//        if (newOffsetY < _activityHeaderHolderView.frame.size.height) {
//            self.activityHeaderHolderView.hidden = NO;
//        }
        
//            HDLog(@"offset:%f", newOffsetY);
//            HDLog(@"content height:%f", _activityTableView.contentSize.height);
//            HDLog(@"table height:%f", _activityTableView.frame.size.height);
        
        //show load more
        if (newOffsetY >= _activityTableView.contentSize.height - _activityTableView.frame.size.height - 32) {
            [self loadMoreActivityData];
        }
    } else if (_listType == ListTypePeople) {
        float peoleTableOffsetY = scrollView.contentOffset.y;
        if (peoleTableOffsetY >= _peopleTableView.contentSize.height - _peopleTableView.frame.size.height - 32) {
            [self loadMorePeopleData];
        }
    }
}

- (void)loadMoreActivityData
{
    if (_isLoadingMoreActivity == NO
        && _hasMoreActivity) {
        _isLoadingMoreActivity = YES;
        _activityPage ++;
        [self queryActivityData];
    }
}

- (void)loadMorePeopleData
{
    if (_isLoadingMoreUser == NO
        && _hasMoreUser) {
        _isLoadingMoreUser = YES;
        _peoplePage ++;
        [self queryUserData];
    }
}

- (void)didClickActivityCell:(NSIndexPath *)indexPath
{
    Activity *activity = [_activityList objectAtIndex:indexPath.row];
    ActivityDetailController *controller = [[ActivityDetailController alloc] initWithActivityId:activity.activityId];
      [self.navigationController pushViewController:controller animated:YES];
}

-(void)didClickActivityCellAvatarButton:(NSIndexPath *)indexPath
{
    Activity *activity = [_activityList objectAtIndex:indexPath.row];
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:activity.userId];
   
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickManageActivityButton:(id)sender {

    if ([UserManager isLogin]) {
        ManageActivityController *controller = [[ManageActivityController alloc] init];
      
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
       
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)clickCreateActivityButton:(id)sender {
    if ([UserManager isLogin]) {
        CreateActivityController *controller = [[CreateActivityController alloc] init];
        controller.delegate = self;
      
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        LoginController *controller = [[LoginController alloc] init];
      
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didCreateActivitySuccess
{
    [self queryActivityDataNoProgressView];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发布成功!" message:@"点击左上角\"活动管理\"查看或接受他人的参与请求" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

#define TAG_PICKER_AC_CATEGORY  2014042901
#define TAG_PICKER_AC_THEME     2014042902
#define TAG_PICKER_AC_SORT      2014042903

#define TAG_PICKER_PEOPLE_CATEGORY      2014050401
#define TAG_PICKER_PEOPLE_GENDER        2014050402
#define TAG_PICKER_PEOPLE_SORT          2014050403

- (IBAction)clickActivityCategoryFilterButton:(id)sender {
    NSMutableArray *nameList = [NSMutableArray array];
    [nameList addObject:@"全部"];
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        [nameList addObject:pro.proName];
    }
    
    SportPickerController *controller = [[SportPickerController alloc]init];
    controller.dataPickerView.tag = TAG_PICKER_AC_CATEGORY;
    controller.dataList = nameList;
    controller.delegate = self;
    
    [self presentViewController:controller animated:YES completion:nil];
    
//    SportPickerView *view = [SportPickerView createSportPickerView];
//    view.tag = TAG_PICKER_AC_CATEGORY;
//    view.delegate = self;
//    view.dataList = nameList;
//    [view show];
}

- (IBAction)clickActivityThemeFilterButton:(id)sender {
    NSDictionary *dic = [[ActivityManager defaultManager] themeDictionary];
    NSArray *keys = [dic allKeys];
    NSArray *sortKeys = [keys sortedArrayWithOptions:NSSortStable
                                     usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                         NSString *item1 = (NSString *)obj1;
                                         NSString *item2 = (NSString *)obj2;
                                         return [item1 compare:item2];
                                     }];
    NSMutableArray *themeNameList = [NSMutableArray array];
    [themeNameList addObject:@"全部"];
    for (NSString *key in sortKeys) {
        [themeNameList addObject:[dic objectForKey:key]];
    }
    
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_AC_THEME;
    view.delegate = self;
    view.dataList = themeNameList;
    [view show];
}

- (IBAction)clickActivitySortFilterButton:(id)sender {
    NSDictionary *dic = [[ActivityManager defaultManager] activitySortDictionary];
    NSArray *keys = [dic allKeys];
    NSArray *sortKeys = [keys sortedArrayWithOptions:NSSortStable
                                     usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                         NSString *item1 = (NSString *)obj1;
                                         NSString *item2 = (NSString *)obj2;
                                         return [item1 compare:item2];
                                     }];
    NSMutableArray *sortNameList = [NSMutableArray array];
    for (NSString *key in sortKeys) {
        [sortNameList addObject:[dic objectForKey:key]];
    }
    
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_AC_SORT;
    view.delegate = self;
    view.dataList = sortNameList;
    [view show];
}

- (void)didClickSportPickerViewOKButton:(UIPickerView *)sportPickerView row:(NSInteger)row
{
    if (sportPickerView.tag == TAG_PICKER_AC_CATEGORY) {
        if (row == 0) {
            self.selectedActivityProId = nil;
            [self.activityCategoryFilterButton setTitle:@"全部" forState:UIControlStateNormal];
        } else {
            CircleProject *pro =  [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:row - 1];
            self.selectedActivityProId = pro.proId;
            [self.activityCategoryFilterButton setTitle:pro.proName forState:UIControlStateNormal];
        }
        
        _activityPage = 1;
        [self queryActivityData];
    }
    
    if (sportPickerView.tag == TAG_PICKER_AC_THEME) {
        self.selectedActivityThemeId = row - 1;
        
        [self.activityThemeFilterButton setTitle:[Activity themeName:_selectedActivityThemeId] forState:UIControlStateNormal];
        
        _activityPage = 1;
        [self queryActivityData];
    }
    
    if (sportPickerView.tag == TAG_PICKER_AC_SORT) {
        self.selectedActivitySortId = row;
        
        NSDictionary *dic = [[ActivityManager defaultManager] activitySortDictionary];
        NSString *buttonTitle = [dic objectForKey:[@(_selectedActivitySortId) stringValue]];
        [self.activitySortFilterButton setTitle:buttonTitle forState:UIControlStateNormal];
        
        _activityPage = 1;
        [self queryActivityData];
    }
    
    if (sportPickerView.tag == TAG_PICKER_PEOPLE_GENDER) {
        NSString *buttonTitle = nil;
        if (row == 0) {
            self.selectedPeopleGender = nil;
            buttonTitle = @"不限";
        } else if (row == 1) {
            self.selectedPeopleGender = @"m";
            buttonTitle = @"男";
        } else if (row == 2) {
            self.selectedPeopleGender = @"f";
            buttonTitle = @"女";
        }
        [self.peopleGenderFilterButton setTitle:buttonTitle forState:UIControlStateNormal];
        
        _peoplePage = 1;
        [self queryUserData];
    }
    
    if (sportPickerView.tag == TAG_PICKER_PEOPLE_CATEGORY) {
        if (row == 0) {
            self.selectedPeopleProId = nil;
            [self.peopleCategoryFilterButton setTitle:@"全部" forState:UIControlStateNormal];
        } else {
            CircleProject *pro =  [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:row - 1];
            self.selectedPeopleProId = pro.proId;
            [self.peopleCategoryFilterButton setTitle:pro.proName forState:UIControlStateNormal];
        }
        
        _peoplePage = 1;
        [self queryUserData];
    }
}

- (IBAction)clickPeopleGenderFilterButton:(id)sender {
    NSArray *genderList = [NSArray arrayWithObjects:@"不限", @"男", @"女", nil];
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_PEOPLE_GENDER;
    view.delegate = self;
    view.dataList = genderList;
    [view show];
}

- (IBAction)clickPeopleCategoryFilterButton:(id)sender {
    NSMutableArray *nameList = [NSMutableArray array];
    [nameList addObject:@"全部"];
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        [nameList addObject:pro.proName];
    }
    
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_PEOPLE_CATEGORY;
    view.delegate = self;
    view.dataList = nameList;
    [view show];
}

- (void)checkUserInfoFinish
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] == 0 ||
        [user.avatarUrl length] == 0 ||
        [user.nickname length] == 0 ||
        user.age == 0 ||
        [user.gender length] == 0 ||
        [user.cityName length] == 0 ||
        [user.signture length] == 0 ||
        [user.sportPlan length] == 0 ||
        [user.likeSport length] == 0
        ) {
        self.updateUserInfoTipsHolderView.hidden = NO;
        
        if ([user.userId length] == 0) {
            [self.updateUserInfoButton setTitle:@"马上注册" forState:UIControlStateNormal];
            self.updateUserInfoTipsLabel.text = @"注册即可查看其他用户发布的活动!";
        } else {
            [self.updateUserInfoButton setTitle:@"完善个人资料" forState:UIControlStateNormal];
            self.updateUserInfoTipsLabel.text = @"完善个人资料即可查看其他用户发布的活动!";
        }
        
        [self.updateUserInfoGrayBackgroundImageView setImage:[SportImage grayBackgroundRoundImage]];
        [self.updateUserInfoButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
        
    } else {
        self.updateUserInfoTipsHolderView.hidden = YES;
    }
}

- (IBAction)clickUpdateUserInfoButton:(id)sender {
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    if ([user.userId length] == 0) {
        LoginController *controller = [[LoginController alloc] init];
       
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        EditUserInfoController *controller = [[EditUserInfoController alloc] initWithUser:user levelTitle:user.rulesTitle];
      
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    if (_listType == ListTypeActivity) {
        _activityPage = 1;
        [self queryActivityData];
    } else if (_listType == ListTypePeople) {
        _peoplePage = 1;
        [self queryUserData];
    }
}

@end
