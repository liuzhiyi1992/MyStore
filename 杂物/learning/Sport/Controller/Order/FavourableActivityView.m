//
//  FavourableActivityView.m
//  Sport
//
//  Created by haodong  on 14/11/7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "FavourableActivityView.h"
#import "FavourableActivityCell.h"
#import "FavourableActivity.h"
#import "UIView+Utils.h"
#import "SportPopupView.h"
#import "User.h"
#import "UserManager.h"
#import "SportProgressView.h"

#define CONTENTVIEW_SCALE       0.8
#define MAX_DISPLAY_ACTIVITY    6

@interface FavourableActivityView()
@property (strong, nonatomic) NSArray *dataList;
@property (copy, nonatomic) NSString *selectedActivityId;
@property (strong, nonatomic) FavourableActivity *currenCheckInviteCodeActivity;
@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@end

@implementation FavourableActivityView

+ (FavourableActivityView *)createViewWithActivityList:(NSArray *)activityList
                                    selectedActivityId:(NSString *)selectedActivityId
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FavourableActivityView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    FavourableActivityView *view = [topLevelObjects objectAtIndex:0];
    
    view.frame = [UIScreen mainScreen].bounds;
    view.contentHolderView.layer.cornerRadius = 3;
    view.contentHolderView.layer.masksToBounds = YES;
    
    [(UIImageView *)[view.contentHolderView viewWithTag:100] setImage:[UIImage imageNamed:@"cell_line_e6"]];
    
    //set data
    view.dataList = activityList;
    view.selectedActivityId = selectedActivityId;
    
    return view;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    //self.dataTableView.showsVerticalScrollIndicator=YES;


   [self.dataTableView flashScrollIndicators ];
   

   // if (self.dataTableView.contentSize.height > self.dataTableView.frame.size.height) {

        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(showBar) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fire];

  //  }
     [self.dataTableView reloadData];

    if(self.dataList.count <= MAX_DISPLAY_ACTIVITY) {
        [self.contentHolderView updateHeight:(self.titleView.frame.size.height + self.dataList.count * [FavourableActivityCell getCellHeight])];
    }else {
        [self.contentHolderView updateHeight:(self.titleView.frame.size.height + MAX_DISPLAY_ACTIVITY * [FavourableActivityCell getCellHeight])];
    }
    
    
    [self.contentHolderView updateWidth:CONTENTVIEW_SCALE * [UIScreen mainScreen].bounds.size.width];
    [self.contentHolderView updateCenterX:[UIScreen mainScreen].bounds.size.width/2];
    [self.contentHolderView updateCenterY:[UIScreen mainScreen].bounds.size.height/2];
    
    self.contentHolderView.alpha = 0;
    self.contentHolderView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [UIView animateWithDuration:0.2 delay:0.06 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.contentHolderView.alpha = 1;
        self.contentHolderView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
    }];
}

-(void)showBar{
    [self.dataTableView flashScrollIndicators ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FavourableActivityCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [FavourableActivityCell getCellIdentifier];
    FavourableActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [FavourableActivityCell createCell];
        cell.delegate = self;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    FavourableActivity *activity = [_dataList objectAtIndex:indexPath.row];
    
    BOOL isSelected = [activity.activityId isEqualToString:_selectedActivityId];
    
    [cell updateCellWithActivity:activity
                       indexPath:indexPath
                      isSelected:isSelected];
    
    return cell;
}

- (void)didClickFavourableActivityCellBackgroundButton:(NSIndexPath *)indexPath
{
    
    
    FavourableActivity *activity = [_dataList objectAtIndex:indexPath.row];
    
    BOOL isAvailable = (activity.activityStatus != FavourableActivityStatusNotAvailable);
    
    if (isAvailable == NO) {
        [SportPopupView popupWithMessage:@"抱歉，该活动不可参与"];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(didSelectFavourableActivityView:inviteCode:)]) {
        [_delegate didSelectFavourableActivityView:activity inviteCode:activity.activityInviteCode];
    }
    
    [self removeFromSuperview];
}

- (void)didClickFavourableActivityCellFinishInputButton:(NSIndexPath *)indexPath text:(NSString *)text
{
    if ([text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入邀请码"];
        return;
    }
    
    FavourableActivity *activity = [_dataList objectAtIndex:indexPath.row];
    User *user = [[UserManager defaultManager] readCurrentUser];
    self.currenCheckInviteCodeActivity = activity;
    
    [SportProgressView showWithStatus:@"正在验证"];
    [OrderService checkActivityInviteCode:self
                                   userId:user.userId
                               activityId:activity.activityId
                               inviteCode:text];
}

- (void)didCheckActivityInviteCode:(NSString *)inviteCode
                            status:(NSString *)status
                               msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        if ([_delegate respondsToSelector:@selector(didSelectFavourableActivityView:inviteCode:)]) {
            _currenCheckInviteCodeActivity.activityInviteCode = inviteCode;
            [_delegate didSelectFavourableActivityView:_currenCheckInviteCodeActivity inviteCode:inviteCode];
        }
        [self removeFromSuperview];
        
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"网络错误，请重试"];
        }
    }
}

- (IBAction)touchDownBackground:(id)sender {
    [self removeFromSuperview];
}

#pragma mark - override removeFromSuperview
- (void)removeFromSuperview {
    
    if(_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [super removeFromSuperview];
}
@end
