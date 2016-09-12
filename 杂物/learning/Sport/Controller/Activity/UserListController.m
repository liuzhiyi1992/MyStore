//
//  UserListController.m
//  Sport
//
//  Created by haodong  on 15/5/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UserListController.h"
#import "UserCell.h"
#import "UserInfoController.h"
#import "User.h"
#import "UIScrollView+SportRefresh.h"
#import "UserManager.h"
#import "CircleProjectManager.h"
#import "SportPopupView.h"
#import "SportProgressView.h"

@interface UserListController ()
@property (strong, nonatomic) NSMutableArray *peopleList;
@property (assign, nonatomic) int finishPage;
@property (copy, nonatomic) NSString *selectedPeopleProId;    //运动项目id
@property (copy, nonatomic) NSString *selectedPeopleGender;   //性别
//@property (strong, nonatomic) NSArray *genderList;

//@property (strong, nonatomic) NSArray *peopleCategoryList;
@property (weak, nonatomic) IBOutlet UITableView *peopleTableView;
@property (weak, nonatomic) IBOutlet UIButton *peopleGenderFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *peopleCategoryFilterButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;

@end

@implementation UserListController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"附近的人";
    [self initButtons];
    [self.peopleTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.peopleTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    
    [self.peopleTableView beginReload];
}
#define COLOR_NORMAL    [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1]
#define COLOR_SELECTED  [SportColor defaultColor]
- (void)initButtons
{
    [self.peopleGenderFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
    [self.peopleGenderFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    [self.peopleGenderFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.peopleGenderFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
    
    self.peopleGenderFilterButton.highlighted=NO;
    [self.peopleGenderFilterButton setAdjustsImageWhenHighlighted:NO];
    
    
    [self.peopleCategoryFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
    [self.peopleCategoryFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    [self.peopleCategoryFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.peopleCategoryFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
    self.peopleCategoryFilterButton.highlighted=NO;
    [self.peopleCategoryFilterButton setAdjustsImageWhenHighlighted:NO];
    
    
   [self.lineImage setImage:[SportImage lineImage]];
}



- (void)loadNewData
{
    self.finishPage = 0;
    [self queryUserData];
}

- (void)loadMoreData
{
    [self queryUserData];
}

#define COUNT_ONE_PAGE 20
- (void)queryUserData
{
    double latitude = [[UserManager defaultManager] readUserLocation].coordinate.latitude;
    double longitude = [[UserManager defaultManager] readUserLocation].coordinate.longitude;
    [ActivityService queryUserList:self
                          latitude:latitude //23.8
                         longitude:longitude //113.17
                            gender:_selectedPeopleGender
                             proId:_selectedPeopleProId
                              sort:nil
                              page:_finishPage + 1
                             count:COUNT_ONE_PAGE];
}

- (void)didQueryUserList:(NSArray *)userList status:(NSString *)status page:(int)page
{
    
    [SportProgressView dismiss];
    [self.peopleTableView endLoad];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.finishPage = page;
        if (page == 1) {
            self.peopleList = [NSMutableArray arrayWithArray:userList];
        } else {
            [self.peopleList addObjectsFromArray:userList];
        }
    }else{
    }
    
    if ([userList count] < COUNT_ONE_PAGE) {
        [self.peopleTableView canNotLoadMore];
    } else {
        [self.peopleTableView canLoadMore];
    }
    
    [self.peopleTableView reloadData];
    
    //无数据时的提示
    if ([_peopleList count] == 0) {
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            CGRect frame = CGRectMake(0, 45, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 45);
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
    [SportProgressView showWithStatus:@"加载中"];
    [self queryUserData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peopleList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [UserCell getCellIdentifier];
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [UserCell createCell];
    }
    User *user = nil;
    if ([_peopleList count] > indexPath.row) {
        user = [_peopleList objectAtIndex:indexPath.row];
    }
    [cell updateCellWithUser:user];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UserCell getCellHeight];
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

#define TAG_PICKER_PEOPLE_CATEGORY      2014050401
#define TAG_PICKER_PEOPLE_GENDER        2014050402
- (IBAction)clickPeopleGenderFilterButton:(id)sender {
    
    
     _peopleGenderFilterButton.selected = !_peopleGenderFilterButton.selected;
    NSArray *genderList = [NSArray arrayWithObjects:@"不限", @"男", @"女", nil];


    if ([SportFilterListView hideInView:self.view tag:TAG_PICKER_PEOPLE_GENDER]) {
        return;
    }
    
    //设置待选列表
    
    int selectedRow = 0;
    int index = 0;
    for (NSString *one in  genderList) {
        if ([self.peopleGenderFilterButton.currentTitle isEqualToString:one]) {
            selectedRow = index;
        }
        index ++;
    }
    
    //显示
    
    [SportFilterListView showInView:self.view
                                  y:45
                                tag:TAG_PICKER_PEOPLE_GENDER
                           dataList:genderList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_peopleGenderFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];
    
    
}

- (IBAction)clickPeopleCategoryFilterButton:(id)sender {
    NSMutableArray *nameList = [NSMutableArray array];
    [nameList addObject:@"全部"];
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        [nameList addObject:pro.proName];
    }

    
    if ([SportFilterListView hideInView:self.view tag:TAG_PICKER_PEOPLE_CATEGORY]) {
        return;
    }
    
    //设置待选列表
    
    int selectedRow = 0;
    int index = 0;
    for (NSString *one in nameList) {
        if ([self.peopleCategoryFilterButton.currentTitle isEqualToString:one]) {
            selectedRow = index;
        }
        index ++;
    }
    
    //显示
    
    [SportFilterListView showInView:self.view
                                  y: 45
                                tag:TAG_PICKER_PEOPLE_CATEGORY
                           dataList:nameList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_peopleCategoryFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];
    

}



- (void)didSelectSportFilterListView:(SportFilterListView *)sportFilterListView indexPath:(NSIndexPath *)indexPath
{

    if (sportFilterListView.tag == TAG_PICKER_PEOPLE_GENDER) {
        NSString *buttonTitle = nil;
        if (indexPath.row == 0) {
            self.selectedPeopleGender = nil;
            buttonTitle = @"不限";
        } else if (indexPath.row == 1) {
            self.selectedPeopleGender = @"m";
            buttonTitle = @"男";
        } else if (indexPath.row == 2) {
            self.selectedPeopleGender = @"f";
            buttonTitle = @"女";
        }
        [self.peopleGenderFilterButton setTitle:buttonTitle forState:UIControlStateNormal];
        
        _finishPage = 0;
        [self queryUserData];
    }
    
    if (sportFilterListView.tag == TAG_PICKER_PEOPLE_CATEGORY) {
        if (indexPath.row == 0) {
            self.selectedPeopleProId = nil;
            [self.peopleCategoryFilterButton setTitle:@"全部" forState:UIControlStateNormal];
        } else {
            CircleProject *pro =  [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:indexPath.row - 1];
            self.selectedPeopleProId = pro.proId;
            [self.peopleCategoryFilterButton setTitle:pro.proName forState:UIControlStateNormal];
        }
        
        _finishPage = 0;
        [self queryUserData];
    }

}



//- (void)didClickSportPickerViewOKButton:(SportPickerView *)sportPickerView row:(NSInteger)row
//{
//    if (sportPickerView.tag == TAG_PICKER_PEOPLE_GENDER) {
//        NSString *buttonTitle = nil;
//        if (row == 0) {
//            self.selectedPeopleGender = nil;
//            buttonTitle = @"不限";
//        } else if (row == 1) {
//            self.selectedPeopleGender = @"m";
//            buttonTitle = @"男";
//        } else if (row == 2) {
//            self.selectedPeopleGender = @"f";
//            buttonTitle = @"女";
//        }
//        [self.peopleGenderFilterButton setTitle:buttonTitle forState:UIControlStateNormal];
//        
//        _finishPage = 0;
//        [self queryUserData];
//    }
//    
//    if (sportPickerView.tag == TAG_PICKER_PEOPLE_CATEGORY) {
//        if (row == 0) {
//            self.selectedPeopleProId = nil;
//            [self.peopleCategoryFilterButton setTitle:@"全部" forState:UIControlStateNormal];
//        } else {
//            CircleProject *pro =  [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:row - 1];
//            self.selectedPeopleProId = pro.proId;
//            [self.peopleCategoryFilterButton setTitle:pro.proName forState:UIControlStateNormal];
//        }
//        
//        _finishPage = 0;
//        [self queryUserData];
//    }
//}

@end
