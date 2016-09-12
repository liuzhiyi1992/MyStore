//
//  BookingDetailController.m
//  Sport
//
//  Created by haodong  on 13-7-18.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BookingDetailController.h"
#import "Business.h"
#import "DayBookingInfo.h"
#import "Court.h"
#import "Product.h"
#import "UIView+Utils.h"
//#import "OrderConfirmController.h"
#import "User.h"
#import "UserManager.h"
#import "LoginController.h"
#import "Order.h"
#import "BusinessCategoryManager.h"
#import "SportPopupView.h"
#import "SportNavigationController.h"
#import "SportProgressView.h"
#import "NSDate+Utils.h"
#import "ProductGroup.h"
#import "OrderListController.h"
#import "TipNumberManager.h"
#import <QuartzCore/QuartzCore.h>
#import "PriceUtil.h"
#import "PayController.h"
#import "OrderManager.h"
#import "SelectedProductView.h"
#import "FastLoginController.h"
#import "NSDate+Utils.h"
#import "ShortTipsView.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"
#include "PreciseTimerHelper.h"
#import "SelectCourtDateListView.h"
#import "SelectCourtTimeView.h"
#import "SelectCourtNameView.h"
#import "SelectCourtProductView.h"
#import "SelectedCourtJoinProductView.h"
#import "CourtJoin.h"
#import "CourtJoinConfirmOrderController.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"
#import "CourtJoinDetailController.h"
#import "BusinessOrderConfirmController.h"

@interface BookingDetailController()<SelectCourtProductViewDelegate>
@property (copy,   nonatomic) NSString *businessId;
@property (copy,   nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSMutableArray *selectedProductList;
@property (copy,   nonatomic) NSString *selectedCourseTypeId;
@property (strong, nonatomic) UIButton *selectedCourseButton;
@property (assign, nonatomic) BOOL isFirstTimeViewDidAppear;
@property (strong, nonatomic) Order *needPayOrder;
@property (strong, nonatomic) ProductInfo *productInfo;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSArray *dateList;
@property (assign, nonatomic) BOOL isCardUser;
@property (assign, nonatomic) BOOL isShowShortTips;
@property (strong, nonatomic) NSMutableArray *twoHourProductIdsList;
@property (strong, nonatomic) ShortTipsView *tipsView;
@property (assign, nonatomic) uint64_t startTime;
@property (weak, nonatomic) NSTimer *countDownTimer;
@property (strong, nonatomic) SelectCourtTimeView *timeScrollView;
@property (strong, nonatomic) SelectCourtNameView *nameScrollView;
@property (strong, nonatomic) SelectCourtProductView *productScrollView;

@end

@implementation BookingDetailController

- (id)initWithBusinessId:(NSString *)businessId
              categoryId:(NSString *)categoryId
                    date:(NSDate *)date
{
    self = [super init];
    if (self) {
        self.businessId = businessId;
        self.categoryId = categoryId;
        self.selectedDate = date;
        
        if (_selectedDate == nil) {
            self.selectedDate = [NSDate date];
        }
        
        [self initData];
    }
    return self;
}

- (void)initData
{
    self.isFirstTimeViewDidAppear = YES;
    self.selectedProductList = [NSMutableArray array];
}

#pragma mark -
//弹出提示信息
- (void)showShortTipsView:(NSString *)tips {
    if( ! self.isShowShortTips){
        self.tipsView = [ShortTipsView creatShortTipsView];
        CGRect tipsViewFrame = CGRectMake(0, 24, [UIScreen mainScreen].bounds.size.width, 40);
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [self.tipsView showWithContent:tips frame:tipsViewFrame durationDisplay:NO holderView:window];
        self.isShowShortTips = YES;
    }
}

#pragma mark -
- (void)queryData
{
    [SportProgressView showWithStatus:@"查询场地中..."];
    NSString *queryNumber = @"0";
    
    __weak __typeof(self) weakSelf = self;
    [BusinessService getVenueBookingWithBusinessId:_businessId
                                        categoryId:_categoryId
                                              date:_selectedDate
                                      courseTypeId:_selectedCourseTypeId
                                       queryNumber:queryNumber
                                        completion:^(NSString *status, NSString *msg, ProductInfo *productInfo, NSArray *dateList, BOOL isCardUser, NSString *tips) {
                                            
                                            [weakSelf didGetVenueBookingDate:productInfo status:status msg:msg dateList:dateList isCardUser:isCardUser tips:tips];
                                            
                                        }];
}

- (void)didGetVenueBookingDate:(ProductInfo *)productInfo
                        status:(NSString *)status
                           msg:(NSString *)msg
                      dateList:(NSArray *)dateList
                    isCardUser:(BOOL)isCardUser
                          tips:(NSString *)tips
{
    self.productInfo = productInfo;
    self.dateList = dateList;
    self.isCardUser = isCardUser;
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        //弹出数秒提示条
        if ([tips length] > 0) {
            [self showShortTipsView:tips];
        }
        
        self.selectedDate = productInfo.dayBookingInfo.date;
        
        if (self.selectedCourseTypeId == nil) {
            self.selectedCourseTypeId = productInfo.selectedCourseTypeId;
        }
        
        [self updateAllViews];
        
        [SportProgressView dismiss];
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
    //无数据时的提示
    if (productInfo == nil) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择场次";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.firstExampleView.backgroundColor = [SelectCourtProductView canOrderColor];
    self.secondExampleView.backgroundColor = [SelectCourtProductView orderedColor];
    self.thirdExampleView.backgroundColor = [SelectCourtProductView myOrderColor];;
    
//    [self.submitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    [self createRightTopButton:@"订单"];
    
    [MobClickUtils event:umeng_event_show_venue_price];
    
    if (_selectedDate == nil) {
        self.selectedDate = [NSDate date];
    }
    
    [self queryData];
}

#define SPACE 1

- (void)autoScrollToCurrentTime {
    [self.productScrollView autoScrollToCurrentTime:self.selectedDate];
}

- (IBAction)clickTitleButton:(id)sender {
    _titleButton.selected = !_titleButton.selected;
    self.courseTypeBackgroundHolderView.hidden = !_titleButton.selected;
}

- (void)updateTitleButton
{
    if ([self.productInfo.courseTypeList count] > 1) {
        if (self.navigationItem.titleView != _titleButton)
        {
            self.navigationItem.titleView = _titleButton;
        }
        
        [self.titleButton setTitle:[self courseTypeNameWithId:self.selectedCourseTypeId] forState:UIControlStateNormal];
    }
}

- (NSString *)courseTypeNameWithId:(NSString *)courseTypeId
{
    if (courseTypeId == nil || [courseTypeId length] == 0) {
        if ([_productInfo.courseTypeList count] > 0) {
            CourseType *type = [_productInfo.courseTypeList objectAtIndex:0];
            return type.courseTypeName;
        }
    }
    
    for (CourseType *type in _productInfo.courseTypeList) {
        if ([type.courseTypeId isEqualToString:courseTypeId]) {
            return type.courseTypeName;
        }
    }
    return nil;
}

- (void)updateCourseTypeHolderView
{
    for (UIView *subView in _courseTypeHolderView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            return;
        }
    }
    
    NSUInteger count = [_productInfo.courseTypeList count];
    if (count <= 1) {
        return;
    }
    
    //建立button
    CGFloat width = [UIScreen mainScreen].bounds.size.width / count;
    CGFloat x = 0;
    int index = 0;
    for (CourseType *type in _productInfo.courseTypeList) {
        x = index * width;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, width, _courseTypeHolderView.frame.size.height)] ;
        [button setTitle:type.courseTypeName forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[SportColor defaultColor] forState:UIControlStateSelected];
        button.tag = index;
        [button addTarget:self action:@selector(clickCourseTypeButton:) forControlEvents:UIControlEventTouchUpInside];
        if (self.selectedCourseTypeId == nil) {
            if (index == 0) {
                button.selected = YES;
                self.selectedCourseButton = button;
            }
        } else {
            if ([type.courseTypeId isEqualToString:self.selectedCourseTypeId]) {
                button.selected = YES;
                self.selectedCourseButton = button;
            }
        }
        
        [self.courseTypeHolderView addSubview:button];
        
        index ++;
    }
    
    [self.moveLineView updateWidth:width];
    [self.moveLineView updateCenterX:_selectedCourseButton.center.x];
    
    //建立分割线
    for (int i = 1 ; i < index; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width * i , 0, 1, _courseTypeHolderView.frame.size.height)] ;
        view.backgroundColor = [UIColor colorWithRed:230./255.0 green:230./255.0 blue:230.0/255.0 alpha:1];
        [self.courseTypeHolderView addSubview:view];
    }
}

- (void)clickCourseTypeButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (self.selectedCourseButton == button) {
        return;
    }
    
    self.selectedCourseButton.selected = NO;
    button.selected = YES;
    self.selectedCourseButton = button;
    [self.moveLineView updateCenterX:button.center.x];
    NSInteger index = button.tag;
    
    if (index  >= _productInfo.courseTypeList.count) {
        return;
    }
    
    CourseType *type = [_productInfo.courseTypeList objectAtIndex:index];
    
    self.selectedCourseTypeId = type.courseTypeId;
    [self queryData];
    
    self.titleButton.selected = NO;
    self.courseTypeBackgroundHolderView.hidden = YES;
    
    [self updateTitleButton];
}

- (IBAction)touchDownCourseTypeBackgroundHolderView:(id)sender {
    self.titleButton.selected = NO;
    self.courseTypeBackgroundHolderView.hidden = YES;
}

- (void)updateAllViews
{
    [self updateTitleButton];
    [self updateCourseTypeHolderView];
    
    [self updateDateScrollView];
    
    [self updateViewsHeight];
    [self updatePromoteMessageLabel];
    
    [self updateProductScrollView];
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_venue_page_click_order_button];
    
    if ([UserManager isLogin]) {
        OrderListController *controller = [[OrderListController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tipsView dismiss];
}

- (void)updateViewsHeight
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [self.bottomHolderView updateOriginY:screenHeight - 64 - self.bottomHolderView.frame.size.height];
    
    [self.productHolderView updateHeight:screenHeight - 64 - self.productHolderView.frame.origin.y - _bottomHolderView.frame.size.height];
    
    [self.timeHolderView updateHeight:self.productHolderView.frame.size.height + 2 * 12];
}

- (void)updatePromoteMessageLabel
{
    if ([_productInfo.promoteMessage length] == 0 || self.isCardUser || [self hasSelectedCourtJoin]) {
        self.promoteMessageLabel.hidden = YES;
        [self.priceLabel updateCenterY:_submitButton.center.y];
    } else {
        self.promoteMessageLabel.hidden = NO;
        [self.priceLabel updateCenterY:_submitButton.center.y - 8];
        
        self.promoteMessageLabel.text = _productInfo.promoteMessage;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstTimeViewDidAppear == NO) {
        [self queryData];
    }
    self.isFirstTimeViewDidAppear = NO;
    
    [self queryNeedPay];
}

- (void)queryNeedPay
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        
        self.startTime = mach_absolute_time();
        [OrderService queryNeedPayOrderCount:self userId:user.userId];
        [UserService getMessageCountList:nil
                                  userId:user.userId
                                deviceId:[SportUUID uuid]];
    }
}

- (void)didQueryNeedPayOrderCount:(NSString *)status
                            count:(NSUInteger)count
                            order:(Order *)order
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.needPayOrder = order;
        
        if (order) {
            [self showRightTopRedPoint];
        } else {
            [self hideRightTopRedPoint];
        }
    }
}

- (void)updateDateScrollView
{
    __weak __typeof(self)weakSelf = self;
    [SelectCourtDateListView showViewInSuperView:self.dateHolderView dateList:self.dateList selectedDate:self.selectedDate didClickDateViewHandler:^(NSDate *date) {
        weakSelf.selectedDate = date;
        [weakSelf queryData];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.productScrollView) {
        [self.timeScrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y) animated:NO];
        [self.nameScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
    }
}

#pragma mark -
- (Product *)findProductWithProductId:(NSString *)productId
{
    return [self.productInfo.dayBookingInfo findProductWithProductId:productId];
}

- (Product *)findProduct:(NSDate *)date
                 courtId:(NSString *)courtId
                    time:(NSString *)time
{
    if (_productInfo.dayBookingInfo == nil){
        return nil;
    }
    Court *court = nil;
    for (Court *tmp in _productInfo.dayBookingInfo.courtList) {
        if ([tmp.courtId isEqualToString:courtId]) {
            court = tmp;
        }
    }
    if (court == nil) {
        return nil;
    }
    for (Product *tmp in court.productList) {
        if ([tmp.startTime isEqualToString:time]) {
            return tmp;
        }
    }
    return nil;
}

//更新时间轴
- (void)updateTimeScrollView
{
    self.timeScrollView = [SelectCourtTimeView showViewInSuperView:self.timeHolderView timeList:self.productInfo.timeList singleHeight:[SelectCourtProductView oneProductViewSize].height singleSpace:SPACE];
}

//更新场号轴
- (void)updateCourtScrollView:(DayBookingInfo *)dayBookingInfo
{
    self.nameScrollView = [SelectCourtNameView showViewInSuperView:self.courtNameHolderView dayBookingInfo:dayBookingInfo singleWidth:[SelectCourtProductView oneProductViewSize].width singleSpace:SPACE];
}

//刷新选择的场次
- (void)reloadSelectedProductList
{
    NSArray *tempList = [self.selectedProductList copy];
    
    //清空选择列表
    self.selectedProductList = [NSMutableArray array];
    
    //重新添加之前已经选择的场次
    for (Product *product in tempList) {
        Product *findProduct = [self findProductWithProductId:product.productId];
        if (findProduct
            && [findProduct canBuy]
            && self.productInfo.minHour != 2)
        {
            [self addToSelectedProductListWithProduct:findProduct animated:NO];
        }
    }
    
    //如果selectedProductList为空，则清空两小时起订的记录
    if ([self.selectedProductList count] <= 0) {
        self.twoHourProductIdsList = [NSMutableArray array];
    }
}

//更新场次的scrollview
- (void)updateProductScrollView
{
    [self updateTimeScrollView];
    [self updateCourtScrollView:self.productInfo.dayBookingInfo];
    
    self.productScrollView = [SelectCourtProductView showViewInSuperView:self.productHolderView dayBookingInfo:self.productInfo.dayBookingInfo timeList:self.productInfo.timeList singleSpace:SPACE isCardUser:self.isCardUser clickProductDelegate:self];
    self.productScrollView.delegate = self;
    
    
    [self reloadSelectedProductList];
    
    [self updateSelectedProductHolderView];
    
    [self updatePrice];
    [self changeTimeColorAndCourtColor];
    
    [self autoScrollToCurrentTime];
}

#pragma mark - SelectCourtProductViewDelegate
- (void)didClickProduct:(Product *)product {
    //有未支付订单
    if (_needPayOrder) {
        UnpaidOrderAlertView *alertView = [UnpaidOrderAlertView createUnpaidOrderAlertView];
        alertView.delegate = self;
        [alertView updateViewWithOrder:_needPayOrder];
        [alertView show];
        return;
    }
    
    //检查之前是否已经选择过
    BOOL isExists = [self isSelectedWithProductId:product.productId];
    
    BOOL isSelected = !isExists;
    
    //处理球局
    BOOL isHandleCourtJoin = ([self hasSelectedCourtJoin] || [product isCourtJoinProduct]);
    if (isHandleCourtJoin){
        [self handleCourtJoin:product isSelected:isSelected];
    }
    
    //如果当前不是球局product，才进行以下非球局处理
    if (![product isCourtJoinProduct]) {
    
        if (isSelected && [_selectedProductList count] >= 4 && !isHandleCourtJoin) {
            
            NSString *message = @"你选择的场次数太多啦，请分两次下单结算哦";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:DDTF(@"kOK") otherButtonTitles: nil];
            [alertView show];
            
        } else {
            
            if (isSelected) {
                [self addToSelectedProductListWithProduct:product animated:NO];
            } else {
                [self removeFromSelectedProductListWithProduct:product];
            }
            
            /*打包订场 与 两个小时起订 互斥*/
            
            //支持打包订场则处理打包订场
            if ([self isSupportGroup]) {
                [self checkGroup:product.productId isSelected:isSelected];
            }
            
            //处理两个小时起订情况
            else {
                [self handleMustTwoHour:product isSelected:isSelected];
            }
        }
    }
    
    [self updatePrice];
    [self changeTimeColorAndCourtColor];
    [self updateSelectedProductHolderView];
    [self updatePromoteMessageLabel];
}

#pragma mark -
//是否已经超时
- (BOOL)isTimeoutWithProduct:(Product *)product
{
    //判断是否已经过时
    /*
     DayBookingInfo *dayBookingInfo = _productInfo.dayBookingInfo;
     NSDate *selectDate = dayBookingInfo.date;
     
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     formatter.dateFormat = @"yyyy-MM-dd";
     NSString *timeString = [formatter stringFromDate:selectDate];
     
     
     NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:selectData];
     NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
     BOOL isToday = ([today day] == [otherDay day] &&
     [today month] == [otherDay month] &&
     [today year] == [otherDay year] &&
     [today era] == [otherDay era]);
     
     NSArray *timeValueList = [product.time componentsSeparatedByString:@":"];
     int hour = 0;
     int minute = 0;
     if ([timeValueList count] == 2) {
     [timeValueList objectAtIndex:0];
     [timeValueList objectAtIndex:1];
     }
     BOOL isExpired = NO;
     [today minute];
     
     if(isToday && [today hour] > product.time) { //is today
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"不能订已经过时的场地" delegate:nil cancelButtonTitle:DDTF(@"kOK") otherButtonTitles: nil];
     [alertView show];
     } else {
     */
    
    return NO;
}

- (Product *)productInSelectedList:(NSString *)productId
{
    for (Product *product in _selectedProductList) {
        if ([product.productId isEqualToString:productId]) {
            return product;
        }
    }
    return nil;
}

- (NSArray *)selectedProductViewValuesList
{
    NSMutableArray *resultList = [NSMutableArray array];
    
    NSMutableArray *hasDealIdList = [NSMutableArray array];
    for (Product *product in _selectedProductList) {
        ProductGroup *group = [self productGroupFromProductId:product.productId];
        if (group) {
            
            //判读是否已经处理过
            BOOL fundDeal = NO;
            for (NSString *oneId in hasDealIdList) {
                if ([oneId isEqualToString:product.productId]) {
                    fundDeal = YES;
                    break;
                }
            }
            
            //没处理过
            if (fundDeal == NO) {
                
                //找出开始时间、结束时间
                NSString *name = nil;
                NSString *minute = nil;
                int startHour = 0, endHour = 0;
                int index = 0;
                for (NSString *oneId in group.productIdList) {
                    
                    [hasDealIdList addObject:oneId];
                    
                    Product *temp = [self productInSelectedList:oneId];
                    
                    if (name == nil && temp) {
                        name = temp.courtName;
                        minute = temp.startTimeMinuteString;
                        startHour = temp.startTimeHour;
                        endHour = temp.startTimeHour + 1;
                    } else if (temp) {
                        startHour = MIN(startHour, temp.startTimeHour);
                        endHour = MAX(endHour, temp.startTimeHour + 1);
                    }
                    index ++;
                }
                
                NSString *value1 = [NSString stringWithFormat:@"%d:%@-%d:%@", startHour, minute, endHour, minute];
                NSString *value2 = [NSString stringWithFormat:@"%@%@", name, (endHour - startHour > 1 ? @"打包时段" : @"")];
                [resultList addObject:@[value1,value2]];
            }
            
        } else {
            [hasDealIdList addObject:product.productId];
            NSString *value1 = [product startTimeToEndTime];
            NSString *value2 = (product.courtName ? product.courtName : @"");
            
            [resultList addObject:@[value1,value2]];
        }
    }
    return resultList;
}

- (void)updateSelectedProductHolderView
{
    if ([_selectedProductList count] > 0) {
        self.exampleHolderView.hidden = YES;
        self.selectedProductHolderView.hidden = NO;
        
        for (UIView *subView in self.selectedProductHolderView.subviews) {
            [subView removeFromSuperview];
        }
        
        if ([self hasSelectedCourtJoin]) {
            [self addCourtJoinViewToSelectedProductHolderView];
        } else {
            [self addViewsToSelectedProductHolderView];
        }
        
    } else {
        self.exampleHolderView.hidden = NO;
        self.selectedProductHolderView.hidden = YES;
    }
}

- (void)addViewsToSelectedProductHolderView {
    NSArray *list = [self selectedProductViewValuesList];
    
    int index = 0;
    CGFloat x, space = 6;
    CGFloat startX = ([UIScreen mainScreen].bounds.size.width - (([SelectedProductView defaultSize].width + space )* [list count] - space)) / 2;
    for (NSArray *one in list) {
        NSString *value1 = [one objectAtIndex:0];
        NSString *value2 = [one objectAtIndex:1];
        
        x = startX + index * ([SelectedProductView defaultSize].width + space);
        SelectedProductView *view = [SelectedProductView createSelectedProductView];
        [view updateOriginX:x];
        [view updateViewWithValue1:value1 value2:value2];
        [self.selectedProductHolderView addSubview:view];
        index ++;
    }
}

- (void)addCourtJoinViewToSelectedProductHolderView  {
    CourtJoin *cj = [self currentSelectedCourtJoin];
    SelectedCourtJoinProductView *view = [SelectedCourtJoinProductView createViewWithCourtJoin:cj];
    CGSize size = view.frame.size;
    CGSize superSize = self.selectedProductHolderView.frame.size;
    [view updateOriginX:(superSize.width - size.width)/2];
    [view updateOriginY:(superSize.height - size.height)/2];
    [self.selectedProductHolderView addSubview:view];
}

- (void)changeTimeColorAndCourtColor
{
    [self.timeScrollView changeColorWithSelectedProductList:self.selectedProductList];
    [self.nameScrollView changeColorWithSelectedProductList:self.selectedProductList];
}

#pragma mark - 处理打包
//根据productId返回productGroup
- (ProductGroup *)productGroupFromProductId:(NSString *)productId
{
    DayBookingInfo *dayBookingInfo = _productInfo.dayBookingInfo;
    
    ProductGroup *foundProductGroup = nil;
    for (Court *court in dayBookingInfo.courtList) {
        for (ProductGroup *group in court.productGroupList) {
            for (NSString *oneProductId in group.productIdList) {
                if ([oneProductId isEqualToString:productId]) {
                    foundProductGroup = group;
                    break;
                }
            }
            if (foundProductGroup) {
                break;
            }
        }
        if (foundProductGroup) {
            break;
        }
    }
    
    return foundProductGroup;
}

//是否支持打包订场
- (BOOL)isSupportGroup
{
    for (Court *court in self.productInfo.dayBookingInfo.courtList) {
        if ([court.productGroupList count] > 0) {
            return YES;
        }
    }
    return NO;
}

//检查是否打包场次。如果是打包，则选择或取消包内的其他场次。
- (void)checkGroup:(NSString *)productId isSelected:(BOOL)isSelected
{
    ProductGroup *foundProductGroup = [self productGroupFromProductId:productId];
    
    if (foundProductGroup) {
        //查找同组内其他的productId
        NSMutableArray *sameGroupProductIdList = [NSMutableArray array];
        for (NSString *oneProductId in foundProductGroup.productIdList) {
            if ([oneProductId isEqualToString:productId] == NO) {
                [sameGroupProductIdList addObject:oneProductId];
            }
        }
        
        //查找同组内其他的product
        NSMutableArray *productList = [NSMutableArray array];
        for (NSString *oneProductId in sameGroupProductIdList) {
            Product *one = [self findProductWithProductId:oneProductId];
            if (one) {
                [productList addObject:one];
            }
        }
        
        if (isSelected) { //选中
            for (Product *one in productList) {
                if (one.status == ProductStatusCanOrder) {
                    [self addToSelectedProductListWithProduct:one animated:YES];
                }
            }
            
        } else { //取消选中
            for (Product *one in productList) {
                [self removeFromSelectedProductListWithProduct:one];
            }
        }
    }
}

#pragma mark - 处理两小时起订
//处理两个小时起预订的情况
- (void)handleMustTwoHour:(Product *)product isSelected:(BOOL)isSelected
{
    //有配置两个小时起预订
    if (self.productInfo.minHour == 2) {
        
        //选中
        if (isSelected) {
            
            //查找出product所属的场地
            Court *currentCourt = nil;
            for (Court *court in self.productInfo.dayBookingInfo.courtList) {
                if ([court.courtId isEqualToString:product.courtId]) {
                    currentCourt = court;
                    break;
                }
            }
            
            //找出前一个场次、后一个场次
            Product *beforeProduct = nil;
            Product *afterProduct = nil;
            int index = -1;
            for (Product * one in currentCourt.productList) {
                index ++;
                if ([one.productId isEqualToString:product.productId]) {
                    break;
                }
            }
            if (index >= 0) {
                if (index - 1 >= 0) {
                    beforeProduct = [currentCourt.productList objectAtIndex:index - 1];
                }
                if (index + 1 < [currentCourt.productList count]) {
                    afterProduct = [currentCourt.productList objectAtIndex:index + 1];
                }
            }
            
            //如果后一个场次可选
            if (afterProduct
                && afterProduct.status == ProductStatusCanOrder
                && ![self isSelectedWithProductId:afterProduct.productId]) {
                
                [self addToSelectedProductListWithProduct:afterProduct animated:YES];
                [self recordTwoHourProductIds:@[product.productId, afterProduct.productId]];
                
            }
            //如果前一个场次可选
            else if (beforeProduct
                     && beforeProduct.status == ProductStatusCanOrder
                     && ![self isSelectedWithProductId:beforeProduct.productId]) {
                
                [self addToSelectedProductListWithProduct:beforeProduct animated:YES];
                [self recordTwoHourProductIds:@[product.productId, beforeProduct.productId]];
                
            }
            
            //如果前后都不可选,则把product也取消选择
            else {
                [self removeFromSelectedProductListWithProduct:product];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"不足2小时，无法预订" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                [alertView show];
            }
        }
        
        //取消选中
        else {
            NSArray *productIds = [self twoHourProductIdsWithProductId:product.productId];
            for (NSString *productId in productIds) {
                Product *one = [self productInSelectedList:productId];
                [self removeFromSelectedProductListWithProduct:one];
            }
        }
    }
}

//记录两个小时起订的成对选择
- (void)recordTwoHourProductIds:(NSArray *)productIds
{
    if (self.twoHourProductIdsList == nil) {
        self.twoHourProductIdsList = [NSMutableArray array];
    }
    [self.twoHourProductIdsList addObject:productIds];
}

//查找两个小时起订所选择的所有productId
- (NSArray *)twoHourProductIdsWithProductId:(NSString *)productId
{
    NSArray *foundList = nil;
    for (NSArray *subList in self.twoHourProductIdsList) {
        for (NSString *oneId in subList) {
            if ([oneId isEqualToString:productId]) {
                foundList = subList;
                break;
            }
        }
    }
    return foundList;
}

//取消记录两个小时起订的成对选择
- (void)cancelRecordTwoHourWithProductId:(NSString *)productId
{
    NSArray *foundList = [self twoHourProductIdsWithProductId:productId];
    [self.twoHourProductIdsList removeObject:foundList];
}

#pragma mark - 处理球局
- (void)handleCourtJoin:(Product *)product isSelected:(BOOL)isSelected {
    
    //product属于球局
    if ([product isCourtJoinProduct]) {
        
        [self clearSelectedProductList];
        
        if (isSelected) {
            [self addToSelectedProductListWithProduct:product animated:NO];
            
            [self addOtherProductsOfSameCourtJoin:product];
        }
    } else if ([self hasSelectedCourtJoin]){
        [self clearSelectedProductList];
    }
}

- (void)addOtherProductsOfSameCourtJoin:(Product *)product {
    NSArray *others = [self.productInfo.dayBookingInfo otherProductsOfSameCourtJoinWithProduct:product];
    for (Product *one in others) {
        [self addToSelectedProductListWithProduct:one animated:YES];
    }
}

- (BOOL)hasSelectedCourtJoin {
    for (Product *product in self.selectedProductList) {
        if ([product isCourtJoinProduct]) {
            return YES;
        }
    }
    return NO;
}

- (IBAction)clickCourtJoinHelpButton:(id)sender {
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:[BaseConfigManager defaultManager].courtJoinInstructionUrl title:@"什么是球局"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
//是否已经选择
- (BOOL)isSelectedWithProductId:(NSString *)productId
{
    BOOL isExists = NO;
    for (Product *one in self.selectedProductList) {
        if ([one.productId isEqualToString:productId]) {
            isExists = YES;
            break;
        }
    }
    return isExists;
}

//添加选择
- (void)addToSelectedProductListWithProduct:(Product *)product animated:(BOOL)animated
{
    if ([self isSelectedWithProductId:product.productId]) {
        return;
    }
    
    [self.selectedProductList addObject:product];
    
    [self.productScrollView selectedWithProductId:product.productId animated:animated];
}

//移除选择
- (void)removeFromSelectedProductListWithProduct:(Product *)product
{
    if ([self.selectedProductList containsObject:product]) {
        [self.selectedProductList removeObject:product];
    }
    
    [self.productScrollView disSelectedWithProductId:product.productId];
}

//清空选择列表
- (void)clearSelectedProductList
{
    NSArray *temp = [self.selectedProductList copy];
    for (Product *product in temp) {
        [self removeFromSelectedProductListWithProduct:product];
    }
}

- (CourtJoin *)currentSelectedCourtJoin
{
    if ([self.selectedProductList count] > 0) {
        Product *product = [self.selectedProductList objectAtIndex:0];
        CourtJoin *cj = [self.productInfo.dayBookingInfo courtJoinWithProduct:product];
        return cj;
    } else {
        return nil;
    }
}

- (void)updatePrice
{
    float totalPrice = 0;
    
    if ([self hasSelectedCourtJoin]) {
        totalPrice = [self currentSelectedCourtJoin].price;
    } else {
        for (Product *product in _selectedProductList) {
            totalPrice += product.price;
        }
    }

    if ([self hasSelectedCourtJoin]) {
        self.priceLabel.text = [NSString stringWithFormat:@"%@元  立即加入", [PriceUtil toValidPriceString:totalPrice]];
    } else if (totalPrice > 0 && self.isCardUser == NO) {
        self.priceLabel.text = [NSString stringWithFormat:@"%@元  提交订单", [PriceUtil toValidPriceString:totalPrice]];
    } else if ([_selectedProductList count] == 0) {
        self.priceLabel.text = @"请选择场次";
    } else {
        self.priceLabel.text = @"提交订单";
    }
}

- (IBAction)clickSubmitButton:(id)sender {
    if ([_selectedProductList count] == 0) {
        [SportPopupView popupWithMessage:@"请选择场次"];
        return;
    }
    
    if (_needPayOrder) {
        UnpaidOrderAlertView *alertView = [UnpaidOrderAlertView createUnpaidOrderAlertView];
        alertView.delegate = self;
        [alertView updateViewWithOrder:_needPayOrder];
        [alertView show];
        return;
    }
    
    if (![UserManager isLogin]) {
        FastLoginController *controller = [[FastLoginController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    if ([self hasSelectedCourtJoin]) {
        CourtJoin *cj = [self currentSelectedCourtJoin];
        CourtJoinDetailController *controller = [[CourtJoinDetailController alloc] initWithCourtJoinId:cj.courtJoinId];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    Order *order = [[Order alloc] init];
    order.categoryId = _productInfo.categoryId;
    order.categoryName =  _productInfo.categoryName;
    order.businessId = _productInfo.businessId;
    order.businessName = _productInfo.busienssName;
    order.businessAddress = _productInfo.address;
    DayBookingInfo *dayBookingInfo = _productInfo.dayBookingInfo;
    order.useDate = dayBookingInfo.date;
    order.productList = [NSArray arrayWithArray:_selectedProductList];
    double totalPrice = 0;
    for (Product * product in order.productList) {
        totalPrice += product.price;
    }
    order.amount = totalPrice;
    
    BusinessOrderConfirmController *controller = [[BusinessOrderConfirmController alloc] initWithOrder:order];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 处理未支付订单

#define TAG_ALERT_VIEW_CANCEL_ORDER 2014121201
- (void)didClickUnpaidOrderAlertViewPayButton
{
    [MobClickUtils event:umeng_event_venue_page_show_unpaid_order label:@"支付"];
    
    if (is_expire(self.startTime, _needPayOrder.payExpireLeftTime)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你的未支付订单已超时，点击确定取消订单" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERT_VIEW_CANCEL_ORDER;
        [alertView show];
        return;
    }
    
    PayController *controller = [[PayController alloc] initWithOrder:_needPayOrder];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_VIEW_CANCEL_ORDER) {
        [self cancelOrder];
    }
}

- (void)cancelOrder
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"正在取消订单..." hasMask:YES];
    [OrderService cancelOrder:self
                        order:_needPayOrder
                       userId:user.userId];
}

- (void)didClickUnpaidOrderAlertViewCancelButton
{
    [MobClickUtils event:umeng_event_venue_page_show_unpaid_order label:@"取消"];
    [self cancelOrder];
}

- (void)didCancelOrder:(NSString *)status orderId:(NSString *)orderId
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"取消成功"];
        self.needPayOrder = nil;
    } else {
        [SportProgressView dismissWithError:@"取消失败,请重试"];
    }
    
    [self queryNeedPay];
    [self queryData];
}

@end
