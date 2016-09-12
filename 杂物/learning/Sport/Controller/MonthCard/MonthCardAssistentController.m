//
//  MonthCardAssistentController.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardAssistentController.h"
#import "UIScrollView+SportRefresh.h"
#import "UserManager.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MonthCardRechargeController.h"
#import "SportHistoryController.h"
#import "DateUtil.h"
#import "BusinessMapController.h"
#import "CourseDetailController.h"
#import "MonthCardCourse.h"

@interface MonthCardAssistentController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *unfoldCellList;
@property (assign, nonatomic) BOOL isShow;
@property (weak, nonatomic) IBOutlet UIView *noticeView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MonthCard *card;
@property (weak, nonatomic) IBOutlet UITextView *noticeTextView;
@end

@implementation MonthCardAssistentController
-(NSMutableArray *)unfoldCellList
{
    if (_unfoldCellList == nil) {
        _unfoldCellList = [NSMutableArray array];
    }
    
    return _unfoldCellList;
}

-(id)initWithIsShowExpire:(BOOL)isShow
{
    self = [super init];
    if (self) {
        self.isShow = isShow;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"运动助手";
    [self createRightTopButton:@"运动记录"];
    
    //设置下拉更新
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];

    [self.tableView beginReload];

    self.tableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[MonthCardAssistentUnfoldCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[MonthCardAssistentUnfoldCell getCellIdentifier]];
    
    cellNib = [UINib nibWithNibName:[MonthCardAssistentFoldCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[MonthCardAssistentFoldCell getCellIdentifier]];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.scrollsToTop = YES;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        self.tableView.estimatedRowHeight = 110.0f;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //总是保持最新的card信息
    self.card = [[UserManager defaultManager] readCurrentUser].monthCard;
    self.isShow = NO;

    int restDay = [DateUtil expiredaysFromNow:self.card.endTime];

    if (restDay >= 0 && restDay <= 7) {
        self.isShow = YES;
        self.noticeView.hidden = NO;
        self.noticeTextView.text = [NSString stringWithFormat:@"亲，您的会员还有%d天到期了\n想继续愉快的玩耍？点击续费吧～",restDay];
    } else {
        self.noticeView.hidden = YES;
    }
    
    [super viewWillAppear:animated];
}

-(void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_month_sports_assistant_click_record];
    SportHistoryController *controller = [[SportHistoryController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//下拉刷新
- (void)beginRefreshing
{
    [self.tableView beginReload];
}

- (void)loadNewData
{
    [self queryData];
}


- (void)queryData
{
    self.unfoldCellList = [NSMutableArray array];
    
    [MonthCardService sportAssistant:self userId:[[UserManager defaultManager] readCurrentUser].userId];
}

-(void) didGetSportAssistant:(NSArray *)list status:(NSString *)status msg:(NSString *)msg
{
    [self.tableView endLoad];

    if ([status isEqualToString:STATUS_SUCCESS]) {

        self.dataList = [NSMutableArray arrayWithArray:list];
    }
    
    if ([list count] == 0) {
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        
        if(_isShow == YES)
        {
            frame.size.height -= self.noticeView.frame.size.height;
        }
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"暂无预约记录"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
    
    [self.tableView reloadData];
}

- (void)didClickNoDataViewRefreshButton
{
    [self loadNewData];
}

//tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ([self isUnfoldCell:indexPath]) {
        NSString *identifier = [MonthCardAssistentUnfoldCell getCellIdentifier];
        cell = (MonthCardAssistentUnfoldCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        [(MonthCardAssistentUnfoldCell *)cell setDelegate:self];

    }else {
        NSString *identifier = [MonthCardAssistentFoldCell getCellIdentifier];
         cell = [tableView dequeueReusableCellWithIdentifier:identifier];
         [(MonthCardAssistentFoldCell *)cell setDelegate:self];
    }

    [self configureCell:cell
           atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataList count] == 0) {
        return;
    }

    MonthCardAssistent *assis = [self.dataList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    
    if ([self isUnfoldCell:indexPath]) {
        [(MonthCardAssistentUnfoldCell *)cell updateCell:assis
                    indexPath:indexPath
                    isLast:isLast];
    } else {
        [(MonthCardAssistentFoldCell *)cell updateCell:assis
                                             indexPath:indexPath
                                                isLast:isLast];
    }
    
    cell.fd_enforceFrameLayout = NO;
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isUnfoldCell:indexPath]) {
        NSString *identifier;
        identifier = [MonthCardAssistentUnfoldCell getCellIdentifier];
        
        return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(MonthCardAssistentUnfoldCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    } else {
        NSString *identifier;
        identifier = [MonthCardAssistentFoldCell getCellIdentifier];
        
        return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(MonthCardAssistentFoldCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
}

- (BOOL)isUnfoldCell:(NSIndexPath *)indexPath
{
    for (NSIndexPath *unfoldIndex in self.unfoldCellList) {
        if (unfoldIndex.row == indexPath.row) {
            return YES;
        }
    }
    
    if (indexPath.row == 0) {
        [self.unfoldCellList addObject:indexPath];
        return YES;
    }
    
    return NO;
}

-(void)didClickUnfoldButton:(NSIndexPath *)indexPath
{
    if ([self isUnfoldCell:indexPath]) {
        return;
    } else {
        [MobClickUtils event:umeng_event_month_sports_assistant_click_notic];
        
        [self.unfoldCellList addObject:indexPath];
        NSArray *unfoldArray = @[indexPath];
        [self.tableView reloadRowsAtIndexPaths:unfoldArray withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)didClickAddressButtonWithLatitude:(double)latitude
                               longitude:(double)longitude
                            businessName:(NSString *)businessName
                         businessAddress:(NSString *)businessAddress
{
    [MobClickUtils event:umeng_event_month_sports_assistant_click_address];
    
    BusinessMapController *controller = [[[BusinessMapController alloc] init]
                                         initWithLatitude:latitude
                                         longitude:longitude
                                         businessName:businessName
                                         businessAddress:businessAddress
                                         parkingLotList:nil
                                        businessId:nil
                                         categoryId:nil
                                         type:0];
    
    [self.navigationController pushViewController:controller animated:YES];

}

-(void)didClickCourseButtonWithCourse:(MonthCardCourse *)course
{
    [MobClickUtils event:umeng_event_month_sports_assistant_click_introduce];
    
    CourseDetailController *controller = [[CourseDetailController alloc]init];
    controller.course = course;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickRechargeButton:(id)sender {
    [MobClickUtils event:umeng_event_month_sports_assistant_click_dead_line];
    
    MonthCardRechargeController *controller = [[MonthCardRechargeController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickCloseNotice:(id)sender {
    [MobClickUtils event:umeng_event_month_sports_assistant_click_dead_line_close];
    
    self.noticeView.hidden = YES;
}





@end
