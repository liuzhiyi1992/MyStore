//
//  CoachOrderController.m
//  Sport
//
//  Created by 江彦聪 on 15/7/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachOrderController.h"
#import "Coach.h"
#import "DateUtil.h"
#import "PriceUtil.h"
#import "CoachHeaderView.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "BusinessCategory.h"
#import "CoachBookingInfo.h"
#import "NSDate+Utils.h"
#import "CoachConfirmOrderController.h"
#import "UIScrollView+SportRefresh.h"
#import "CoachServiceArea.h"
#import "CoachPickerView.h"
#import "UserManager.h"
#import "CoachItemCell.h"
#import "CoachProjects.h"
#import "CoachOftenArea.h"

@interface CoachOrderController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *durationSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;

@property (strong, nonatomic) NSDate *selectedDate;      //选择的日期
@property (strong, nonatomic) NSString *selectedCategory; //选择的项目
@property (assign, nonatomic) TIME_STATE selectedTimeRange;  //选择的时段
@property (assign, nonatomic) int selectedDuration;    //选择的时长
@property (strong, nonatomic) NSDate *beginTime;       // 选择的开始时间
@property (strong, nonatomic) NSDate *mininumBeginTime; //最小开始时间
@property (strong, nonatomic) NSDate *maxEndime;        //最大结束时间
@property (strong, nonatomic) CoachOftenArea* displayAddress; //显示的地址
@property (assign, nonatomic) int selectedAddressIndex;  //选择的地址索引
//@property (assign, nonatomic) float totalPrice;
@property (strong, nonatomic) Coach *coach;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
//@property (strong, nonatomic) CoachHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (assign, nonatomic) BOOL isLoadingBookingInfo;
@property (assign, nonatomic) BOOL isLoadingCoachInfo;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *orderButtonList;
@property (strong, nonatomic) NSMutableArray *bookingInfoList;
@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) NSArray *oneWeekDateList;
@property (strong, nonatomic) NSMutableArray *addressList;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *beginTimeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *continueButtonList;
@property (copy, nonatomic) NSString *coachId;
@property (copy, nonatomic) NSString *coachName;

@property (assign, nonatomic) BOOL isHasServiceArea;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *categoryButtonArray;
@property (weak, nonatomic) IBOutlet UIView *categoryHolderView;
@property (strong, nonatomic) NSMutableArray *datePickerViewDataList;

@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (assign, nonatomic) NSUInteger dateSelectedRow;
@property (assign, nonatomic) NSUInteger timeSelectedRow;
@property (strong, nonatomic) CoachProjects *project;
@property (weak, nonatomic) IBOutlet UILabel *coachNameLabel;

@end

@implementation CoachOrderController


- (id)initWithCoach:(Coach *)coach project:(CoachProjects *)project {
    self = [super init];
    if (self) {
        self.coach = coach;
        self.coachId = self.coach.coachId;
        self.coachName = self.coach.name;
        self.project = project;
    }
    
    return self;
}

//- (id)initWithCoachId:(NSString *)coachId name:(NSString *)name
//{
//    self = [super init];
//    if (self) {
//        self.coachId = coachId;
//        self.coachName = name;
//    }
//    
//    return self;
//}
//
//- (id)initWithCoachId:(NSString *)coachId
//{
//    self = [super init];
//    if (self) {
//        self.coachId = coachId;
//    }
//    
//    return self;
//}

- (NSArray *)categoryList
{
    if (_categoryList == nil) {
        _categoryList = [NSArray array];
    }
    
    return _categoryList;
}

- (NSMutableArray *)bookingInfoList
{
    if (_bookingInfoList == nil) {
        _bookingInfoList = [NSMutableArray array];
    }
    
    return _bookingInfoList;
}

- (NSArray *)oneWeekDateList
{
    if (_oneWeekDateList == nil) {
        _oneWeekDateList = [NSArray array];
    }
    
    return _oneWeekDateList;
}

- (NSMutableArray *)addressList
{
    if (_addressList == nil) {
        _addressList = [NSMutableArray array];
    }
    
    return _addressList;
}

- (NSMutableArray *)datePickerViewDataList
{
    if (_datePickerViewDataList == nil) {
        _datePickerViewDataList = [NSMutableArray array];
    }
    
    return _datePickerViewDataList;
}

-(NSArray *)generateOneWeekData
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (CoachBookingInfo *info in self.bookingInfoList) {
        NSString *dateString = [DateUtil dateStringWithWeekday:info.weekDate];
        [mutableArray addObject:dateString];
    }
    
    return mutableArray;
}

-(NSArray *)generateCatogoryList
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (BusinessCategory *category in self.coach.categoryList) {
        [mutableArray addObject:category.name];
    }
    
    return mutableArray;
}

- (void)dealloc
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.isLoadingCoachInfo = NO;
    self.isLoadingBookingInfo = NO;
    self.isHasServiceArea = NO;
    self.title = [NSString stringWithFormat:@"预约%@",self.coachName];
    
    //设置下拉更新
    [self.scrollView addPullDownReloadWithTarget:self action:@selector(queryData)];
    
    [self.confirmButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultOrangeColor]] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultOrangeHightLightColor]] forState:UIControlStateHighlighted];
    [self.confirmButton setBackgroundImage:[SportColor createImageWithColor:[SportColor content2Color]] forState:UIControlStateDisabled];
    for (UIButton *button in self.categoryButtonArray) {
        button.layer.borderColor = [[UIColor hexColor:@"cccccc"] CGColor];
        button.layer.borderWidth = 0.5f;
        button.layer.cornerRadius = 5.0f;
        button.layer.masksToBounds = YES;
        [button setBackgroundImage:[SportColor createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [button setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultColor]] forState:UIControlStateSelected];
        button.hidden = YES;
        button.selected = NO;
    }
    
    self.coachNameLabel.text = [NSString stringWithFormat:@"教练：%@",self.coachName];
    
    [self initSelectedItem];
    [self setButtonState:NO];
    [self queryData];

}

-(void)setButtonState:(BOOL)isEnable
{
    for (UIButton *button in self.orderButtonList) {
        button.enabled = isEnable;
    }
    
    self.timeSegmentedControl.enabled = isEnable;
    self.durationSegmentedControl.enabled = isEnable;
}

-(void)setContinueButtonState:(BOOL)isEnable
{
    for (UIButton *button in self.continueButtonList) {
        button.enabled = isEnable;
    }
    
    self.durationSegmentedControl.enabled = isEnable;
}


-(void)initSelectedItem
{
    self.selectedCategory = @"";
    self.selectedDate = nil;
    self.selectedTimeRange = TIME_STATE_MORNING;
    self.selectedDuration = 1;
    self.beginTime = nil;
    self.selectedAddressIndex = -1;
    self.displayAddress = nil;
    //self.totalPrice = 0;
    
    self.dateSelectedRow = 0;
    self.timeSelectedRow = 0;
}

#define MORNING_INTERVAL 12*ONE_HOUR_INTERVAL
#define AFTERNOON_INTERVAL 18*ONE_HOUR_INTERVAL
//选择最近可用的时间段
-(void) updateAvalableTimeInfoWithDateIndex:(NSInteger)index
{
    if (index  >= [self.bookingInfoList count] || self.selectedDate == nil) {
        HDLog(@"系统错误 total number: %ld index %lu",(long)index,(unsigned long)[self.bookingInfoList count]);
        
        return;
    }
    
    CoachBookingInfo *info = self.bookingInfoList[index];
    
    if ([info.weekDate isToday]) {
        NSDate *now = [NSDate date];
        NSInteger diff = [now timeIntervalSinceDate:info.weekDate];
        if (diff > MORNING_INTERVAL) {
            info.morningState = NO;
        } else if (diff > AFTERNOON_INTERVAL) {
            info.afternoonState = NO;
        }
    }
    
//    [self.timeSegmentedControl setEnabled:info.morningState forSegmentAtIndex:TIME_STATE_MORNING];
//    
//    [self.timeSegmentedControl setEnabled:info.afternoonState forSegmentAtIndex:TIME_STATE_AFTERNOON];
//    
//    [self.timeSegmentedControl setEnabled:info.nightState forSegmentAtIndex:TIME_STATE_NIGHT];
    
    NSInteger beginTimeInterval = 0;
//    NSInteger endTimeInterval;
    int selectedIndex = -1;
    if (info.morningState) {
        selectedIndex = TIME_STATE_MORNING;
        beginTimeInterval = 6;
    } else if(info.afternoonState) {
        if (selectedIndex == -1) {
            selectedIndex = TIME_STATE_AFTERNOON;
       
            beginTimeInterval = 12;
        }
    } else if(info.nightState) {
        if (selectedIndex == -1) {
            selectedIndex = TIME_STATE_NIGHT;
            beginTimeInterval = 18;
        }

    } else {
        beginTimeInterval = 0;
        //全部时间段都不满足
    }
    
    //只要有一个时间段是OK，就选择最近的那个，开始时间以那个时间开始
    if (selectedIndex != -1) {
        //self.timeSegmentedControl.selectedSegmentIndex = selectedIndex;
        self.selectedTimeRange = selectedIndex;
    }
//    if (beginTimeInterval != 0) {
//        
//       //[self updateTimePickerRange:beginTimeInterval selectedDate:info.weekDate];
//        [self setContinueButtonState:YES];
//    } else {
//        [self performSelector:@selector(popupMessage:) withObject:@"TA今天没有时间哦~换一天试试？" afterDelay:0.5];
//
//        [self setContinueButtonState:NO];
//    }
}

-(void)popupMessage:(NSString *)string
{
    [SportPopupView popupWithMessage:string];
}

//必须在网络接口成功后才能够更新UI
-(void)updateUIWithIndex:(int)index
{
//    [self.headerView updateWithCoach:self.coach];
    
    //self.categoryLabel.text = self.selectedCategory;
//    [self updateCategoryButton];
    CoachItemCell *itemView = [CoachItemCell createCellWithCellType:CellTypeBooking];
    [itemView showWithSuperView:self.categoryHolderView];
    [itemView updateCellWithItem:_project];
    [self updateDisplayAddress];
    
    //复位约练时间段
    //[self updateMinusButtonAndPlusButton];

}

#define TAG_BUTTON_CATEGORY 1000
-(void)updateCategoryButton
{
    int count = 0;
    
    for (NSString *name in self.categoryList) {
        if (count >= 3) {
            return;
        }
        
        UIButton *button = (UIButton *)[self.categoryHolderView viewWithTag:TAG_BUTTON_CATEGORY+count];
        
        if (button == nil || ![button isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        [button setTitle:name forState:UIControlStateNormal];
        button.hidden = NO;
        
        if ([name isEqualToString:self.selectedCategory]){
            button.selected = YES;
            //按钮选中同时去掉边框
            button.layer.borderWidth = 0.0f;
        } else {
            button.selected = NO;
            //按钮去选中加边框
            button.layer.borderWidth = 0.5f;
        }
        
        count++;
    }
}

-(void) updateDisplayAddress {
    if (self.displayAddress == nil || [self.displayAddress.businessName length] == 0) {
        self.addressLabel.text = @"选择约练地点";
    } else {
        self.addressLabel.text = self.displayAddress.businessName;
    }

}
-(void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
    self.isLoadingCoachInfo = NO;
    self.isLoadingBookingInfo = YES;
    //User *user = [[UserManager defaultManager] readCurrentUser];
    //[[CoachService defaultService] getCoachInfo:self userId:user.userId coachId:self.coachId];
    [CoachService getCoachBespeakTime:self coachId:self.coachId];
}

#pragma mark - CoachServiceDelegate
//-(void)didGetCoachInfo:(Coach *)coach status:(NSString *)status msg:(NSString *)msg
//{
//    self.isLoadingCoachInfo = NO;
//    if ([status isEqualToString:STATUS_SUCCESS]) {
//        self.coach = coach;
//        
//        if (_isLoadingBookingInfo == NO) {
//            
//            [self handleLoadingCompleted];
//            //[self postCompleteNotification];
//        }
//    }else {
//        [SportProgressView dismissWithError:msg];
//    }
//    
//    //无数据时的提示
//    if (coach == nil) {
//        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
//        if ([status isEqualToString:STATUS_SUCCESS]) {
//            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
//        } else {
//            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
//        }
//    } else {
//        [self removeNoDataView];
//    }
//}

-(void)didGetCoachBookingInfo:(NSArray *)infoList status:(NSString *)status msg:(NSString *)msg
{
    self.isLoadingBookingInfo = NO;
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        [self generateCoachDataList:infoList];

        if (_isLoadingCoachInfo == NO) {
            [self handleLoadingCompleted];
            // [self postCompleteNotification];
        }
    }else {
        [SportProgressView dismissWithError:msg];
    }
    
    //无数据时的提示
    if ([infoList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"暂无数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
        }
    } else {
        [self removeNoDataView];
    }
}

-(void)handleLoadingCompleted
{
    
    [self.scrollView endLoad];
    
    //运动项目
    self.categoryList = [self generateCatogoryList];
    
    //默认选择的项目
    if ([self.categoryList count] > 0) {
        self.selectedCategory = self.categoryList[0];
    } else {
        self.selectedCategory = @"";
    }
    
    NSString *serviceName = @"";
//    if ([self.coach.serviceAreaList count] > 0) {
//        //为了标示是否设置服务区域
//        self.isHasServiceArea = YES;
//    }
    
    //第一条记录为用户手动指定上门地址
    CoachOftenArea *manualAddress = [[CoachOftenArea alloc]init];
    manualAddress.businessName = serviceName;
    
    self.addressList = [NSMutableArray arrayWithObject:manualAddress];
    
    if ([self.coach.oftenAreaList count] != 0) {
        [self.addressList addObjectsFromArray:self.coach.oftenAreaList];
    }
    
//    if (![self.coach.oftenArea isEqualToString:@""]) {
//        [self.addressList addObjectsFromArray:[self.coach.oftenArea componentsSeparatedByString:@","]];
//    }
    
    //默认选中第一条常驻场地
    if ([self.addressList count] > 1) {
        self.displayAddress = self.addressList[1];
        self.selectedAddressIndex = 1;
    }
    
    //价钱
    //self.totalPrice = self.coach.price;
    
    //一周可预定的时间
    self.oneWeekDateList = [self generateOneWeekData];
    
    int index = 0;
    
    //默认选中最近的可预约的时间
    if ([self.bookingInfoList count] > 0) {
        for (CoachBookingInfo *info in self.bookingInfoList) {
            if (info.morningState || info.afternoonState || info.nightState) {
                self.selectedDate = info.weekDate;
                break;
            }
            
            index++;
        }
    }
    
    if (self.selectedDate == nil) {
        [SportProgressView dismissWithError:@"亲，未来一周都没有可预约的时段"];
        self.dateLabel.text = @"已被约满";
        [self.dateLabel setTextColor:[SportColor otherRedColor]];
    } else {
        
        [self caculateTimeWithDateRowIndex:index
                              timeRowIndex:0
                                      date:self.selectedDate];

        [SportProgressView dismiss];
        [self setButtonState:YES];

        //[self updateAvalableTimeInfoWithDateIndex:index];
    }
    

    [self updateUIWithIndex:index];
}

-(void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

#define TAG_PICKER_CATEGORY   0x001
#define TAG_PICKER_DATE       0x002
#define TAG_PICKER_TIME       0x003

////切换项目
//- (IBAction)clickCategoryButton:(id)sender {
//    
//    if ([self.categoryList count]==0) {
//        return;
//    }
//    
//    SportPickerView *view = [SportPickerView createSportPickerView];
//    view.tag = TAG_PICKER_CATEGORY;
//    view.delegate = self;
//    view.dataList = self.categoryList;
//    
//    NSInteger row = [view.dataList indexOfObject:self.selectedCategory];
//    [view.dataPickerView selectRow:row inComponent:0 animated:YES];
//    [view show];
//}

- (IBAction)clickCategoryButton:(id)sender {
    NSUInteger index = [(UIButton *)sender tag] - TAG_BUTTON_CATEGORY;
    
    if (index < 3) {
        self.selectedCategory = self.categoryList[index];
        [self updateCategoryButton];
    }
}

//切换日期
- (IBAction)clickDateButton:(id)sender {
    if ([self.bookingInfoList count] == 0)  {
        return;
    }
    
    CoachPickerView *view = [CoachPickerView createCoachPickerView];
    view.tag = TAG_PICKER_DATE;
    view.delegate = self;
    view.dataList = self.datePickerViewDataList;
    //NSInteger row = [view.dataList indexOfObject:self.selectedInfo];
    
    [view.dataPickerView selectRow:self.dateSelectedRow inComponent:0 animated:YES];
    
    [view.dataPickerView selectRow:self.timeSelectedRow inComponent:1 animated:YES];
    
    [view show];
}

//完成选择项目或者日期
- (void)didClickSportPickerViewOKButton:(CoachPickerView *)sportPickerView
                                    row:(NSInteger)row
{
    if (sportPickerView.tag == TAG_PICKER_CATEGORY) {
        if (row >= [self.categoryList count]) {
            [SportPopupView popupWithMessage:@"系统错误"];
            return;
        }
        
        self.selectedCategory = self.categoryList[row];
        self.categoryLabel.text = self.selectedCategory;
        
    } else if (sportPickerView.tag == TAG_PICKER_DATE) {
        if (row >= [self.bookingInfoList count]) {
            [SportPopupView popupWithMessage:@"系统错误"];
            return;
        }
        
        self.dateSelectedRow = row;
        self.timeSelectedRow = [sportPickerView.dataPickerView selectedRowInComponent:1];
        
        self.selectedDate = [(CoachBookingInfo *)self.bookingInfoList[row] weekDate];
  
        [self caculateTimeWithDateRowIndex:row
                            timeRowIndex:self.timeSelectedRow
                                    date:self.selectedDate];
    }
}

- (void)caculateTimeWithDateRowIndex:(NSUInteger)row
                                 timeRowIndex:(NSUInteger)timeSelectedRow
                                         date:(NSDate *)selectedDate
{
    if ([self.datePickerViewDataList count] == 0 ||
        [(NSArray *)self.datePickerViewDataList[0] count] < 1 ||
        [(NSArray *)self.datePickerViewDataList[0][1] count] == 0) {
        return;
    }
    
    NSString *beginTimeString = self.datePickerViewDataList[row][1][timeSelectedRow];
    if (![beginTimeString isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSArray *hourMinArray = [beginTimeString componentsSeparatedByString:@":"];
    if (hourMinArray == nil || [hourMinArray count] < 2) {
        return;
    }
    
    NSUInteger mininutesInterval = [hourMinArray[0] intValue]*60 + [hourMinArray[1] intValue];
    
    self.beginTime = [selectedDate dateByAddingMinutes:mininutesInterval];
    
    self.dateLabel.text = [DateUtil dateStringWithWeekdayDetail:self.beginTime];
    [self.dateLabel setTextColor:[SportColor highlightTextColor]];
    
    //选择时间段
    NSInteger interval = [self.beginTime hoursAfterDate:self.selectedDate];
    if (interval >= 6 && interval < 12) {
        self.selectedTimeRange = 0;
    } else if (interval >= 12 && interval < 18) {
        self.selectedTimeRange = 1;
    } else {
        self.selectedTimeRange = 2;
    }
}

//点击切换上下午晚上
//- (IBAction)clickTimeSegmentControl:(UISegmentedControl *)sender {
//    if (sender.selectedSegmentIndex > TIME_STATE_NIGHT) {
//        [SportPopupView popupWithMessage:@"系统错误"];
//        return;
//    }
//    
//    self.selectedTimeRange = sender.selectedSegmentIndex;
//    NSInteger beginTimeInterval = 0;
//    switch (sender.selectedSegmentIndex) {
//        case TIME_STATE_MORNING:
//            beginTimeInterval = 6;
//            break;
//        case TIME_STATE_AFTERNOON:
//            beginTimeInterval = 12;
//            break;
//        case TIME_STATE_NIGHT:
//            beginTimeInterval = 18;
//            break;
//    }
//    
//    [self updateTimePickerRange:beginTimeInterval
//                   selectedDate:self.selectedDate];
//}

//- (void)updateTimePickerRange:(NSInteger)beginTimeInterval
//                 selectedDate:(NSDate *)selectedDate {
//    NSDate *minBeginTime = [selectedDate dateByAddingHours:beginTimeInterval];
//    
//    //最大结束时间应该在计算当天的情况之前，取边界差5分钟为最大值
//    self.maxEndime = [minBeginTime dateByAddingMinutes:60*5+55];
//    
//    // 当天可预约的时间已经过期，则开始时间以现在时间为准。
//    if ([selectedDate isToday] && [minBeginTime isEarlierThanDate:[NSDate date]]) {
//        minBeginTime = [NSDate date];
//    }
//    
//    self.mininumBeginTime = minBeginTime;
//    self.beginTime = self.mininumBeginTime;
//    
//    self.beginTimeLabel.text = [DateUtil stringFromDate:self.mininumBeginTime DateFormat:@"HH:mm"];
//}

//点击切换时间长度
//#define MAX_DURATION 4
//- (IBAction)clickDurationSegmentControl:(UISegmentedControl *)sender {
//    if (sender.selectedSegmentIndex >= MAX_DURATION) {
//        [SportPopupView popupWithMessage:@"系统错误"];
//        return;
//    }
//    
//    [self updateDurationIndex:sender.selectedSegmentIndex];
//}

//-(void)updateDurationIndex:(NSInteger)index
//{
//    self.durationSegmentedControl.selectedSegmentIndex = index;
//    self.selectedDuration = (int)index +1;
//    self.totalPrice = self.coach.price * self.selectedDuration;
//    self.priceLabel.text = [PriceUtil toPriceStringWithYuan:self.totalPrice];
//}

//点击开始时间按钮
//- (IBAction)clickBeginTimeButton:(id)sender {
//    SportTimePickerView *view = [SportTimePickerView createSportTimePickerView];
//    view.tag = TAG_PICKER_TIME;
//
//    view.delegate = self;
//    view.datePickerView.datePickerMode = UIDatePickerModeTime;
//    view.datePickerView.minimumDate = self.mininumBeginTime;
//    view.datePickerView.maximumDate = self.maxEndime;
//    view.datePickerView.minuteInterval = 5;
//    
//    if (self.beginTime) {
//        [view.datePickerView setDate:self.beginTime animated:YES];
//    }
//    
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
//    [view.datePickerView setLocale:locale];
//    
//    [view show];
//}
//
////响应开始时间按钮
//- (void)didClickSportTimePickerViewOKButton:(SportTimePickerView *)sportTimePickerView selectedTime:(NSDate *)selectedTimeRange
//{
//    if (sportTimePickerView.tag == TAG_PICKER_TIME) {
//        self.beginTime = selectedTimeRange;
//        self.beginTimeLabel.text = [DateUtil stringFromDate:self.beginTime DateFormat:@"HH:mm"];
//    }
//}

//点击约练地址
- (IBAction)clickEditAddressButton:(id)sender {
    
    CoachSelectPlaceController *controller = [[CoachSelectPlaceController alloc]initWithSelectedAddressIndex:self.selectedAddressIndex serviceArea:self.coach.serviceAreaList dataList:self.addressList delegate:self];
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark --CoachSelectPlaceControllerDelegate
-(void)didFinishAddressSelection:(int)index
{
    if (index == -1) {
        return;
    }
    
    self.selectedAddressIndex = index;
    if (index < [self.addressList count]) {
        self.displayAddress = self.addressList[index];
    }
    
    [self updateDisplayAddress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickConfirmButton:(id)sender {
    
    if (self.displayAddress == nil ||[self.displayAddress.businessName length] == 0) {
        [SportPopupView popupWithMessage:@"请输入约练地址"];
        return;
    }
    
    if ([self.selectedCategory length] == 0) {
        [SportPopupView popupWithMessage:@"该教练没有填写运动项目，数据有误!"];
        
        return;
    }
    
//    for (BusinessCategory *category in self.coach.categoryList) {
//        if ([category.name isEqualToString:self.selectedCategory]) {
//            categoryId = category.businessCategoryId;
//            break;
//        }
//    }
    
    //计算开始时间
//    NSArray *timeArray = [self.beginTimeLabel.text componentsSeparatedByString:@":"];
//    int hour = 0, minute = 0;
//    if ([timeArray count] == 2) {
//        hour = [[timeArray objectAtIndex:0] intValue];
//        minute = [[timeArray objectAtIndex:1] intValue];
//    }
//    NSDate *startTime = [self.selectedDate dateByAddingTimeInterval:(hour * 60 * 60) + (minute * 60)];
    
    CoachConfirmOrderController *controller = [[CoachConfirmOrderController alloc] initWithCoachId:self.coachId
                                                                                          goodsId:self.project.goodsId
                                                                                         startTime:_beginTime
                                                                                           address:self.displayAddress];
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSArray *)generateDayTimeStringWithBegin:(NSDate *)beginTime
                                        end:(NSDate *)endTime {
    
    NSUInteger interval = 30;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while ([beginTime isEarlierThanDate:endTime]) {

        //当前时间之前的时间不显示
        if ([beginTime isLaterThanDate:[NSDate date]]) {
            [resultArray addObject:[DateUtil stringFromDate:beginTime DateFormat:@"HH:mm"]];
        }
        
        beginTime = [beginTime dateByAddingMinutes:interval];
    }
    
    return resultArray;
}

-(void)generateCoachDataList:(NSArray *)infoList {
    
    for (CoachBookingInfo *info in infoList) {
        if ([info.weekDate isToday]) {
            NSDate *now = [NSDate date];
            NSInteger diff = [now timeIntervalSinceDate:info.weekDate];
            if (diff > MORNING_INTERVAL) {
                info.morningState = NO;
            } else if (diff > AFTERNOON_INTERVAL) {
                info.afternoonState = NO;
            }
        }
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        if (info.morningState) {
            [tempArray addObjectsFromArray:[self generateDayTimeStringWithBegin:[info.weekDate dateByAddingHours:6] end:[info.weekDate dateByAddingHours:12]]];
        }
        
        if (info.afternoonState) {
            [tempArray addObjectsFromArray:[self generateDayTimeStringWithBegin:[info.weekDate dateByAddingHours:12] end:[info.weekDate dateByAddingHours:18]]];
        }
        
        if (info.nightState) {
            [tempArray addObjectsFromArray:[self generateDayTimeStringWithBegin:[info.weekDate dateByAddingHours:18] end:[info.weekDate dateByAddingHours:24]]];
        }
        
        if ([tempArray count] == 0) {
            continue;
        }
        
        [self.bookingInfoList addObject:info];
        [self.datePickerViewDataList addObject:[NSArray arrayWithObjects:info.weekDate,tempArray,nil]];
    }
    
}

//#define MAX_COUNT 4
//- (void)updateMinusButtonAndPlusButton
//{
//    if (self.selectedDuration <= 1) {
//        self.minusButton.enabled = NO;
//        self.selectedDuration = 1;
//    } else {
//        self.minusButton.enabled = YES;
//    }
//    
//    if (self.selectedDuration >= MAX_COUNT) {
//        self.plusButton.enabled = NO;
//        self.selectedDuration = MAX_COUNT;
//    } else {
//        self.plusButton.enabled = YES;
//    }
//    
//    self.durationLabel.text = [NSString stringWithFormat:@"%d个小时",self.selectedDuration];
//    self.totalPrice = self.coach.price * self.selectedDuration;
//
//    NSString *priceString = [PriceUtil toPriceStringWithYuan:self.totalPrice];
//    
//    NSString *title = [NSString stringWithFormat:@"提交预约（%@）",priceString];
//    [self.confirmButton setTitle:title forState:UIControlStateNormal];
//    
//}
//
//- (IBAction)clickMinusButton:(id)sender {
//    //[MobClickUtils event:umeng_event_month_buy_club_click_count_decrease];
//    
//    if (self.selectedDuration > 1) {
//        self.selectedDuration--;
//    }
//    
//    [self updateMinusButtonAndPlusButton];
//}
//
//- (IBAction)clickPlusButton:(id)sender {
//    //[MobClickUtils event:umeng_event_month_buy_club_click_count_increase];
//    
//    if (self.selectedDuration < MAX_COUNT) {
//        self.selectedDuration ++;;
//    }
//    
//    [self updateMinusButtonAndPlusButton];
//}

@end
