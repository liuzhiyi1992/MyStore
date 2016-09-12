//
//  ManageActivityController.m
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ManageActivityController.h"
#import "ActivityPromise.h"
#import "UIView+Utils.h"
#import "Activity.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "UserInfoController.h"
#import "SportPopupView.h"
#import "ActivityDetailController.h"

@interface ManageActivityController ()
@property (strong, nonatomic) Activity *myCreateActivity;
@property (strong, nonatomic) NSMutableArray *myPromiseActivityList;
@property (assign, nonatomic) BOOL isSuccessLoadMyCreate;
@property (assign, nonatomic) BOOL isSuccessLoadMyPromise;
@property (assign, nonatomic) ManageActivityType type;
@property (strong, nonatomic) NSIndexPath *myPromiseActivityIndexPath;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@end

@implementation ManageActivityController


- (void)viewDidUnload {
    [self setMyCreateActivityTableView:nil];
    [self setMyPromiseActivityTableView:nil];
    [self setMyCreateStatusImageView:nil];
    [self setMyCreateCategoryLabel:nil];
    [self setMyCreateDateLabel:nil];
    [self setMyCreateStartTimeLabel:nil];
    [self setMyCreateAddressLabel:nil];
    [self setMyCreatePromiseEndTimeLabel:nil];
    [self setMyCreateCancelButton:nil];
    [self setMyCreateEnterRoomChatButton:nil];
    [self setMyCreatePromiseCountLabel:nil];
    [self setMyCreateActivityPeopleCountLabel:nil];
    [self setMyCreateAgreeCountLabel:nil];
    [self setMyCreateNeedCountLabel:nil];
    [self setMyCreateButton:nil];
    [self setMyPromiseButton:nil];
    [self setMoveLineView:nil];
    [self setMyCreateBackgroundImageView1:nil];
    [self setMyCreateBackgroundImageView2:nil];
    [self setTipsBackgroundImageView:nil];
    [self setMyCreateActivityDetailButton:nil];
    [super viewDidUnload];
}

- (instancetype)initWithType:(ManageActivityType)type
{
    self = [super init];
    if (self) {
        [self.moveLineView updateWidth:[[UIApplication sharedApplication]keyWindow].frame.size.width/2];
        self.type = type;
    }
    return self;
}

#define TAG_ALERT_VIEW_CANCEL  2014050402
#define TAG_ALERT_VIEW_MY_PROMISE_CANCEL 2014050601
- (IBAction)clickCancelActivityButton:(id)sender {
    NSString *message = nil;
    if ([self hasAgreePromisssInMyCreateActivity]) {
        message = @"此时取消会影响你的赴约率，确定要取消活动?";
    } else {
        message = @"确定要取消活动?";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"否"
                                              otherButtonTitles:@"是", nil];
    alertView.tag = TAG_ALERT_VIEW_CANCEL;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    if (alertView.tag == TAG_ALERT_VIEW_CANCEL) {
        [SportProgressView showWithStatus:@"更新中..."];
        User *user = [[UserManager defaultManager] readCurrentUser];
        ActivityStatus status = ([self hasAgreePromisssInMyCreateActivity] ? ActivityStatusCancelAfterAgreeUser :  ActivityStatusCancel);
        [ActivityService updateActivityStatus:self
                                   activityId:_myCreateActivity.activityId
                                       userId:user.userId
                                       status:status];
    } else if (alertView.tag == TAG_ALERT_VIEW_MY_PROMISE_CANCEL) {
        [self myPromiseCancel];
    }
}

- (void)didUpdateActivityStatus:(NSString *)status activityId:(NSString *)activityId activityStatus:(int)activityStatus
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"更新成功"];
        //self.myCreateActivity.stauts = activityStatus;
        self.myCreateActivity = nil;
        [self reloadMyCreateActivity];
    } else {
        [SportProgressView dismissWithError:@"更新失败"];
    }
}

- (IBAction)clickRoomChatButton:(id)sender {
//    if ([self hasAgreePromisssInMyCreateActivity]) {
//        ChatController *controller = [[ChatController alloc] initWithActivityId:_myCreateActivity.activityId
//                                                                 activityUserId:_myCreateActivity.userId];
//        [self.navigationController pushViewController:controller animated:YES];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你的活动还没有参与者，还不能群聊，去邀请好友来参与吧" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alertView show];
//    }
}

- (IBAction)clickCreateActivityDetailButton:(id)sender {
    ActivityDetailController *controller = [[ActivityDetailController alloc] initWithActivityId:_myCreateActivity.activityId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

#define TAG_STATUS_IMAGE_VIEW_START  20
- (void)toPointIndex:(int)index
{
    for (int i = 0 ; i <  3; i ++) {
        UIImageView *iv = (UIImageView *)[self.myCreateActivityTableView.tableHeaderView viewWithTag:TAG_STATUS_IMAGE_VIEW_START + i];
        if (i <= index) {
            [iv setImage:[SportImage activityStatusDot2Image]];
        } else {
            [iv setImage:[SportImage activityStatusDot1Image]];
        }
    }
}

- (BOOL)hasAgreePromisssInMyCreateActivity
{
    BOOL found = NO;
    for (ActivityPromise *promise in _myCreateActivity.promiseList) {
        if (promise.status == ActivityPromiseStatusAgreed) {
            found = YES;
            break;
        }
    }
    return found;
}

- (void)updateStatus
{
    if ([self hasAgreePromisssInMyCreateActivity]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *todayString = [formatter stringFromDate:[NSDate date]];
        NSString *statrString = [formatter stringFromDate:_myCreateActivity.startTime];
        if ([todayString isEqualToString:statrString]) {
            [self toPointIndex:2];
        } else {
            [self toPointIndex:1];
        }
    } else {
        [self toPointIndex:0];
    }
}

- (void)updateMyActivityHeader
{
    if (_myCreateActivity == nil) {
        self.myCreateActivityTableView.tableHeaderView.hidden = YES;
        return;
    } else {
        self.myCreateActivityTableView.tableHeaderView.hidden = NO;
    }
    
    [self updateStatus];
    
    self.myCreateCategoryLabel.text = _myCreateActivity.proName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    self.myCreateDateLabel.text = [NSString stringWithFormat:@"发布于%@", [formatter stringFromDate:_myCreateActivity.createTime]];
    
    self.myCreateStartTimeLabel.text = [formatter stringFromDate:_myCreateActivity.startTime];
    self.myCreateAddressLabel.text = _myCreateActivity.address;
    
    if (_myCreateActivity.promiseEndTime == nil) {
        self.myCreatePromiseEndTimeLabel.text = @"";
    } else {
        self.myCreatePromiseEndTimeLabel.text = [NSString stringWithFormat:@"截止时间 %@", [formatter stringFromDate:_myCreateActivity.promiseEndTime]];
    }
    
    self.myCreatePromiseCountLabel.text = [NSString stringWithFormat:@"%d人应约", (int)[_myCreateActivity.promiseList count]];
    NSUInteger activityPeopleCount = _myCreateActivity.peopleNumber;
    int agreeCount = [_myCreateActivity agreePromiseCount];
    self.myCreateActivityPeopleCountLabel.text = [NSString stringWithFormat:@"需要%d人", (int)activityPeopleCount - 1];
    self.myCreateAgreeCountLabel.text = [NSString stringWithFormat:@"已选%d人", (int)agreeCount];
    self.myCreateNeedCountLabel.text = [NSString stringWithFormat:@"还需%d人", activityPeopleCount - 1   > agreeCount ?(int)activityPeopleCount - 1 - agreeCount:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"活动管理";
    
    [self.myCreateBackgroundImageView1 setImage:[SportImage orderBackgroundTopImage]];
    [self.myCreateBackgroundImageView2 setImage:[SportImage orderBackgroundTopImage]];
    
    [self.myCreateCancelButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    [self.myCreateEnterRoomChatButton setBackgroundImage:[SportImage greenButtonImage] forState:UIControlStateNormal];
    [self.myCreateActivityDetailButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    if (_type == ManageActivityCreate) {
        [self clickMyCreateButton:_myCreateButton];
    } else {
        [self clickMyPromiseButton:_myPromiseButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)queryMyCreateData
{
    self.tipsBackgroundImageView.hidden = YES;
    [SportProgressView showWithStatus:@"正在加载..."];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [ActivityService queryActivityList:self
                                  type:ActivityListTypeMyCreate
                                userId:user.userId
                        activityStatus:nil
                                 proId:nil
                               actName:nil
                              latitude:0
                             longitude:0
                                  sort:nil
                                  page:1
                                 count:1];
}

- (void)queryMyPromiseData
{
    self.tipsBackgroundImageView.hidden = YES;
    [SportProgressView showWithStatus:@"正在加载..."];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [ActivityService queryActivityList:self
                                  type:ActivityListTypeMyPromise
                                userId:user.userId
                        activityStatus:nil
                                 proId:nil
                               actName:nil
                              latitude:0
                             longitude:0
                                  sort:nil
                                  page:1
                                 count:2];
}

//TEST DATA测试数据
//- (void)addPromiseTestData
//{
//    NSMutableArray *mu = [NSMutableArray array];
//    for (int i = 0; i < 10; i ++) {
//        ActivityPromise *promise = [[[ActivityPromise alloc] init] autorelease];
//        promise.promiseId = [NSString stringWithFormat:@"%d",     1000  + i];
//        promise.promiseUserId = [NSString stringWithFormat:@"%d", 1000 + i];
//        promise.promiseUserAvatar = @"http://img4.duitang.com/uploads/item/201306/19/20130619113256_vRGPj.thumb.600_0.jpeg";
//        promise.promiseUserName = [NSString stringWithFormat:@"%d", 1000  + i];
//        promise.promiseUserGender = (i %2 == 0 ? @"m" : @"f");
//        promise.promiseUserAge = i;
//        promise.promiseUserAppointmentRate = (i %2 == 0 ? @"100%" : @"80%");
//        promise.promiseUserActivityCount = i;
//        
//        promise.lemonType = (i % 3);
//        promise.lemonCount = i + 1;
//        promise.status = (i % 3);
//        
//        [mu addObject:promise];
//    }
//    self.myCreateActivity.promiseList = mu;
//}

- (void)didQueryActivityList:(NSArray *)list status:(NSString *)status type:(ActivityListType)type page:(int)page
{
    [SportProgressView dismiss];
    if (type == ActivityListTypeMyCreate) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            if ([list count] > 0) {
                self.myCreateActivity = [list objectAtIndex:0];
            } else {
                self.myCreateActivity = nil;
            }
            self.isSuccessLoadMyCreate = YES;
        } else {
            self.myCreateActivity = nil;
        }
        
        [self reloadMyCreateActivity];

//            self.tipsBackgroundImageView.hidden = NO;
//            if ([status isEqualToString:STATUS_SUCCESS]) {
//                [self.tipsBackgroundImageView setImage:[SportImage noDataPageImage]];
//            } else {
//                [self.tipsBackgroundImageView setImage:[SportImage networkErrorPageImage]];
//            }
//        } else {
//            self.tipsBackgroundImageView.hidden = YES;
//        }
        
    } else {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            self.isSuccessLoadMyPromise  = YES;
            self.myPromiseActivityList = [NSMutableArray arrayWithArray:list];
            [self reloadMyPromiseActivity];
        }
        
        //无数据时的提示
        if ([_myPromiseActivityList count] == 0) {
            CGRect frame = CGRectMake(0, self.headerView.frame.size.height, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - self.headerView.frame.size.height);
            if ([status isEqualToString:STATUS_SUCCESS]) {
                [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
            } else {
                [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
            }
        } else {
            [self removeNoDataView];
        }

//            self.tipsBackgroundImageView.hidden = NO;
//            if ([status isEqualToString:STATUS_SUCCESS]) {
//                [self.tipsBackgroundImageView setImage:[SportImage noDataPageImage]];
//            } else {
//                [self.tipsBackgroundImageView setImage:[SportImage networkErrorPageImage]];
//            }
//        } else {
//            self.tipsBackgroundImageView.hidden = YES;
//        }
    }

}

- (IBAction)clickMyCreateButton:(id)sender {
    self.myCreateButton.selected = YES;
    self.myPromiseButton.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [self.moveLineView updateOriginX:0];
    }];
    
    self.myCreateActivityTableView.hidden = NO;
    self.myPromiseActivityTableView.hidden = YES;
    [self.myCreateActivityTableView reloadData];
    
    [self updateMyActivityHeader];
    [self.myCreateActivityTableView reloadData];
    
    if (_isSuccessLoadMyCreate == NO) {
        [self queryMyCreateData];
    } else {
        if (self.myCreateActivity) {
            [self removeNoDataView];
        }
    }
}

- (void)reloadMyCreateActivity
{
    [self updateMyActivityHeader];
    //无数据时的提示
    if (_myCreateActivity == nil) {
        CGRect frame = CGRectMake(0, self.headerView.frame.size.height, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - self.headerView.frame.size.height);
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
    } else {
        [self removeNoDataView];
    }
//    if (_myCreateActivity == nil) {
//        self.tipsBackgroundImageView.hidden = NO;
//        [self.tipsBackgroundImageView setImage:[SportImage noDataPageImage]];
//    } else {
//        self.tipsBackgroundImageView.hidden = YES;
//    }
    
    [self.myCreateActivityTableView reloadData];
}

- (IBAction)clickMyPromiseButton:(id)sender {
    self.myCreateButton.selected = NO;
    self.myPromiseButton.selected = YES;
    [UIView animateWithDuration:0.2 animations:^{
        [self.moveLineView updateOriginX:[[UIApplication sharedApplication]keyWindow].frame.size.width/2];
    }];
    
    self.myCreateActivityTableView.hidden = YES;
    self.myPromiseActivityTableView.hidden = NO;

    [self.myPromiseActivityTableView reloadData];
    
    if (_isSuccessLoadMyPromise == NO) {
        [self queryMyPromiseData];
    }
}

- (void)reloadMyPromiseActivity
{
    if ([_myPromiseActivityList count] == 0) {
        self.tipsBackgroundImageView.hidden = NO;
        [self.tipsBackgroundImageView setImage:[SportImage noDataPageImage]];
    } else {
        self.tipsBackgroundImageView.hidden = YES;
    }
    
    [self.myPromiseActivityTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _myCreateActivityTableView) {
        return [_myCreateActivity.promiseList count];
    } else {
        return [_myPromiseActivityList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _myCreateActivityTableView) {
        NSString *identifier = [PromiseUserCell getCellIdentifier];
        PromiseUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [PromiseUserCell createCell];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        ActivityPromise *promise = [_myCreateActivity.promiseList objectAtIndex:indexPath.row];
        BOOL isLast = (indexPath.row == _myCreateActivity.promiseList.count - 1);
        [cell updateCellWithPromise:promise indexPath:indexPath isLast:isLast];
        return cell;
    } else {
        NSString *identifier = [MyPromiseActivityCell getCellIdentifier];
        MyPromiseActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [MyPromiseActivityCell createCell];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        Activity *activity = [_myPromiseActivityList objectAtIndex:indexPath.row];
        [cell updateCellWithActivity:activity indexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _myCreateActivityTableView) {
        return [PromiseUserCell getCellHeight];
    } else {
        return [MyPromiseActivityCell getCellHeight];
    }
}

- (void)didClickPromiseUserCellButton:(NSIndexPath *)indexPath
{
    if ([_myCreateActivity agreePromiseCount] >= _myCreateActivity.peopleNumber - 1 ) {
        [SportPopupView popupWithMessage:@"人数已够，不能再接受"];
        return;
    }
    
    ActivityPromise *promise = [_myCreateActivity.promiseList objectAtIndex:indexPath.row];
    
//    ActivityPromiseStatus newStatus = (promise.status == ActivityPromiseStatusAgreed ? ActivityPromiseStatusRejected : ActivityPromiseStatusAgreed);
    
    [SportProgressView showWithStatus:@"更新中..."];
    [ActivityService updatePromiseStatus:self
                               promiseId:promise.promiseId
                                  userId:[[[UserManager defaultManager] readCurrentUser] userId]
                                  status:ActivityPromiseStatusAgreed];
}

- (void)didClickPromiseUserCellAvatarButton:(NSIndexPath *)indexPath
{
    ActivityPromise *promise = [_myCreateActivity.promiseList objectAtIndex:indexPath.row];
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:promise.promiseUserId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didUpdatePromise:(NSString *)status
               promiseId:(NSString *)promiseId
           promiseStatus:(ActivityPromiseStatus)promiseStatus
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"更新成功"];
        
        ActivityPromise *promise = nil;
        int row = 0;
        for (ActivityPromise *one in _myCreateActivity.promiseList) {
            if ([one.promiseId isEqualToString:promiseId]) {
                promise = one;
                break;
            }
            row ++;
        }
        if (promise) {
            promise.status = promiseStatus;
            NSArray *array = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil];
            [_myCreateActivityTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
            [self updateMyActivityHeader];
        }
        
        [self showTipsIfFirstAgree];
    } else {
        [SportProgressView dismissWithSuccess:@"更新失败"];
    }
}

//如果第一次点击同意，则弹出提示
- (void)showTipsIfFirstAgree
{
    int count = 0;
    for (ActivityPromise *one in _myCreateActivity.promiseList) {
        if (one.status == ActivityPromiseStatusAgreed) {
            count ++;
        }
        if (count > 1) {
            break;
        }
    }
    if (count == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"接受成功!" message:@"现在可以和伙伴一起群聊啦" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - MyPromiseActivityCellDelegate
- (void)didClickMyPromiseActivityCellAvatarButton:(NSIndexPath *)indexPath
{
    Activity *activity = [_myPromiseActivityList objectAtIndex:indexPath.row];
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:activity.userId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickMyPromiseActivityCellEnterRoomChatButton:(NSIndexPath *)indexPath
{
//    Activity *activity = [_myPromiseActivityList objectAtIndex:indexPath.row];
//    if ([self isBeAgreedInMyPromise:activity]) {
//        ChatController *controller = [[ChatController alloc] initWithActivityId:activity.activityId
//                                                                 activityUserId:activity.userId];
//        [self.navigationController pushViewController:controller animated:YES];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你的参与请求还没有被接受，不能群聊" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alertView show];
//    }
}

- (void)didClickMyPromiseActivityCellDetailButton:(NSIndexPath *)indexPath
{
    Activity *activity = [_myPromiseActivityList objectAtIndex:indexPath.row];
    ActivityDetailController *controller = [[ActivityDetailController alloc] initWithActivityId:activity.activityId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)isBeAgreedInMyPromise:(Activity *)activity
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    for (ActivityPromise *promise in activity.promiseList) {
        if ([user.userId isEqualToString:promise.promiseUserId]
            && promise.status == ActivityPromiseStatusAgreed) {
            return YES;
        }
    }
    return NO;
}

- (void)didClickMyPromiseActivityCellCancelButton:(NSIndexPath *)indexPath
{
    Activity *activity = [_myPromiseActivityList objectAtIndex:indexPath.row];
    NSString *message = nil;
    if ([self isBeAgreedInMyPromise:activity]) {
        message = @"此时取消会影响你的赴约率，确定要取消应约?";
    } else {
        message = @"确定要取消应约?";
    }
    
    self.myPromiseActivityIndexPath = indexPath;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"否"
                                              otherButtonTitles:@"是", nil];
    alertView.tag = TAG_ALERT_VIEW_MY_PROMISE_CANCEL;
    [alertView show];
}

- (void)myPromiseCancel
{
    Activity *activity = [_myPromiseActivityList objectAtIndex:_myPromiseActivityIndexPath.row];
    User *user = [[UserManager defaultManager] readCurrentUser];
    NSString *myPromiseId = nil;
    for (ActivityPromise *promise in activity.promiseList) {
        if ([promise.promiseUserId isEqualToString:user.userId]) {
            myPromiseId = promise.promiseId;
            break;
        }
    }
    
    [SportProgressView showWithStatus:@"正在更新..."];
    [ActivityService cancelPromise:self
                     promiseUserId:user.userId
                         promiseId:myPromiseId];
}

- (void)didCancelPromise:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"更新成功"];
        [self.myPromiseActivityList removeObjectAtIndex:_myPromiseActivityIndexPath.row];
        [self reloadMyPromiseActivity];
    } else {
        [SportProgressView dismissWithSuccess:msg];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    if (_type == ManageActivityCreate) {
        [self clickMyCreateButton:_myCreateButton];
    } else {
        [self clickMyPromiseButton:_myPromiseButton];
    }
    
}

@end
