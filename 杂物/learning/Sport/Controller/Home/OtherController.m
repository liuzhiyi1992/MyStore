//
//  OtherController.m
//  Sport
//
//  Created by haodong  on 14-5-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "OtherController.h"
#import "UserManager.h"
#import "OrderListController.h"
#import "LoginController.h"
#import "MyVouchersController.h"
#import "ActivityHistroyListController.h"
#import "UserInfoController.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import "ChatMessageBrief.h"
#import "ChatManager.h"
#import "AppDelegate.h"
#import "TipNumberManager.h"
#import "SystemNoticeMessageManager.h"
#import "UIUtils.h"
#import "FavoriteController.h"
#import "BaseConfigManager.h"
#import "HistoryController.h"
#import "AccountManageController.h"
#import "AboutSportController.h"
#import "PrizeShareController.h"
#import "SportUUID.h"
#import "MyPointController.h"
#import "SportPopupView.h"
#import "MembershipCardListController.h"
#import "RegisterController.h"
#import "MyMoneyController.h"
#import "AddVoucherController.h"
#import "NSString+Utils.h"
#import "ActClubIntroduceController.h"
#import "TicketService.h"
#import "MyVouchersController.h"
#import "OrderSimpleCell.h"
#import "OrderInformationCell.h"
#import "SportProgressView.h"
#import "MineInfo.h"
#import "OrderTips.h"
#import "TodayOrderInfo.h"
#import "PriceUtil.h"
#import "TodayOrderCell.h"
#import "UIScrollView+SportRefresh.h"
#import "MJRefresh.h"
#import "FeedbackController.h"
#import "EditUserInfoController.h"
#import "SportWebController.h"
#import "UserInfoHolderView.h"
#import "SportOrderDetailFactory.h"


@interface OtherController () <TodayOrderCellDelegate>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSArray *dataList;
@property (assign, nonatomic) NSUInteger newMessageCount;
@property (assign, nonatomic) NSUInteger newSystemNoticeCount;
@property (assign, nonatomic) NSUInteger needPayOrderCount;
@property (assign, nonatomic) NSUInteger newVoucherCount;
@property (assign, nonatomic) NSUInteger readyBeginCount;
@property (assign, nonatomic) NSUInteger canCommentCount;
@property (assign, nonatomic) NSUInteger newCardCount;
@property (assign, nonatomic) NSUInteger cardChangeCount;
@property (strong, nonatomic) MineInfo *mineInfo; //我的信息
@property (weak, nonatomic) IBOutlet UIButton *voucherTipsCountButton;
@property (weak, nonatomic) IBOutlet UIView *userInfoHolderView;
@property (weak, nonatomic) IBOutlet UIButton *clubButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *highlightButtonArray;



@end

#define TITLE_ORDER                     @"我的订单"
#define TITLE_TODAY_ORDER               @"今日预订"
#define TITLE_MY_FAVORITES              @"我的收藏"
#define TITLE_SYSTEM_NOTICE             @"系统消息"
#define TITLE_CUSTOMER_SERVICE_PHONE    @"联系客服"
#define TITLE_SHARE                     @"推荐给朋友"
#define TITLE_CARD                      @"场馆会员卡"
#define TITLE_FEEDBACK                  @"意见反馈"
#define TITLE_SURVEY                    @"趣运动问卷调查"

@implementation OtherController

- (MineInfo *)mineInfo {
    if (_mineInfo == nil) {
        _mineInfo = [[MineInfo alloc] init];
    }
    return _mineInfo;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT object:nil];
}

- (void)viewDidUnload {
    [self setDataTableView:nil];
    [super viewDidUnload];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMessageCount)
                                                     name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的";
    
    [self createRightTopImageButton:[UIImage imageNamed:@"MyCellSettingIcon"]];
    
    [self.dataTableView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - 49];
    [self.dataTableView setBackgroundColor:[SportColor defaultPageBackgroundColor]];
    [self.dataTableView setShowsVerticalScrollIndicator:NO];
   
    for (UIView *subView in _dataTableView.tableHeaderView.subviews) {
        if (subView.tag == 100 && [subView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)subView setImage:[SportImage lineImage]];
        }
    }
    
    for(UIButton *button in self.highlightButtonArray) {
        [button setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     self.user = [[UserManager defaultManager] readCurrentUser];
    
    if ([_user.userId length] > 0) {
        
        self.headerInfoView.hidden = NO;
        self.coverView.hidden = YES;
        
         [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];

        [MineService getMineInfor:self userId:_user.userId];
        
        //更新headerView高度
        UIView *headerView = self.dataTableView.tableHeaderView;
        [headerView updateHeight:self.headerInfoView.frame.size.height];
        self.dataTableView.tableHeaderView = headerView;
        
    } else {
      //隐藏刷新head
        for (UIView *v in self.dataTableView.subviews) {
            
            if ([v isKindOfClass:[MJRefreshNormalHeader class]]) {
 
                v.hidden=YES ;
            }
        }

        self.headerInfoView.hidden = YES;
        self.coverView.hidden = NO;
        
        //更新headerView高度
        UIView *headerView = self.dataTableView.tableHeaderView;
        [headerView updateHeight:self.coverView.frame.size.height];
        self.dataTableView.tableHeaderView = headerView;
      
        //logout的时候已经清空TipManager
//        self.newMessageCount = 0;
//        self.newSystemNoticeCount = 0;
//        self.needPayOrderCount = 0;
//        self.newVoucherCount = 0;
//        self.readyBeginCount = 0;
//        self.canCommentCount = 0;
//        self.newCardCount = 0;
        self.mineInfo = nil;
    }
    
    [self getMessageCount];
    [self updateDataList];
   
    [self.dataTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dataTableView endLoad];
}

-(void)loadNewData {
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        [MineService getMineInfor:self userId:user.userId];
    }
    
    [self getMessageCount];
}

- (void)getMessageCount {
    User *user = [[UserManager defaultManager] readCurrentUser];
    [UserService getMessageCountList:self
                              userId:user.userId
                            deviceId:nil];
}

-(void) didGetMessageCountList:(NSString *)status msg:(NSString *)msg {
    [self updateMessageCount];
}

- (void)updateMessageCount {
    TipNumberManager *manager = [TipNumberManager defaultManager];
    self.newMessageCount = [manager chatMessageCount];
    self.newSystemNoticeCount = [manager userMessageCount];
    self.needPayOrderCount = [manager needPayOrderCount];
    self.newVoucherCount = [manager voucherCount];
    self.readyBeginCount = [manager readyBeginCount];
    self.canCommentCount = [manager canCommentCount];
    self.newCardCount = [manager newCardCount];
    self.cardChangeCount = [manager cardChangeCount];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.newVoucherCount > 0) {
            [self.voucherTipsCountButton setTitle:[@(self.newVoucherCount) stringValue] forState:UIControlStateNormal];
            self.voucherTipsCountButton.hidden = NO;
        } else {
            self.voucherTipsCountButton.hidden = YES;
        }
        [self.dataTableView reloadData];
    });
}

- (void)updateMoreUserInfo
{
    
    NSURL *avatarUrl = [NSURL URLWithString:self.mineInfo.avatar];
    NSString *nickName = self.mineInfo.nickName ? self.mineInfo.nickName : [[UserManager defaultManager]readCurrentUser].nickname;
    NSString *signature = self.mineInfo.signature;
    
    //去除之前的UserInfoView
    for (UIView *subView in self.userInfoHolderView.subviews) {
        if ([subView isKindOfClass:[UserInfoHolderView class]]) {
            [subView removeFromSuperview];
            break;
        }
    }
    UserInfoHolderView *view = [UserInfoHolderView creatViewWithAvatarUrl:avatarUrl
                                                                userName:nickName
                                                                     city:nil
                                                                 signture:signature
                                                                   gender:nil
                                                                    level:self.mineInfo.rulesTitle
                                                                  iconUrl:self.mineInfo.rulesIconUrl
                                                           isRulesDisplay:([self.mineInfo.rulesIsDisplay isEqualToString:@"1"] ? YES : NO)
                                                               viewStatus:ViewStatusMyself];
    
    //"我的"页面，UserInfoHolderView不隐藏右箭头
    view.arrowRightImageView.hidden = NO;
    
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view updateHeight:self.userInfoHolderView.bounds.size.height];
    [self.userInfoHolderView addSubview:view];
    
    self.noDataTipsLabel.hidden = YES;
    self.coverView.hidden = YES;
    

    self.moneyLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:self.mineInfo.money]];
    self.jiFenLabel.text = [NSString stringWithFormat:@"%d", self.mineInfo.credit];
    self.kaQuanLabel.text = [NSString stringWithFormat:@"%d张可用", self.mineInfo.couponNumber];
    
    switch (self.mineInfo.buyedClub) {
        case CLUB_STATUS_UNPAID:
        case CLUB_STATUS_EXPIRE:
            [self.dongButton setBackgroundImage:[SportImage dongClubGrayBackroundImage] forState:UIControlStateNormal];
            self.dateLabel.hidden = YES;
            break;
        case CLUB_STATUS_PAID_VALID:
        case CLUB_STATUS_PAID_INVALID: {
            [self.dongButton setBackgroundImage:[SportImage dongClubRedBackgroundImage] forState:UIControlStateNormal];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd"];
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[self.mineInfo.clubEndTime integerValue]];
            NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
            self.dateLabel.hidden = NO;
            self.dateLabel.text = [NSString stringWithFormat:@"有效期%@",confromTimespStr];
    
            }
            break;
        default:
            break;
    }
}

- (void)didGetMineInfor:(MineInfo *)info status:(NSString *)status msg:(NSString *)msg
{
    [self.dataTableView endLoad];
    
    if (![status isEqualToString:STATUS_SUCCESS]) {
        [SportPopupView popupWithMessage:msg];
    } else {
    
        self.mineInfo = info;
      
        [self updateDataList];
        [self updateMoreUserInfo];
        [self.dataTableView reloadData];
    }
}

- (void)clickRightTopButton:(id)sender{
    AboutSportController *controller = [[AboutSportController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)hasTodayOrder
{
    return ([self.mineInfo.orderNotify count] > 0);
}

- (void)updateDataList
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    if ([self hasTodayOrder]) {
        [mutableArray addObject:[NSArray arrayWithObjects:TITLE_ORDER,TITLE_TODAY_ORDER,TITLE_CARD,TITLE_MY_FAVORITES,nil]];
    } else {
        [mutableArray addObject:[NSArray arrayWithObjects:TITLE_ORDER,TITLE_CARD,TITLE_MY_FAVORITES,nil]];
    }
    
    [mutableArray addObject:[NSArray arrayWithObjects:TITLE_SHARE, TITLE_CUSTOMER_SERVICE_PHONE,TITLE_FEEDBACK,TITLE_SURVEY,nil]];
    
    self.dataList = mutableArray;
    [self.dataTableView reloadData];
}

- (IBAction)clickHeaderButton:(id)sender {
    if ([self isLoginAndShowLoginIfNot]) {
//to do 1.91去除，只有运动圈入口
//        UserInfoController *controller = [[UserInfoController alloc] initWithUserId:_user.userId];
//        [self.navigationController pushViewController:controller animated:YES];
        EditUserInfoController *controller = [[EditUserInfoController alloc] initWithUser:[[UserManager defaultManager] readCurrentUser] levelTitle:self.mineInfo.rulesTitle];

        [self.navigationController pushViewController:controller animated:YES];
    }
}

//余额
- (IBAction)clickMyMoneyButton:(id)sender {
    MyMoneyController *controller = [[MyMoneyController alloc] initWithType:TypeMoney];
    [self.navigationController pushViewController:controller animated:YES];
}

//我的积分
- (IBAction)clickMyIntegralButton:(id)sender {

   MyMoneyController *controller = [[MyMoneyController alloc] initWithType:TypePoint];
    [self.navigationController pushViewController:controller animated:YES];
}

//卡券
- (IBAction)clickMyVouchersButton:(id)sender {
    [MobClickUtils event:umeng_event_my_page_click_card];
    
    MyVouchersController *controller = [[MyVouchersController alloc] init];
    controller.canSelect=NO;
    controller.entry = @"0";
    controller.title = @"卡券";
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = _dataList[section];
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = _dataList[indexPath.section];
    NSString *value = list[indexPath.row];
    
    if ([value isEqualToString:TITLE_TODAY_ORDER]) {
     
        TodayOrderCell *cell = [TodayOrderCell cellWithTableView:tableView];
        cell.delegate = self;
        [cell updateCellWithTodayOrderList:self.mineInfo.orderNotify];
        
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {

        UserInfoCell *cell = [UserInfoCell cellWithTableView:tableView];
        NSString *subValue = nil;
        NSString *orangeValue = nil;
        BOOL isLast = (indexPath.row == [list count] - 1 ? YES : NO);
        UIImage *iconImage = nil;
        NSUInteger tipsCount = 0;
        BOOL isShowRedPoint = NO;
        
        if ([value isEqualToString:TITLE_ORDER]) {
            
            cell.option=^{
                if ([self isLoginAndShowLoginIfNot]) {
                    
                    int openIndex = 0;
                    if (self.needPayOrderCount > 0) {
                        openIndex = 0;
                    } else if (self.readyBeginCount > 0){
                        openIndex = 1;
                    } else if(self.canCommentCount > 0) {
                        openIndex = 2;
                    }
                    OrderListController *controller = [[OrderListController alloc] initWithOpenIndex:openIndex];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            };
        
            iconImage = [UIImage imageNamed:@"OtherMyOrder"];
            if (self.needPayOrderCount >0) {
                subValue = @"待付款";
                tipsCount = self.needPayOrderCount;
            } else if (self.readyBeginCount >0){
                subValue = @"待开始";
                tipsCount = self.readyBeginCount;
            }else if(self.canCommentCount > 0) {
                subValue = @"未评价";
                tipsCount = self.canCommentCount;
            }
        }
        else if ([value isEqualToString:TITLE_MY_FAVORITES]) {
           
            iconImage = [UIImage imageNamed:@"MyCellFavoritesIcon"];
            cell.option=^{
                if ([self isLoginAndShowLoginIfNot]) {
                    FavoriteController *controller = [[FavoriteController alloc] init] ;
                    controller.title = TITLE_MY_FAVORITES;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            };
        } else if ([value isEqualToString:TITLE_CUSTOMER_SERVICE_PHONE]) {
            
            cell.option=^{
                NSString *phone = [ConfigData customerServicePhone];
                if ([phone length] > 0) {
                    NSString *title = @"客服在线时间:周一至周六10:00-20:00，周日10:00-18:00";
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:phone otherButtonTitles:nil];
                    [sheet showInView:[UIApplication sharedApplication].keyWindow];
                }

            };

            iconImage = [UIImage imageNamed:@"MyCellPhoneIcon"];
            
        } else if([value isEqualToString:TITLE_FEEDBACK ]){
            
            iconImage = [UIImage imageNamed:@"MyCellFeedBack"];
            
            cell.option = ^{
                [MobClickUtils event:umeng_event_click_questionnaire];
                FeedbackController *controller = [[FeedbackController alloc]init];
                [self.navigationController pushViewController:controller animated:YES];
            };
            
            
        } else if([value isEqualToString:TITLE_SURVEY ]){
            
            iconImage = [UIImage imageNamed:@"MyCellSurvey"];
            
            isShowRedPoint = [[TipNumberManager defaultManager] isShowSurveyTips];

            cell.option=^{
                [MobClickUtils event:umeng_event_click_feed_back];
                [UserManager saveIsClickedSurvey:YES];
                NSMutableString *urlString = [[NSMutableString alloc] init];
                NSString *str = [BaseConfigManager defaultManager].nmqUrl;
                if (str) {
                    [urlString appendString:str];
                }
                [urlString appendFormat:@"device_id=%@", [SportUUID uuid]];
                
                User *user = [[UserManager defaultManager] readCurrentUser];
                if ([user.userId length] > 0) {
                    [urlString appendFormat:@"&id=%@", user.userId];
                }
                SportWebController *controller = [[SportWebController alloc] initWithUrlString:urlString title:TITLE_SURVEY];
                [self.navigationController pushViewController:controller animated:YES];
                
            };

        } else if ([value isEqualToString:TITLE_SHARE]) {
            iconImage = [UIImage imageNamed:@"MyCellShareIcon"];
            subValue = [[BaseConfigManager defaultManager] recommendDescription];
         cell.option=^{
   
                if ([self isLoginAndShowLoginIfNot]) {
                    PrizeShareController *controller = [[PrizeShareController alloc] init] ;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            };

        }else if ([value isEqualToString:TITLE_CARD]) {
            iconImage = [UIImage imageNamed:@"OtherControllerMyCard"];
            if (self.newCardCount > 0) {
                tipsCount = self.newCardCount;
            } else if (self.cardChangeCount > 0) {
                isShowRedPoint = YES;
            }
            cell.option=^{
                if ([self isLoginAndShowLoginIfNot]) {
                    [MobClickUtils event:umeng_event_click_mine_balance];
                    MembershipCardListController *controller = [[MembershipCardListController alloc] init];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            };
        }
        
        [cell updateCell:value
                subValue:subValue
             orangeValue:orangeValue
               iconImage:iconImage
               indexPath:indexPath
                  isLast:isLast
               tipsCount:tipsCount
          isShowRedPoint:isShowRedPoint];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *value = [list objectAtIndex:indexPath.row];
    if ([value isEqualToString:TITLE_TODAY_ORDER]) {
        return [TodayOrderCell heightWithOrderCount:[self.mineInfo.orderNotify count]];
    } else {
        return [UserInfoCell getCellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
 
   UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[UserInfoCell class]]) {
        UserInfoCell *ucell=(UserInfoCell *)cell;
        if (ucell.option) {
            ucell.option();
        }
    }
}

- (void)didClickTodayOrderCell:(TodayOrderInfo *)todayOrderInfo {
    Order *order = [[Order alloc]init];
    order.orderId = todayOrderInfo.orderId;
    order.type = todayOrderInfo.type;
    order.status = todayOrderInfo.status;
    
    UIViewController *orderDetailController = [SportOrderDetailFactory orderDetailControllerWithOrder:order];
    if (nil != orderDetailController) {
        [self.navigationController pushViewController:orderDetailController animated:YES];
    }
    
    
//    if (order.type == OrderTypeCoach) {
//        CoachOrderDetailController *controller = [[CoachOrderDetailController alloc] initWithOrder:order];
//        [self.navigationController pushViewController:controller animated:YES];
//        
////      }else if (order.type == OrderTypeCourtPool){
////          CourtPoolOrderDetailController *vc = [[CourtPoolOrderDetailController alloc]initWithOrder:order];
////          [self.navigationController pushViewController:vc animated:YES];
//    } else if (order.type == OrderTypeCourtJoin) {
//        CourtJoinOrderDetailController *controller = [[CourtJoinOrderDetailController alloc]initWithOrder:order];
//        [self.navigationController pushViewController:controller animated:YES];
//      } else {
//        OrderDetailController *controller = [[OrderDetailController alloc] initWithOrder:order isReload:YES];
//        [self.navigationController pushViewController:controller animated:YES];
//    }
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        BOOL result = [UIUtils makePromptCall:title];
        
        if (result == NO) {
            [SportPopupView popupWithMessage:@"此设备不支持打电话"];
        }
    }
}

- (IBAction)logInButton:(id)sender {
    if ([self isLoginAndShowLoginIfNot]) {
        UserInfoController *controller = [[UserInfoController alloc] initWithUserId:_user.userId];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

//- (IBAction)clickDongClub:(id)sender {
//    [self pushActClubIntroduceController];
//}
//
//- (IBAction)clickDongButton:(id)sender {
//    [self pushActClubIntroduceController];
//}
//
//- (void)pushActClubIntroduceController {
//    ActClubIntroduceController *controller = [[ActClubIntroduceController alloc] initWithClubStatus:self.mineInfo.buyedClub];
//    [self.navigationController pushViewController:controller animated:YES];
//
//}

@end
