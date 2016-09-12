//
//  BusinessListController.m
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessListController.h"
#import "BusinessListCell.h"
#import "BusinessDetailController.h"
#import "Business.h"
#import "SportProgressView.h"
#import "BusinessCategory.h"
#import "UIView+Utils.h"
#import "City.h"
#import "CityManager.h"
#import "HistoryManager.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "BaseService.h"
#import "MapBusinessesController.h"
#import "BusinessCategoryManager.h"
#import "SearchBusinessController.h"
#import "DeviceDetection.h"
#import "UIScrollView+SportRefresh.h"
#import "DateUtil.h"
#import "GuidanceView.h"
#import "NoBlankSpaceView.h"
#import "NSDate+Utils.h"
#import "BusinessListPickerView.h"
#import "SportPopupView.h"
#import "DropDownDataManager.h"
#import "PickerViewDataList.h"
#import "UITableView+Utils.h"
#import "BusinessListFilterButtonsView.h"
#import "BusinessListFilterContentView.h"

@interface BusinessListController ()<UIAlertViewDelegate,NoBlankSpaceViewDelegate,GuidanceViewDelegate, BusinessListFilterButtonsViewDelegate>

@property (strong, nonatomic) NSMutableArray *dataList;

@property (copy, nonatomic) NSString *selectedCategoryId;
@property (copy, nonatomic) NSString *selectedRegionId;
@property (copy, nonatomic) NSString *selectedFilterId;
@property (copy, nonatomic) NSString *selectedSortId;

@property (copy, nonatomic) NSString *selectedCategoryName;
@property (copy, nonatomic) NSString *selectedRegionName;
@property (copy, nonatomic) NSString *selectedFilterName;
@property (copy, nonatomic) NSString *selectedSortName;

@property (strong, nonatomic) NSDate *selectedDate;           //日期
@property (copy, nonatomic) NSString *selectedStartHour;      //开始时间的小时 (取值例如:@"17")
@property (copy, nonatomic) NSString *selectedTimeTnterval;   //时长 (取值例如:@"3")
@property (copy, nonatomic) NSString *selectedSoccerNumber;   //人数 (取值例如:@"9")

@property (assign, nonatomic) int finishPage;
@property (assign, nonatomic) int onePageCount;
@property (assign, nonatomic) BOOL isFirstController;
@property (copy, nonatomic) NSString *from;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) BOOL isChooseTime;
@property (strong, nonatomic) NoBlankSpaceView *noBlankSpaceView;
@property (assign, nonatomic) BOOL isClickRefresh;
@property (weak, nonatomic) IBOutlet UILabel *businessResultLabel;
@property (strong, nonatomic) GuidanceView *guidanceView;
@property (strong, nonatomic) NSURLSessionTask *task;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseTimeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseTimeViewHeightConstraint;
@property (assign, nonatomic) BOOL canChooseTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *filterHolderView;
@property (strong, nonatomic) BusinessListFilterButtonsView *filterButtonsView;
@property (weak, nonatomic) BusinessListFilterContentView *pullDownView;

@end

#define COUNT_ONE_PAGE  20
#define PAGE_START      1

#define PICKER_TYPE_REGION  1
#define PICKER_TYPE_SORT    2

#define SCREENHEIGHT  [UIScreen mainScreen].bounds.size.height

@implementation BusinessListController

- (NSMutableDictionary *)offscreenCells {
    if (_offscreenCells == nil) {
        _offscreenCells =[[NSMutableDictionary alloc]initWithDictionary:[NSDictionary dictionary]];
    }
    
    return _offscreenCells;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_DID_CHANGE_CITY object:nil];
}

- (id)initWithCategoryId:(NSString *)categoryId
       isFirstController:(BOOL)isFirstController
            categoryName:(NSString *)categoryName {
    self = [super init];
    if (self) {
        self.selectedCategoryId = categoryId;
        self.isFirstController = isFirstController;
        self.selectedCategoryName = categoryName;
        [self commonInitData];
    }
    return self;
}

- (id)initWithCategoryId:(NSString *)categoryId
                regionId:(NSString *)regionId
                  sortId:(NSString *)sortId
                    page:(int)page
                   count:(int)count
                    from:(NSString *)from{
    self = [super init];
    if (self) {
        self.selectedCategoryId = categoryId;
        self.selectedRegionId = regionId;
        self.finishPage = page;
        self.onePageCount = count;
        self.from = from;
        [self commonInitData];
    }
    return self;
}

- (id)initWithCategoryId:(NSString *)categoryId
                    date:(NSDate *)date
               startHour:(NSInteger)startHour
            timeTnterval:(NSInteger)timeTnterval
            soccerNumber:(NSString *)soccerNumber
        selectedFilterId:(NSString *)selectedFilterId {
    self = [super init];
    if (self) {
        self.selectedCategoryId = categoryId;
        self.selectedDate = date;
        self.selectedStartHour = [@(startHour) stringValue];
        self.selectedTimeTnterval = [@(timeTnterval) stringValue];
        self.selectedSoccerNumber = soccerNumber;
        self.selectedFilterId = selectedFilterId;
        [self commonInitData];
    }
    return self;
}

- (void)commonInitData {
    [self reloadAllIdAndNameData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeCity)
                                                 name:NOTIFICATION_NAME_DID_CHANGE_CITY
                                               object:nil];
}

- (void)reloadAllIdAndNameData
{
    if (self.selectedCategoryId == nil) {
        self.selectedCategoryId = DEFAULT_CATEGORY_ID;
    }
    if (self.selectedRegionId == nil) {
        self.selectedRegionId = REGION_ID_ALL;
    }
    if (self.selectedFilterId == nil) {
        self.selectedFilterId = FILTRATE_ID_ALL;
    }
    if (self.selectedSortId == nil) {
        self.selectedSortId = SORT_ID_NEAR_TO_FAR;
    }
    
    DropDownDataManager *m = [DropDownDataManager defaultManager];
    self.selectedCategoryName = [m categoryNameWithId:self.selectedCategoryId];
    self.selectedRegionName = [m regionNameWithId:self.selectedRegionId];
    self.selectedFilterName = [m filterNameWithId:self.selectedFilterId];
    self.selectedSortName = [m sortNameWithId:self.selectedSortId];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"场馆列表";
    self.finishPage = 0;

    if (_onePageCount == 0) {
        self.onePageCount = COUNT_ONE_PAGE;
    }
    
    if ([[CityManager defaultManager].cityList count] == 0) {
        [[BaseService defaultService] queryCityList:nil];
    }
    
    [self updateBaseUI];
}

- (void)updateBaseUI{
    [self createRightTopImageButton:[SportImage mapButtonImage]];
    
    [self hideChooseTimeView:NO];
    [self tableViewUp];
    
    [self.chooseTimeLine updateHeight:0.5];
    [self.chooseTimeLine setHidden:YES];

    self.dataTableView.rowHeight = UITableViewAutomaticDimension;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        self.dataTableView.estimatedRowHeight = 80.0f;
    }
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    
    [self updateChooseTimeView];
    
    [self updateFilterButtonsHolderView];
    
    [self.dataTableView beginReload];
}

#pragma mark - 筛选栏的下拉与收起
- (void)updateFilterButtonsHolderView {
    self.filterButtonsView = [BusinessListFilterButtonsView showInSuperView:self.filterHolderView delegate:self];
    [self updatFilterButtonsView];
}

- (void)didClickBusinessListFilterButtonsView:(NSUInteger)index isOpen:(BOOL)isOpen {
    if (isOpen == NO) {
        [self dismissPullDownView];
        return;
    }
    
    NSString *selectedId = nil;
    switch (index) {
        case 0: {
            selectedId = self.selectedCategoryId;
            break;
        }
        case 1: {
            selectedId = self.selectedRegionId;
            break;
        }
        case 2: {
            selectedId = self.selectedFilterId;
            break;
        }
        case 3: {
            selectedId = self.selectedSortId;
            break;
        }
        default: {
            break;
        }
    }
    
    self.pullDownView = [BusinessListFilterContentView showInSuperView:self.filterHolderView belowSubview:self.filterButtonsView superViewHeightConstraint:self.filterViewHeightConstraint categoryId:self.selectedCategoryId pullDownType:(PullDownType)index selectedId:selectedId finishHandler:^(NSString *resultSelectedId) {
        switch (index) {
            case 0: {
                //如果切换项目，则清空时间筛选
                if (![self.selectedCategoryId isEqualToString:resultSelectedId]) {
                    [self clearChooseTimeView];
                }
                
                self.selectedCategoryId = resultSelectedId;
                
                //如果项目是不支持显示室内室外筛选的，则筛选置为默认
                if (![DropDownDataManager isShowIndoorOutdoorWithCategoryId:self.selectedCategoryId]) {
                    self.selectedFilterId = FILTRATE_ID_ALL;
                }
                break;
            }
            case 1: {
                self.selectedRegionId = resultSelectedId;
                break;
            }
            case 2: {
                self.selectedFilterId = resultSelectedId;
                break;
            }
            case 3: {
                self.selectedSortId = resultSelectedId;
                break;
            }
            default: {
                break;
            }
        }
        
        [self reloadAllIdAndNameData];
        
        [self.dataTableView beginReload];
    } dismissHandler:^{
        [self updatFilterButtonsView];
    }];
}

- (void)dismissPullDownView {
    if (self.pullDownView) {
        [self.pullDownView dismiss];
    }
}

- (void)updatFilterButtonsView {
    NSMutableArray *mList = [NSMutableArray array];
    if (self.selectedCategoryName) {
        [mList addObject:self.selectedCategoryName];
    }
    if (self.selectedRegionName) {
        [mList addObject:self.selectedRegionName];
    }
    if (self.selectedFilterName) {
        [mList addObject:self.selectedFilterName];
    }
    if (self.selectedSortName) {
        [mList addObject:self.selectedSortName];
    }
    [self.filterButtonsView updateWithTitleArray:mList];
}

/**
 *  点击选择时间按钮展开pickerView
 */
- (IBAction)clickChooseTimeButton:(UIButton *)sender {
    if (self.isChooseTime) {
        [self dismissPullDownView];
        
        [MobClickUtils event:umeng_event_business_list_click_cancel_time];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否清除当前指定时间？清除后可重新指定时间" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
        [alert show];
    }else{
        [self showPickView];
    }
}

- (IBAction)clickTimeLabelButton:(UIButton *)sender {
    [self showPickView];
}

- (void)showPickView{
    [self dismissPullDownView];
    
    __weak __typeof(self) weakSelf = self;
    [BusinessListPickerView showWithCategoryId:self.selectedCategoryId selectedDate:self.selectedDate selectedStartHour:self.selectedStartHour selectedTimeTnterval:self.selectedTimeTnterval selectedSoccerNumber:self.selectedSoccerNumber OKHandler:^(NSDate *date, NSString *startHour, NSString *timeTnterval, NSString *soccerNumber) {
        
        weakSelf.selectedDate = date;
        weakSelf.selectedStartHour = startHour;
        weakSelf.selectedTimeTnterval = timeTnterval;
        weakSelf.selectedSoccerNumber = soccerNumber;
        
        [weakSelf updateChooseTimeView];
        
        [weakSelf.dataTableView beginReload];
        
        if (weakSelf.isClickRefresh) {
            [SportProgressView showWithStatus:@"重新选择时间"];
        }
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex == buttonIndex) {
        [MobClickUtils event:umeng_event_business_list_click_cancel_time label:@"取消"];
    }else{
        [MobClickUtils event:umeng_event_business_list_click_cancel_time label:@"清除"];
        if (self.noBlankSpaceView) {
            [SportProgressView showWithStatus:@"正在清除"];
        }
        [self clearChooseTimeView];
        [self.dataTableView beginReload];
    }
}

/**
 *  更改筛选时间按钮的状态
 */
- (void)clearChooseTimeView {
    self.isChooseTime = NO;
    
    self.selectedDate = nil;
    self.selectedStartHour = nil;
    self.selectedTimeTnterval = nil;
    self.selectedSoccerNumber = PEOPLE_NUMBER_ALL;
    
    [self updateChooseTimeView];
}

- (void)updateChooseTimeView {
    if (self.selectedDate == nil) {
        [self.chooseTimeButton setTitle:@"指定时间" forState:UIControlStateNormal];
        self.chooseTimeLabel.text = @"按指定时间筛选空闲场馆";
        
        self.isChooseTime = NO;
    } else {
        [self.chooseTimeButton setTitle:@"清除时间" forState:UIControlStateNormal];
        
        NSDate *date = self.selectedDate;
        NSString *weekString = ([date isToday] ? @"今天" : [DateUtil ChineseWeek2:date]);
        NSString *dateString = [DateUtil stringFromDate:date DateFormat:[NSString stringWithFormat:@"dd日(%@) %@:00",weekString, self.selectedStartHour]];
        
        //足球场
        if ([self.selectedCategoryId isEqualToString: @"11"]) {
            NSMutableString *mutableString = [NSMutableString stringWithString:dateString];
            if ([self.selectedSoccerNumber length] > 0) {
                [mutableString appendString:[NSString stringWithFormat:@"   %@人场",self.selectedSoccerNumber]];
            }
//            [mutableString appendString:@" 有空场的"];
            self.chooseTimeLabel.text = mutableString;
        }else{//羽毛球
            self.selectedSoccerNumber = nil;
            int endHour = [self.selectedStartHour intValue] + [self.selectedTimeTnterval intValue];
            self.chooseTimeLabel.text = [NSString stringWithFormat:@"%@-%@:00",dateString,[@(endHour) stringValue]];
        }
        
        //一个label中显示不同的字体和颜色
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:self.chooseTimeLabel.text];
//        [str addAttribute:NSForegroundColorAttributeName value:[SportColor content2Color] range:NSMakeRange(self.chooseTimeLabel.text.length - 4, 4)];
        self.chooseTimeLabel.attributedText = str;
        
        self.isChooseTime = YES;

    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];

    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.task cancel];
    [self.guidanceView removeFromSuperview];
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    }
}

// This method is called when the Dynamic Type user setting changes (from the system Settings app)
- (void)contentSizeCategoryChanged:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataTableView reloadData];
    });
}

- (void)didChangeCity{
    self.selectedRegionId = REGION_ID_ALL;
    
    NSArray *list = [[BusinessCategoryManager defaultManager] currentAllCategories];
    if ([list count] > 0) {
        BusinessCategory *category = [list objectAtIndex:0];
        self.selectedCategoryId = category.businessCategoryId;
    }
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataTableView beginReload];
    });
}

- (void)clickRightTopButton:(id)sender{
    [self dismissPullDownView];
    
    [MobClickUtils event:umeng_event_click_map_from_business_list];
    
    MapBusinessesController *controller = [[MapBusinessesController alloc] initWithCategoryId:_selectedCategoryId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createBackButton{
    if (_isFirstController == YES) {
        CGFloat buttonWith = 44;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWith, 25)] ;
        if (DeviceSystemMajorVersion() >= 7) {
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, -24, 0, 0)];
        }
        [button setImage:[SportImage searchButtonImage] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = buttonItem;
    } else {
        [super createBackButton];
    }
}

- (void)clickSearchButton:(id)sender{
    SearchBusinessController *controller = [[SearchBusinessController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadNewData{
    [self.noBlankSpaceView removeFromSuperview];
    [self removeNoDataView];
    
    self.finishPage = 0;
    [self queryData];
}

- (void)loadMoreData{
    [self queryData];
}

- (void)queryDataNoLodingTips
{
    NSString *startDateString = nil;
    
    if (self.selectedDate != nil && self.selectedStartHour != nil) {
        NSString *dayString = [DateUtil stringFromDate:self.selectedDate DateFormat:@"yyyy-MM-dd"];
        NSString *timeString = [NSString stringWithFormat:@"%@ %@:00:00", dayString, self.selectedStartHour];
        NSDate *startDate = [DateUtil dateFromString:timeString DateFormat:@"yyyy-MM-dd HH:mm:ss"];
        startDateString = [@((int)[startDate timeIntervalSince1970]) stringValue];
    }

    CLLocationCoordinate2D coordinate = [[[UserManager defaultManager] readUserLocation] coordinate];
    
    self.task = [BusinessService queryBusinesses:self
                          categoryId:_selectedCategoryId
                              cityId:[CityManager readCurrentCityId]
                           region_id:self.selectedRegionId
                                sort:self.selectedSortId
                        querySupport:self.selectedFilterId
                            latitude:coordinate.latitude
                           longitude:coordinate.longitude
                               count:_onePageCount
                                page:_finishPage + 1
                                from:_from
                           queryDate:startDateString
                           queryHour:self.selectedTimeTnterval
                         queryNumber:self.selectedSoccerNumber];
}

- (void)queryData
{
    [self queryDataNoLodingTips];
}

#pragma mark - 时间筛选的显示与隐藏的处理
- (void)hideChooseTimeView:(BOOL)animated {
    [self updateChooseTimeViewHeightConstraint:- self.chooseTimeViewHeightConstraint.constant animated:animated];
}

- (void)showChooseTimeView:(BOOL)animated {
     [self updateChooseTimeViewHeightConstraint:0 animated:animated];
}

static BOOL isRunningChooseTimeViewAnimation = NO;

- (void)updateChooseTimeViewHeightConstraint:(CGFloat)constraint animated:(BOOL)animated {
    if (self.chooseTimeViewTopConstraint.constant == constraint) {
        return;
    }
    
    if (isRunningChooseTimeViewAnimation == NO) {
        isRunningChooseTimeViewAnimation = YES;
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                self.chooseTimeViewTopConstraint.constant = constraint;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                isRunningChooseTimeViewAnimation = NO;
            }];
            
        } else {
            self.chooseTimeViewTopConstraint.constant = constraint;
            [self.view layoutIfNeeded];
            isRunningChooseTimeViewAnimation = NO;
        }
    }
}

- (void)tableViewUp {
    CGFloat tableViewTopConstant = self.chooseTimeViewHeightConstraint.constant;
    if (self.tableViewTopConstraint.constant == tableViewTopConstant) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableViewTopConstraint.constant = tableViewTopConstant;
        [self.view layoutIfNeeded];
    }];
}

- (void)tableViewDown {
    CGFloat tableViewTopConstant = self.chooseTimeViewHeightConstraint.constant + 45;
    if (self.tableViewTopConstraint.constant == tableViewTopConstant) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableViewTopConstraint.constant = tableViewTopConstant;
        [self.view layoutIfNeeded];
    }];
}

typedef enum {
    BussinessListScrollDirectionNone = 0,
    BussinessListScrollDirectionUp = 1,
    BussinessListScrollDirectionDown = 2
} BussinessListScrollDirection;

//判断滚动方向
- (BussinessListScrollDirection)scrollDirection:(UIScrollView *)scrollView {
    static float newY = 0;
    static float oldY = 0;
    static int guessUpTimes = 0;   //猜测向上的次数
    static int guessDownTimes = 0; //猜测向下的次数
    static BussinessListScrollDirection direction;
    newY = scrollView.contentOffset.y;
    direction = BussinessListScrollDirectionNone;
    
    if (newY != oldY) {
        //向上
        if (newY > oldY) {
            guessUpTimes ++;
            guessDownTimes = 0;
            
            //经过三次猜测才算真的向上
            if (guessUpTimes >= 3) {
                guessUpTimes = 0;
                direction = BussinessListScrollDirectionUp;
            }
        }
        
        //向下
        else if (newY < oldY) {
            guessDownTimes ++;
            guessUpTimes = 0;
            
            //经过三次猜测才算真的向下
            if (guessDownTimes >= 3) {
                guessDownTimes = 0;
                direction = BussinessListScrollDirectionDown;
            }
        }
        oldY = newY;
    }
    return direction;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.canChooseTime) {
        CGFloat offsetY = scrollView.contentOffset.y;
        BussinessListScrollDirection direction = [self scrollDirection:scrollView];
        
        if (direction == BussinessListScrollDirectionUp) {
            //大于80是为了防止在顶部下拉刷新带来的不确定偏移
            if (offsetY > 80) {
                [self hideChooseTimeView:YES];
            }
        } else if (direction == BussinessListScrollDirectionDown) {
            CGFloat contentHeight = scrollView.contentSize.height;
            CGFloat tableHeight = scrollView.frame.size.height;
            //大于80是为了防止在底部带来的不确定偏移
            if (80 < contentHeight - tableHeight - offsetY) {
                [self showChooseTimeView:YES];
            }
        }
        
        //移动tableview的上边界
        if (offsetY > 80) {
            [self tableViewUp];
        } else if (offsetY <= 80 && self.chooseTimeViewTopConstraint.constant != -self.chooseTimeViewHeightConstraint.constant) {
            [self tableViewDown];
        }
    }
}

- (void)showGuidanceView {
    //添加场馆列表新手引导页
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"BUSINESSGUIDANCE"] isEqualToString:@"1"]) {
        if (self.guidanceView == nil) {
            self.guidanceView = [GuidanceView createGuidanceView];
        }
        _guidanceView.delegate = self;
        _guidanceView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [[UIApplication sharedApplication].keyWindow addSubview:_guidanceView];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"BUSINESSGUIDANCE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - BusinessServiceDelegate
- (void)didQueryBusinesses:(NSArray *)businesses status:(NSString *)status msg:(NSString *)msg page:(int)page canFiltrateTime:(NSString *)canFiltrateTime totalNumber:(NSString *)totalNumber tips:(NSString *)tips
{
    if (self.parentViewController == nil) {
        return;
    }
    
    [self.activityIndicatorView stopAnimating];

    [self.dataTableView endLoad];
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self.chooseTimeLine setHidden:YES];
        if (self.selectedDate && [totalNumber intValue] > 0) {
            
            [self.dataTableView sizeHeaderToFit:40];

            self.businessResultLabel.hidden = NO;
            //一个label中显示不同的字体和颜色
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:tips];
            [str addAttribute:NSForegroundColorAttributeName value:[SportColor defaultBlueColor] range:[tips rangeOfString:totalNumber]];
                                              
            self.businessResultLabel.attributedText =str;
        } else {
            
            [self.dataTableView sizeHeaderToFit:0];
            self.businessResultLabel.hidden = YES;
        }
        
        self.canChooseTime = [canFiltrateTime isEqualToString:@"1"];
        
        if (self.canChooseTime) {
            if (page == PAGE_START) {
                [self tableViewDown];
                [self showChooseTimeView:YES];
            }
            [self showGuidanceView];
        } else {
            [self tableViewUp];
            [self hideChooseTimeView:NO];
        }
        
        self.finishPage = page;
        if (page == PAGE_START) {
             self.dataList = [NSMutableArray arrayWithArray:businesses];
        } else {
            [self.dataList addObjectsFromArray:businesses];
        }
    } else {
        [SportPopupView popupWithMessage:msg];
    }
    
    [self.dataTableView reloadData];
    
    if (page == PAGE_START && [_dataList count] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.dataTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    if ([businesses count] < COUNT_ONE_PAGE) {
        [self.dataTableView canNotLoadMore];
    } else {
        [self.dataTableView canLoadMore];
    }
    
    //无数据时的提示
    if ([_dataList count] == 0) {
        if (self.canChooseTime && (self.selectedTimeTnterval.length > 0 || self.selectedSoccerNumber.length > 0)) {
            [self.chooseTimeLine setHidden:NO];
            if (self.noBlankSpaceView == nil) {
                
                self.noBlankSpaceView = [NoBlankSpaceView createNoBlankSpaceView];
                self.noBlankSpaceView.delegate = self;
                self.noBlankSpaceView.frame = CGRectMake(0, 90, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 90);
            }

            [self.view addSubview:self.noBlankSpaceView];
        }else{
            CGRect frame = CGRectMake(0, 90, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 90);
            if ([status isEqualToString:STATUS_SUCCESS]) {
                [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"暂无相关场馆"];
            } else {
                [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
            }
        }
        
        [self.view bringSubviewToFront:self.filterHolderView];
        [self.view bringSubviewToFront:self.chooseTimeView];
    } else {
        [self.noBlankSpaceView removeFromSuperview];
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"加载中"];
    [self queryData];
}

#pragma mark - NoBlankSpaceViewDelegate
- (void)didClickResetTimeButton{
    self.isClickRefresh = YES;
    [self showPickView];
}

#pragma mark - GuidanceViewDelegate
- (void)didClickGuidanceButton{
    [self showPickView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [BusinessListCell getCellIdentifier];
    
    BusinessListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [BusinessListCell createCell];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
        
    [self configureCell:cell atIndexPath:indexPath];
   
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // This project has only one cell identifier, but if you are have more than one, this is the time
    // to figure out which reuse identifier should be used for the cell at this index path.
    NSString *reuseIdentifier = [BusinessListCell getCellIdentifier];
    
    BusinessListCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [BusinessListCell createCell];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
       
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height + 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

- (void)configureCell:(BusinessListCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    BOOL isLast = (indexPath.row == [_dataList count] - 1);
    Business *business = [_dataList objectAtIndex:indexPath.row];
    [cell updateCell:business indexPath:indexPath isLast:isLast];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Business *business = [_dataList objectAtIndex:indexPath.row];
    BusinessDetailController *controller = nil;
    if (_selectedCategoryId == nil) {
        controller = [[BusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId] ;
    } else{
        controller = [[BusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:_selectedCategoryId] ;
    }
    [self.navigationController pushViewController:controller animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
