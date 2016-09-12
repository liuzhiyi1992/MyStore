//
//  ActivityListController.m
//  Sport
//
//  Created by haodong  on 15/5/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ActivityListController.h"
#import "ActivityDetailController.h"
#import "UserInfoController.h"
#import "CircleProjectManager.h"
#import "ActivityManager.h"
#import "UserManager.h"
#import "UIScrollView+SportRefresh.h"
#import "LoginController.h"
#import "ManageActivityController.h"
#import "UIView+Utils.h"
#import "SportProgressView.h"

@interface ActivityListController ()

@property (strong, nonatomic) NSMutableArray *activityList;
@property (assign, nonatomic) int finishPage;
@property (copy, nonatomic) NSString *selectedActivityProId;    //运动项目id
@property (assign, nonatomic) NSInteger selectedActivityThemeId;  //主题id
@property (assign, nonatomic) NSInteger selectedActivitySortId;   //排序id

@property (strong, nonatomic) NSArray *nameList;
@property (strong, nonatomic) NSArray *themeNameList;

@property (strong, nonatomic) NSArray *sortNameList;
@property (assign, nonatomic) CGFloat downy;

@property (strong, nonatomic)  SportFilterListView *sview;


@property (weak, nonatomic) IBOutlet UITableView *activityTableView;
@property (strong, nonatomic) IBOutlet UIView *activityFilterHolderView;
@property (weak, nonatomic) IBOutlet UIButton *activityCategoryFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *activityThemeFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *activitySortFilterButton;
@property (weak, nonatomic) IBOutlet UIImageView *filterBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *manageActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *createActivityButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UIImageView *actLine;

@end

@implementation ActivityListController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"活动";
 
    
    [self initButtons];
    
  //  self.activityTableView.showsVerticalScrollIndicator=NO;

    [self.activityTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.activityTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    
    [self.activityTableView beginReload];
}
#define COLOR_NORMAL    [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1]
#define COLOR_SELECTED  [SportColor defaultColor]
- (void)initButtons
{
    self.filterBackgroundImageView.image = [SportImage activityFilterImage];
    [self.manageActivityButton setBackgroundImage:[SportColor createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//    [self.manageActivityButton setBackgroundImage:[SportImage manageActivityButtonSelectedImage] forState:UIControlStateHighlighted];
    
    self.manageActivityButton.highlighted=NO;
    
    [self.manageActivityButton setAdjustsImageWhenHighlighted:NO];
    [self.createActivityButton setBackgroundImage:[SportColor createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//    [self.createActivityButton setBackgroundImage:[SportImage createActivityButtonSelectedImage] forState:UIControlStateHighlighted];
    self.createActivityButton.highlighted=NO;
    
    [self.createActivityButton setAdjustsImageWhenHighlighted:NO];
    
    [self.activityCategoryFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
    [self.activityCategoryFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    [self.activityCategoryFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.activityCategoryFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
    
    self.activityCategoryFilterButton.highlighted=NO;
    [self.activityCategoryFilterButton setAdjustsImageWhenHighlighted:NO];
    
    
    [self.activityThemeFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
    [self.activityThemeFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    [self.activityThemeFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.activityThemeFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
    self.activityThemeFilterButton.highlighted=NO;
    [self.activityThemeFilterButton setAdjustsImageWhenHighlighted:NO];
    
    
    [self.activitySortFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
    [self.activitySortFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    [self.activitySortFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.activitySortFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
    self.activitySortFilterButton.highlighted=NO;
    [self.activitySortFilterButton setAdjustsImageWhenHighlighted:NO];

    [self.lineImage setImage:[SportImage lineImage]];
    [self.actLine setImage:[SportImage lineImage]];
   
}

- (void)loadNewData
{
    self.finishPage = 0;
    [self queryActivityData];
}

- (void)loadMoreData
{
    [self queryActivityData];
}

#define COUNT_ONE_PAGE 20
- (void)queryActivityData
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
                                  page:_finishPage + 1
                                 count:COUNT_ONE_PAGE];
}

- (void)didQueryActivityList:(NSArray *)list status:(NSString *)status type:(ActivityListType)type page:(int)page
{
    [SportProgressView dismiss];
    [self.activityTableView endLoad];
    
    if (page == 1) {
        self.activityList = [NSMutableArray arrayWithArray:list];
    } else {
        [self.activityList addObjectsFromArray:list];
    }
    self.finishPage = page;
    
    if ([list count] < COUNT_ONE_PAGE) {
        [self.activityTableView canNotLoadMore];
    } else {
        [self.activityTableView canLoadMore];
    }
    
    [self.activityTableView reloadData];
    
    //无数据时的提示
    if ([_activityList count] == 0) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            CGRect frame = CGRectMake(0, 110, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 110);
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [self queryActivityData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_activityList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ActivityCell getCellIdentifier];
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [ActivityCell createCell];
        cell.delegate = self;
    }
    Activity *activity = nil;
    if ([_activityList count] > indexPath.row) {
        activity = [_activityList objectAtIndex:indexPath.row];
    }
    [cell updateCell:indexPath activity:activity];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ActivityCell getCellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _activityFilterHolderView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _activityFilterHolderView;
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



#define TAG_PICKER_AC_CATEGORY  2014042901
#define TAG_PICKER_AC_THEME     2014042902
#define TAG_PICKER_AC_SORT      2014042903
- (IBAction)clickActivityCategoryFilterButton:(id)sender {
   // self.activityTableView.scrollEnabled=!self.activityTableView.scrollEnabled;
    
     _activityCategoryFilterButton.selected = !_activityCategoryFilterButton.selected;
    NSMutableArray *nameList = [NSMutableArray array];
    [nameList addObject:@"全部"];
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        [nameList addObject:pro.proName];
    }
    self.nameList=nameList;
  
    if ([SportFilterListView hideInView:self.view tag:TAG_PICKER_AC_CATEGORY]) {
        return;
    }
    
    //设置待选列表
   
    int selectedRow = 0;

    int index = 0;
    for (NSString *one in  self.nameList) {
        if ([self.activityCategoryFilterButton.currentTitle isEqualToString:one]) {
            selectedRow = index;
        }
        index ++;
    }
    //显示
    
    
    CGFloat offy=0;
    if (self.downy<68) {
        offy=110-self.downy;
    }else{
        
        offy=42;
    }

   [SportFilterListView showInView:self.view
                                  y:offy
                                tag:TAG_PICKER_AC_CATEGORY
                           dataList:nameList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_activityCategoryFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];
    

}

- (IBAction)clickActivityThemeFilterButton:(id)sender {
     _activityThemeFilterButton.selected = !_activityThemeFilterButton.selected;
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
    
    self.themeNameList=themeNameList;

    if ([SportFilterListView hideInView:self.view tag:TAG_PICKER_AC_THEME]) {
        return;
    }
    
    //设置待选列表
   
    int selectedRow = 0;
    int index = 0;
        for (NSString *one in  self.themeNameList) {
            if ([self.activityThemeFilterButton.currentTitle isEqualToString:one]) {
                selectedRow = index;
            }
            index ++;
        }
 
    //显示
    
    CGFloat offy=0;
    if (self.downy<68) {
        offy=110-self.downy;
    }else{
    
        offy=42;
    }

    [SportFilterListView showInView:self.view
                                  y: offy
                                tag:TAG_PICKER_AC_THEME
                           dataList:themeNameList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_activityThemeFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];
    
}

- (IBAction)clickActivitySortFilterButton:(id)sender {
     _activitySortFilterButton.selected = !_activitySortFilterButton.selected;
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
    self.sortNameList=sortNameList;

    if ([SportFilterListView hideInView:self.view tag:TAG_PICKER_AC_SORT]) {
        return;
    }
 
    int selectedRow = 0;
    int index = 0;
    for (NSString *one in  self.sortNameList) {
        if ([self.activitySortFilterButton.currentTitle isEqualToString:one]) {
            selectedRow = index;
        }
        index ++;
    }
    //显示
    
    CGFloat offy=0;
    if (self.downy<68) {
        offy=110-self.downy;
    }else{
        
        offy=42;
    }

    [SportFilterListView showInView:self.view
                                  y:offy
                                tag:TAG_PICKER_AC_SORT
                           dataList:sortNameList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_activitySortFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];

}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    self.downy=scrollView.contentOffset.y;

    
    CGFloat offy=0;
    if (self.downy<68) {
        offy=110-self.downy;
    }else{
        
        offy=42;
    }
    
 
    
    UIView *v=[self.view.subviews lastObject];
    
    if ([v isKindOfClass:[SportFilterListView class]]) {
        v.frame=CGRectMake(0, offy, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
        
      
    }

    


}

- (void)didSelectSportFilterListView:(SportFilterListView *)sportFilterListView indexPath:(NSIndexPath *)indexPath
{
    if (sportFilterListView.tag == TAG_PICKER_AC_CATEGORY) {
        
        [self.activityCategoryFilterButton setTitle:[self.nameList objectAtIndex:indexPath.row] forState:UIControlStateNormal];
   
        
        if (indexPath.row == 0) {
                        self.selectedActivityProId = nil;
                        [self.activityCategoryFilterButton setTitle:@"全部" forState:UIControlStateNormal];
                    } else {
                        CircleProject *pro =  [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:indexPath.row - 1];
                        self.selectedActivityProId = pro.proId;
                        [self.activityCategoryFilterButton setTitle:pro.proName forState:UIControlStateNormal];
           
                    }
                    
                    _finishPage = 0;
                    [self queryActivityData];
        

        
        [MobClickUtils event:umeng_event_click_coach_list_categories label:[self.nameList objectAtIndex:indexPath.row]];
        
    } else if (sportFilterListView.tag == TAG_PICKER_AC_THEME) {
        
        [self.activityThemeFilterButton setTitle:[self.themeNameList objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        [MobClickUtils event:umeng_event_click_coach_list_sex label:[self.themeNameList objectAtIndex:indexPath.row]];
       
        
        self.selectedActivityThemeId = indexPath.row - 1;
        
                               _finishPage = 0;
                [self queryActivityData];
        
    
        
    } else if (sportFilterListView.tag == TAG_PICKER_AC_SORT) {
       
         [self.activitySortFilterButton setTitle:[self.sortNameList objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        [MobClickUtils event:umeng_event_click_coach_list_sort label:[self.sortNameList objectAtIndex:indexPath.row]];
            self.selectedActivitySortId = indexPath.row;
        
                NSDictionary *dic = [[ActivityManager defaultManager] activitySortDictionary];
                NSString *buttonTitle = [dic objectForKey:[@(_selectedActivitySortId) stringValue]];
                [self.activitySortFilterButton setTitle:buttonTitle forState:UIControlStateNormal];
        
                _finishPage = 0;
                [self queryActivityData];
        
        
           }
 
}


//- (void)didClickSportPickerViewOKButton:(SportFilterListView *)sportPickerView row:(NSInteger)row
//{
//    if (sportPickerView.tag == TAG_PICKER_AC_CATEGORY) {
//        if (row == 0) {
//            self.selectedActivityProId = nil;
//            [self.activityCategoryFilterButton setTitle:@"全部" forState:UIControlStateNormal];
//        } else {
//            CircleProject *pro =  [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:row - 1];
//            self.selectedActivityProId = pro.proId;
//            [self.activityCategoryFilterButton setTitle:pro.proName forState:UIControlStateNormal];
//        }
//        
//        _finishPage = 0;
//        [self queryActivityData];
//    }
//    
//    if (sportPickerView.tag == TAG_PICKER_AC_THEME) {
//        self.selectedActivityThemeId = row - 1;
//        
//        [self.activityThemeFilterButton setTitle:[Activity themeName:_selectedActivityThemeId] forState:UIControlStateNormal];
//        
//        _finishPage = 0;
//        [self queryActivityData];
//    }
//    
//    if (sportPickerView.tag == TAG_PICKER_AC_SORT) {
//        self.selectedActivitySortId = row;
//        
//        NSDictionary *dic = [[ActivityManager defaultManager] activitySortDictionary];
//        NSString *buttonTitle = [dic objectForKey:[@(_selectedActivitySortId) stringValue]];
//        [self.activitySortFilterButton setTitle:buttonTitle forState:UIControlStateNormal];
//        
//        _finishPage = 0;
//        [self queryActivityData];
//    }
//}
//
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
        CreateActivityController *controller = [[CreateActivityController alloc] init] ;
        controller.delegate = self;
     
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
      
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didCreateActivitySuccess
{
    [self queryActivityData];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发布成功!" message:@"点击左上角\"活动管理\"查看或接受他人的参与请求" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

@end
