//
//  SearchResultController.m
//  Sport
//
//  Created by haodong  on 14-9-12.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SearchResultController.h"
#import "SportProgressView.h"
#import "CityManager.h"
#import "BusinessListCell.h"
#import "BusinessDetailController.h"
#import "Business.h"
#import "SearchBusinessController.h"
#import "SearchResultCell.h"
#import "UIScrollView+SportRefresh.h"
#import "RecommendDetailAlertView.h"
#import "LocateInMapController.h"
#import "UserManager.h"
#import "FastLoginController.h"
#import "LoginAlertView.h"
#import "SportPopupView.h"
#import "UIView+Utils.h"

@interface SearchResultController ()<RecommendDetailAlertViewDelegate,LocateInMapControllerDelegate,LoginAlertViewDelegate>
@property (copy, nonatomic) NSString *searchText;
@property (assign, nonatomic) int page;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic)  BusinessListCell *cell;
@property (strong, nonatomic) SearchResultCell *searchCell;
@property (strong, nonatomic) IBOutlet UIImageView *searchBackgroundImageView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (strong, nonatomic) IBOutlet UIView *tableViewFooterView;

@property (strong, nonatomic) RecommendDetailAlertView *recommendDetailAlertView;
@property (strong, nonatomic) LoginAlertView *loginAlertView;
@property (assign, nonatomic) CGFloat latitude;
@property (assign, nonatomic) CGFloat longitude;
@property (assign, nonatomic) BOOL isShowSelectedLocation;
@property (copy, nonatomic) NSString *venuesName;
@property (weak, nonatomic) IBOutlet UIButton *recommendVenuesButton;
@property (weak, nonatomic) IBOutlet UILabel *recommendLabel;

@end

@implementation SearchResultController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (instancetype)initWithSearchText:(NSString *)searchText
{
    self = [super init];
    if (self) {
        self.searchText = searchText;
    }
    return self;
}

#define PAGE_START      1
#define COUNT_ONE_PAGE 20

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initBaseUI];
    self.page = PAGE_START;
//    [self searchData];
    [self performSelector:@selector(searchData) withObject:nil afterDelay:0.8];
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    //[self.dataTableView beginReload];
    
    [self.tableViewFooterView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.21, [UIScreen mainScreen].bounds.size.width, [self updateRecommendDetailAlertViewSizeWithDataIsNil:YES])];
    self.isShowSelectedLocation = NO;
    self.recommendDetailAlertView.addressLabel.text = nil;
    self.venuesName = nil;
    
    [self.recommendVenuesButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackground"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [self.recommendVenuesButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackgroundSelected"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateHighlighted];
}

- (CGFloat)updateRecommendDetailAlertViewSizeWithDataIsNil:(BOOL)dataIsNil {
    
    if (dataIsNil) {
        [self.recommendLabel updateOriginY:0];
        CGFloat y = self.recommendLabel.frame.size.height;
        y = y + [UIScreen mainScreen].bounds.size.height * 0.06;
        [self.recommendVenuesButton updateOriginY:y];
        y = y + self.recommendVenuesButton.frame.size.height;
        
        [self.tableViewFooterView updateHeight:y];
        
        return self.tableViewFooterView.frame.size.height;
        
    }else {
        
        CGFloat y = [UIScreen mainScreen].bounds.size.height * 0.112;
        [self.recommendLabel updateOriginY:y];
        y = y + self.recommendLabel.frame.size.height;
        y = y + [UIScreen mainScreen].bounds.size.height * 0.06;
        [self.recommendVenuesButton updateOriginY:y];
        y = y + self.recommendVenuesButton.frame.size.height;
        y = y + [UIScreen mainScreen].bounds.size.height * 0.112;
        
        [self.tableViewFooterView updateHeight:y];
        
        return self.tableViewFooterView.frame.size.height;
        
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.loginAlertView removeFromSuperview];
}

- (void)initBaseUI{
    self.searchTextField.text = self.searchText;
    [self.searchBackgroundImageView setImage:[[UIImage imageNamed:@"SearchBackground"] stretchableImageWithLeftCapWidth:15 topCapHeight:0]];
    self.searchButton.layer.cornerRadius = 3.0f;
    self.searchButton.layer.masksToBounds = YES;
    [self.searchButton setBackgroundColor:[SportColor hexAColor]];
    self.searchButton.enabled = NO;
    
    if ([CityManager readCurrentCityName].length > 0) {
        [self createTitleView];
        NSString *string = [NSString stringWithFormat:@"%@·%@",DDTF(@"kSearch"),[CityManager readCurrentCityName]];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:14.0] range:NSMakeRange(3, [CityManager readCurrentCityName].length)];
        self.titleLabel.attributedText = attrString;
    }else{
        self.title = DDTF(@"kSearch");
    }
}

- (void)loadNewData
{
    self.page = PAGE_START;
    [self searchData];
}

- (void)loadMoreData
{
    self.page ++;
    [self searchData];
}

- (void)searchData
{
    [SportProgressView showWithStatus:DDTF(@"kLoading")];
    [BusinessService searchBusinesses:self
                           searchText:_searchText
                               cityId:[CityManager readCurrentCityId]
                                count:COUNT_ONE_PAGE
                                 page:_page];
}

#pragma mark - BusinessServiceDelegate
- (void)didSearchBusinesses:(NSArray *)businesses status:(NSString *)status
{
    [SportProgressView dismiss];
    [self.dataTableView endLoad];
    
    self.dataTableView.scrollEnabled = YES;
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if (_page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:businesses];
        } else {
            [self.dataList addObjectsFromArray:businesses];
        }
    }
    
    //    if ([_dataList count] == 0) {
    //        self.noDataTipsLabel.hidden = NO;
    //        if ([status isEqualToString:STATUS_SUCCESS]) {
    //            self.noDataTipsLabel.text = @"没有符合条件的场馆";
    //        } else {
    //            self.noDataTipsLabel.text = @"网络问题，未能加载到场馆";
    //        }
    //    } else {
    //        self.noDataTipsLabel.hidden = YES;
    //    }
    [self.dataTableView reloadData];
    
    if ([businesses count] < COUNT_ONE_PAGE) {
        [self.dataTableView canNotLoadMore];
        
        [self.tableViewFooterView updateHeight:[self updateRecommendDetailAlertViewSizeWithDataIsNil:NO]];
        
        self.dataTableView.tableFooterView = self.tableViewFooterView;
        self.tableViewFooterView.hidden = NO;
        
    } else {
        [self.dataTableView canLoadMore];
        self.dataTableView.tableFooterView = self.tableViewFooterView;
        self.tableViewFooterView.hidden = YES;
    }
    
    //无数据时的提示
    if ([_dataList count] == 0) {
        self.dataTableView.scrollEnabled = NO;
        CGRect frame = CGRectMake(0, 50, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 50);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            self.dataTableView.tableFooterView = nil;
            //            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"找不到相关的球馆呦，换个词搜搜看吧~"];
            [self.tableViewFooterView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.21 , [UIScreen mainScreen].bounds.size.width, [self updateRecommendDetailAlertViewSizeWithDataIsNil:YES])];
            [self.view addSubview:self.tableViewFooterView];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"数据加载失败，请点击刷新按钮"];
            
        }
    } else {
        [self removeNoDataView];        
    }
}

- (IBAction)clickSearchButton:(UIButton *)sender {
    [MobClickUtils event:umeng_event_click_search_window];
    SearchBusinessController *vc = [[SearchBusinessController alloc]initWithControllertype:ControllerTypeSearchResult];
    vc.transmitSearchText = self.searchText;
    __weak __typeof(self) weakSelf = self;
    vc.block = ^(NSString *clearWord){
        weakSelf.searchTextField.text = clearWord;
        weakSelf.searchText = clearWord;
        weakSelf.page = PAGE_START;
        [weakSelf searchData];
    };
    [self presentViewController:vc animated:NO completion:nil];
}
- (IBAction)clickRecommendButton:(id)sender {
    if (![UserManager isLogin]) {
        self.loginAlertView = [LoginAlertView createLoginAlertView];
        self.loginAlertView.delegate = self;
        [self.loginAlertView show];
        
    } else {
        
        self.recommendDetailAlertView = [RecommendDetailAlertView createRecommendDetailAlertView];
        self.recommendDetailAlertView.delegate = self;
        [self.recommendDetailAlertView show];
    }

}

- (void)clickBackButton:(id)sender{
    [MobClickUtils event:umeng_event_click_exit_search_result];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didClickNoDataViewRefreshButton
{
    [self searchData];
}

#pragma mark - LoginAlertViewDelegate
- (void)didClickLoginButton {
    FastLoginController *controller = [[FastLoginController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickDirectRecommendButton{
    self.recommendDetailAlertView = [RecommendDetailAlertView createRecommendDetailAlertView];
    self.recommendDetailAlertView.delegate = self;
    [self.recommendDetailAlertView show];
    
    [self.loginAlertView removeFromSuperview];
}

#pragma mark - RecommendDetailAlertViewDelegate
- (void)didSelectedPosition {
    LocateInMapController *controller = [[LocateInMapController alloc] initWithDelegate:self SelectedLatitude:self.latitude selectedLongtitude:self.longitude isShowSelectedLocation:_isShowSelectedLocation];
    [self.navigationController pushViewController:controller animated:YES];
    [self.recommendDetailAlertView removeFromSuperview];
}

- (void)didClickSubmitButtonWithBusinessNameTextfieldText:(NSString *)businessNameTextfieldText {
//   需求改了，之前是要提示的，这代码保留先吧
//    if (businessNameTextfieldText == nil || [businessNameTextfieldText isEqual:@""]) {
//        
//        [SportPopupView popupWithMessage:@"请输入场馆名称"];
//    }else if (self.recommendDetailAlertView.addressLabel.text == nil || [self.recommendDetailAlertView.addressLabel.text  isEqual: @""]) {
//        
//        [SportPopupView popupWithMessage:@"请选择场馆地址"];
//    }else {
//        
//        [BusinessService getVenuesUserRecommend:self venuesName:businessNameTextfieldText locationName:self.recommendDetailAlertView.addressLabel.text userId:[UserManager defaultManager].readCurrentUser.userId];
//    }
    
    [BusinessService getVenuesUserRecommend:self venuesName:businessNameTextfieldText locationName:self.recommendDetailAlertView.addressLabel.text userId:[UserManager defaultManager].readCurrentUser.userId];
}

- (void)updateTextFieldText:(NSString *)text {
    
    self.venuesName = text;
    
    if (text != nil && [text isEqualToString:@""] == NO && _recommendDetailAlertView.addressLabel.text != nil && [_recommendDetailAlertView.addressLabel.text isEqualToString:@""] == NO) {
        
        self.recommendDetailAlertView.submitButton.enabled = YES;
        self.recommendDetailAlertView.submitButton.backgroundColor = [UIColor hexColor:@"4958ee"];
    } else {
        self.recommendDetailAlertView.submitButton.enabled = NO;
        self.recommendDetailAlertView.submitButton.backgroundColor = [UIColor hexColor:@"aaaaaa"];
    }
}

#pragma mark - BusiessServiceDelegate
- (void)didGetVenuesUserRecommendWithStatus:(NSString *)status
                                        msg:(NSString *)msg{
    //提交就置空场馆名称，防止干扰第二次提交的结果
    self.venuesName = nil;
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        [self.recommendDetailAlertView removeFromSuperview];
        [SportPopupView popupWithMessage:@"感谢您的推荐，趣运动将尽快审核!"];
        
        
    }else {
        
        [SportProgressView dismissWithError:msg];
    }
    
}

#pragma mark - LocateInMapControllerDelegate
- (void)didLocateInMap:(NSString *)address
              latitude:(double)latitude
             longitude:(double)longitude
isShowSelectedLocation:(BOOL)isShowSelectedLocation

{

    self.recommendDetailAlertView.addressLabel.text = address;
    self.latitude = latitude;
    self.longitude = longitude;
    self.isShowSelectedLocation = isShowSelectedLocation;
    [self.recommendDetailAlertView show];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"修改位置"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.recommendDetailAlertView.selectedAddressButton setAttributedTitle:str forState:UIControlStateNormal];
    
    if (address != nil && [address isEqual:@""] == NO ) {
        self.recommendDetailAlertView.cancelButtonTopConstraint.constant = 25;
    } else {
        self.recommendDetailAlertView.cancelButtonTopConstraint.constant = 0;
    }
    
    if (_venuesName != nil && [_venuesName isEqualToString:@""] == NO && _recommendDetailAlertView.addressLabel.text != nil && [_recommendDetailAlertView.addressLabel.text isEqualToString:@""] == NO) {
        
        self.recommendDetailAlertView.submitButton.enabled = YES;
        self.recommendDetailAlertView.submitButton.backgroundColor = [UIColor hexColor:@"4958ee"];
    } else {
        self.recommendDetailAlertView.submitButton.enabled = NO;
        self.recommendDetailAlertView.submitButton.backgroundColor = [UIColor hexColor:@"aaaaaa"];
    }

}

- (void)didClickCancelButton{
    
    [self.recommendDetailAlertView show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    BOOL isLast = (indexPath.row - [_dataList count] - 1);
    Business *business = [_dataList objectAtIndex:indexPath.row];
    [cell updateCell:business indexPath:indexPath isLast:isLast isShowCategory:YES searchText:self.searchText];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Business *business = [_dataList objectAtIndex:indexPath.row];
    if (business.neighborhood.length > 0) {
        return 100;
    }else{
        return 75;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClickUtils event:umeng_event_click_search_result];
    Business *business = [_dataList objectAtIndex:indexPath.row];
    BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId] ;
    [self.navigationController pushViewController:controller animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
