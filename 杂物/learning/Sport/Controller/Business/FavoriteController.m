//
//  FavoriteController.m
//  Sport
//
//  Created by haodong  on 13-8-21.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "FavoriteController.h"
#import "BusinessListCell.h"
#import "Business.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "BusinessDetailController.h"
#import "SportNavigationController.h"
#import "DeviceDetection.h"
#import "UIView+Utils.h"
#import "CoachCollectionCell.h"
#import "SearchResultCell.h"
#import "CoachIntroductionController.h"
#import "Coach.h"


@interface FavoriteController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) UIButton *deleteButton;
@end

@implementation FavoriteController


- (void)viewDidUnload {
    [self setDataTableView:nil];
    [self setDeleteButton:nil];
    [super viewDidUnload];
}

- (void)clickBackButton:(id)sender
{
    //[(SportNavigationController *)self.navigationController setCanDragBack:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self queryData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kMyCollection");
    
    [self createTitleViewWithleftButtonTitle:@"收藏场馆" rightButtonTitle:@"收藏陪练"];
    self.noDataTipsLabel = [self createNoDataTipsLabel];
    self.noDataTipsLabel.text = @"暂时没有收藏";
    [self.dataTableView addSubview:self.noDataTipsLabel];
    self.noDataTipsLabel.hidden = YES;
    [self selectedLeftButton];
}
- (void)selectedLeftButton
{
    [super selectedLeftButton];
    [self queryData];
}

- (void)selectedRightButton
{
    [super selectedRightButton];
    [self queryData];
}

- (void)queryData
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:DDTF(@"kLoading")];
    self.navigationItem.titleView.userInteractionEnabled = NO;
    if(self.leftTitleButton.selected == YES) {//场馆
        [BusinessService queryFavoriteBusinessList:self
                                            userId:user.userId];
    }else{
        [CoachService queryFavoriteCoachList:self userId:user.userId];
    }
    
}

//- (void)initNavigationSegmentView {
//    [self.navigationSegmentView updateWidth:150];
//    [self.navigationItem setTitleView:self.navigationSegmentView];
//    
//    [self.topSegmentedControl addTarget:self action:@selector(segmentChange) forControlEvents:UIControlEventValueChanged];
//}

- (void)clickDeleteButton:(id)sender
{
    BOOL editing = !self.dataTableView.editing;
    [self.dataTableView setEditing:editing animated:YES];
    if (editing) {
        [_deleteButton setTitle:@"完成" forState:UIControlStateNormal];
        //[_deleteButton setImage:[SportImage markButtonImage] forState:UIControlStateNormal];
    } else {
        [_deleteButton setTitle:@"管理" forState:UIControlStateNormal];
        //[_deleteButton setImage:[SportImage manageButtonImage] forState:UIControlStateNormal];
    }
}

- (void)didQueryFavoriteBusinessList:(NSArray *)businessList status:(NSString *)status
{
    self.navigationItem.titleView.userInteractionEnabled = YES;
    [self analyseFavoriteListWithList:businessList status:status noDataTips:@"您没有收藏的场馆哦"];
}


- (void)didQueryFavoriteCoachList:(NSString *)status msg:(NSString *)msg coachList:(NSArray *)coachList {
    
    self.navigationItem.titleView.userInteractionEnabled = YES;
    [self analyseFavoriteListWithList:coachList status:status noDataTips:@"您没有收藏的陪练哦"];
    
}

- (void)analyseFavoriteListWithList:(NSArray *)array status:(NSString *)status noDataTips:(NSString *)tips {
    
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.dataList = [NSMutableArray arrayWithArray:array];
        if ([_dataList count] == 0) {
            self.noDataTipsLabel.hidden = NO;
        } else {
            self.noDataTipsLabel.hidden = YES;
        }
        [self.dataTableView reloadData];
    }
    
    //无数据时的提示
    if ([array count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:tips];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (void)didRemoveFavoriteBusiness:(NSString *)status
{
    //[SportProgressView dismiss];
}


- (void)didUserCollectionCoach:(NSString *)status msg:(NSString *)msg {
    //[SportProgressView dismiss];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //场馆
    if(self.leftTitleButton.selected) {
        NSString *identifier = [SearchResultCell getCellIdentifier];
        
        SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [SearchResultCell createCell];
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        BOOL isLast = (indexPath.row == [_dataList count] - 1);
        Business *business = [_dataList objectAtIndex:indexPath.row];
        [cell updateCell:business indexPath:indexPath isLast:isLast isShowCategory:NO searchText:nil];
        
        return cell;
        
    }else {//约练
        NSString *identifier = [CoachCollectionCell getCellIdentifier];
        
        CoachCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if(nil == cell) {
            cell = [CoachCollectionCell createCell];
        }
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        [cell updateCellWithCoach:self.dataList[indexPath.row]];
        
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.leftTitleButton.selected){
        Business *business = [_dataList objectAtIndex:indexPath.row];
        if (business.neighborhood.length > 0) {
            return 100;
        }else{
            return 75;
        }
    }else{
        return [SearchResultCell getCellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.leftTitleButton.selected) {
        Business *business = [_dataList objectAtIndex:indexPath.row];
        NSString *defaultCategoryId = business.defaultCategoryId;
        BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusiness:business categoryId:defaultCategoryId] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if(self.rightTitleButton.selected) {
        Coach *coach = [_dataList objectAtIndex:indexPath.row];
        CoachIntroductionController *con = [[CoachIntroductionController alloc] initWithCoachId:coach.coachId];
        [self.navigationController pushViewController:con animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    //删除场馆收藏
    if(self.leftTitleButton.selected) {
        Business *business = [_dataList objectAtIndex:indexPath.row];
        [BusinessService removeFavoriteBusiness:self
                                     businessId:business.businessId
                                     categoryId:business.defaultCategoryId
                                         userId:user.userId];
        
        [self.dataList removeObjectAtIndex:indexPath.row];
        [self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }else {
    //删除陪练收藏
        Coach *coach = [_dataList objectAtIndex:indexPath.row];
        [CoachService userCollectionCoach:self userId:user.userId coachId:coach.coachId type:2];
        
        [self.dataList removeObjectAtIndex:indexPath.row];
        [self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark topSegmentedControl Target
- (void)segmentChange {
    switch (self.topSegmentedControl.selectedSegmentIndex) {
        case 0:
            HDLog(@"0");
            [self queryData];
            break;
        case 1:
            HDLog(@"1");
            [self queryData];
            break;
        default:
            break;
    }
}

@end
