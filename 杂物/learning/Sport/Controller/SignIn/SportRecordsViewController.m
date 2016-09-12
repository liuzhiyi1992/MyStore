//
//  SportRecordsViewController.m
//  Sport
//
//  Created by lzy on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportRecordsViewController.h"
#import "SignInRecordsTableViewCell.h"
#import "UserManager.h"
#import "SignInService.h"
#import "SignInRecordsCabinetView.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIView+Utils.h"
#import "SignInWeeklyModel.h"
#import "UIScrollView+SportRefresh.h"
#import "SportPopupView.h"

int const TAG_SIGN_IN_RECORDS_BASIC = 11;
int const PAGE_START = 1;
int const MAX_ITEM_NUM = 20;
int const TABLEVIEW_HEADER_LAST_VIEW_BOTTOM_MARGIN = 10;

@interface SportRecordsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *signInTipsLabel;
@property (weak, nonatomic) IBOutlet UITableView *recordsTableView;
@property (weak, nonatomic) IBOutlet UIView *signInRecordsHolderView;
@property (strong, nonatomic) NSMutableArray *diaryArray;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UILabel *wisdomContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *wisdomAuthorLabel;
@property (weak, nonatomic) IBOutlet UIView *wisdomHolderView;
@property (weak, nonatomic) IBOutlet UIView *tableViewHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *tableViewHeaderLastView;


@property (assign, nonatomic) int page;

@end

@implementation SportRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"运动记录";
    
    [self configureView];
    self.page = PAGE_START;
    [self queryDiaryWithPage:_page];
    [self querySignInRecord];
    
    [MobClickUtils event:umeng_event_show_sign_in_record label:@"运动记录页"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = PAGE_START;
    [self queryDiaryWithPage:_page];
}

- (void)configureView {
    _maskView.hidden = NO;
    [_recordsTableView registerNib:[UINib nibWithNibName:@"SignInRecordsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SignInRecordsTableViewCell"];
    [self.recordsTableView addPullUpLoadMoreWithTarget:self action:@selector(queryMoreData)];
    
}

- (void)queryMoreData {
    [self queryDiaryWithPage:++_page];
}

- (void)querySignInRecord {
    __weak __typeof(self) weakSelf = self;
    [SignInService getSignInRecordsWithUserId:[[UserManager defaultManager] readCurrentUser].userId completion:^(NSString *status, NSString *msg, NSArray *weeklyModelArray, NSString *signInTips, NSString *wisdomAuthor, NSString *wisdomContent) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            _signInTipsLabel.text = signInTips;
            if (wisdomContent.length <= 0) {
                [self removeWisdomView];
            } else {
                _wisdomAuthorLabel.text = [NSString stringWithFormat:@"——%@", wisdomAuthor];
                _wisdomContentLabel.text = wisdomContent;
            }
            [weakSelf configureSignInRecordsWithWeekArray:weeklyModelArray];
            weakSelf.maskView.hidden = YES;
        } else {
            [self removeWisdomView];
            [SportPopupView popupWithMessage:msg];
        }
    }];
}

- (void)queryDiaryWithPage:(int)page {
    __weak __typeof(self) weakSelf = self;
    [SignInService getSignInDiaryListWithUserId:[[UserManager defaultManager] readCurrentUser].userId page:page count:MAX_ITEM_NUM completion:^(NSString *status, NSString *msg, NSDictionary *data) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            //日志列表
            NSArray *diaryArray = [data validArrayValueForKey:PARA_DIARY];
            if (diaryArray.count > 0) {
                if (weakSelf.page == PAGE_START) {
                    weakSelf.diaryArray = [NSMutableArray arrayWithArray:diaryArray];
                } else {
                    [weakSelf.diaryArray addObjectsFromArray:diaryArray];
                }
                [weakSelf.recordsTableView reloadData];
                
                if (diaryArray.count >= MAX_ITEM_NUM) {
                    [weakSelf.recordsTableView canLoadMore];
                } else {
                    [weakSelf.recordsTableView canNotLoadMore];
                }
                [weakSelf.recordsTableView endLoad];
            }
        }
    }];
}

- (void)configureSignInRecordsWithWeekArray:(NSArray *)weekArray {
    for (int i = 0; i < weekArray.count; i++) {
        SignInWeeklyModel *week = weekArray[i];
        SignInRecordsCabinetView *cabinetView = [_signInRecordsHolderView viewWithTag:TAG_SIGN_IN_RECORDS_BASIC+i];
        
        NSString *signImageCouponName = @"";
        NSString *signImageIntegralName = @"";
        if ([week.status isEqualToString:@"1"]) {
            //已打卡
            cabinetView.backgroundImage = [UIImage imageNamed:@"sign_in_records_bright"];
            cabinetView.numberLabel.textColor = [UIColor hexColor:@"bfc9ff"];
            cabinetView.weekNameLabel.textColor = [UIColor hexColor:@"5b73f2"];
            cabinetView.rmbImageView.image = [UIImage imageNamed:@"sign_in_logo_bright"];
            signImageCouponName = @"sign_in_rmb_sign_bright";
            signImageIntegralName = @"sign_in_integral_bright";
        } else {
            cabinetView.backgroundImage = [UIImage imageNamed:@"sign_in_records_dark"];
            cabinetView.numberLabel.textColor = [UIColor hexColor:@"dddddd"];
            cabinetView.weekNameLabel.textColor = [UIColor hexColor:@"666666"];
            cabinetView.rmbImageView.image = [UIImage imageNamed:@"sign_in_logo_dark"];
            signImageCouponName = @"sign_in_rmb_sign_dark";
            signImageIntegralName = @"sign_in_integral_dark";
        }
        
        NSString *signImageName = @"sign_in_integral_bright";
        if (week.coupon.length > 0) {
            //优先代金券
            cabinetView.numberLabel.text = week.coupon;
            cabinetView.rmbImageView.hidden = NO;
            signImageName = signImageCouponName;
        } else {
            //积分
            cabinetView.numberLabel.text = week.integral;
            cabinetView.rmbImageView.hidden = YES;
            signImageName = signImageIntegralName;
        }
        cabinetView.rewardSignImageView.image = [UIImage imageNamed:signImageName];
        
        if (cabinetView.numberLabel.text.length > 1) {
            //两位数字
            cabinetView.numberLabel.font = [UIFont boldSystemFontOfSize:[cabinetView.numberLabel.font pointSize]-4];
            cabinetView.rewardSignBottomConstraint.constant += 2;
        }
        cabinetView.weekNameLabel.text = week.weekName;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _diaryArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [tableView fd_heightForCellWithIdentifier:@"SignInRecordsTableViewCell" configuration:^(id cell) {
        //配置
        [cell updateCellWithDataDict:_diaryArray[indexPath.row]];
    }];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SignInRecordsTableViewCell";
    SignInRecordsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [SignInRecordsTableViewCell createCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell updateCellWithDataDict:_diaryArray[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)removeWisdomView {
    [_tableViewHeaderView updateHeight:_tableViewHeaderView.frame.size.height - _wisdomHolderView.frame.size.height];
    [_recordsTableView beginUpdates];
    [_recordsTableView setTableHeaderView:_tableViewHeaderView];
    [_recordsTableView endUpdates];
    [_wisdomHolderView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
