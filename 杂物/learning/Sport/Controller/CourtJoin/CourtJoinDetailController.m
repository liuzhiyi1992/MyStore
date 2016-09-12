//
//  CourtJoinDetailController.m
//  Sport
//
//  Created by jiangyancong on 16/6/7.
//  Copyright © 2016年 jiangyancong . All rights reserved.
//

#import "CourtJoinDetailController.h"
#import "AvatarLabelView.h"
#import "User.h"
#import "CourtJoinService.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "DateUtil.h"
#import "BusinessDetailController.h"
#import "OrderService.h"
#import "LoginController.h"
#import "PayController.h"
#import "NoDataView.h"
#import "CollectAndShareButtonView.h"
#import "ShareView.h"
#import "PriceUtil.h"
#import "CourtJoin.h"
#import "CourtJoinUser.h"
#import "CourtJoinInfoCell.h"
#import "UIImageView+WebCache.h"
#import "SportImage.h"
#import "CourtJoinConfirmOrderController.h"
#import "BusinessDetailController.h"
#import "BusinessMapController.h"
#import "UIAlertView+Block.h"
#import "UnpaidOrderAlertView.h"
#include "PreciseTimerHelper.h"
#import "SDWebImageDownloader.h"
#import "UIImage+normalized.h"
#import "ConversationViewController.h"
#import "CourtJoinGuideView.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"

@interface CourtJoinDetailController ()<LoginDelegate,OrderServiceDelegate,UITableViewDelegate,UITableViewDataSource,UnpaidOrderAlertViewDelegate,AvatarLabelViewDelegate,ShareViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *courtJoinDescLabel;

@property (strong, nonatomic) CourtJoin *courtJoin;
@property (strong, nonatomic) NSString *courtJoinId;
@property (weak, nonatomic) IBOutlet UIScrollView *courtPoolFriendScrollView;
@property (strong, nonatomic) CollectAndShareButtonView *rightTopView;
@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) NSArray *titleList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTableViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *alreadyJoinLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftJoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (strong, nonatomic) Order *needPayOrder;
@property (assign, nonatomic) uint64_t startTime;
@property (weak, nonatomic) IBOutlet UIView *courtJoinHolderView;
@property (copy, nonatomic) NSString *from;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@end

#define TITLE_COST @"费用："
#define TITLE_DATE @"日期："
#define TITLE_TIME  @"时间："
#define TITLE_CATEGORY  @"项目："
#define TITLE_VENUE @"场馆："
#define TITLE_ADDRESS @"地址："


@implementation CourtJoinDetailController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithCourtJoinId:(NSString *)courtJoinId {
    self = [super init];
    if (self) {
        self.courtJoinId = courtJoinId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 2) {
        UIViewController *preController = [self.navigationController.viewControllers objectAtIndex:count - 2];
        NSString *className = NSStringFromClass(preController.class);
        if ([className isEqualToString:@"MainController"]) {
            self.from = @"首页";
        } else if ([className isEqualToString:@"BookingDetailController"]) {
            self.from = @"场次选择页";
        } else if ([className isEqualToString:@"CourtJoinListController"]) {
            self.from = @"球局列表页";
        } else {
            self.from = className;
        }
    }
    
    self.joinButton.layer.cornerRadius = 20.0;
    self.joinButton.layer.masksToBounds = YES;
    [self.joinButton setBackgroundImage:[SportColor createImageWithColor:[SportColor content2Color]] forState:UIControlStateDisabled];
    [self.joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.joinButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultBlueColor]] forState:UIControlStateHighlighted];
    
    self.userAvatarImageView.layer.cornerRadius = 25.0;
    self.userAvatarImageView.layer.masksToBounds = YES;
    
    self.sendMessageButton.layer.borderColor = [UIColor hexColor:@"4f6dcf"].CGColor;
    self.sendMessageButton.layer.borderWidth = 1.0;
    self.sendMessageButton.layer.cornerRadius = 10.0;
    self.sendMessageButton.layer.masksToBounds = YES;
    
    self.title = @"球局详情";
    
    if (_rightTopView == nil) {
        self.rightTopView = [CollectAndShareButtonView createCollectAndShareButtonView];
        [self.rightTopView.leftButton setImage:[UIImage imageNamed:@"courtJoinHelpIcon"] forState:UIControlStateNormal];
        self.rightTopView.rightButton.hidden = YES;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightTopView];
        self.navigationItem.rightBarButtonItem = buttonItem;
        
        [self.rightTopView.leftButton addTarget:self
                                          action:@selector(pushCourtJoinHelpController)
                                forControlEvents:UIControlEventTouchUpInside];
        [self.rightTopView.rightButton addTarget:self
                                          action:@selector(clickShareButton:)
                                forControlEvents:UIControlEventTouchUpInside];
    }
    
    UINib *cellNib = [UINib nibWithNibName:[CourtJoinInfoCell getCellIdentifier] bundle:nil];
    [self.infoTableView registerNib:cellNib forCellReuseIdentifier:[CourtJoinInfoCell getCellIdentifier]];
    
    self.titleList = @[TITLE_COST,TITLE_DATE,TITLE_TIME,TITLE_CATEGORY,TITLE_VENUE,TITLE_ADDRESS];
    
    self.courtJoinHolderView.hidden = YES;
    [self showNoticePage];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setJoinButtonEnable:NO];
    [self queryData];
}

- (void)queryData {
    [SportProgressView showWithStatus:@"加载中"];
    [self queryNeedPay];
    User *me = [[UserManager defaultManager] readCurrentUser];
    __weak __typeof(self) weakSelf = self;
    [CourtJoinService getCourtJoinInfo:self.courtJoinId userId:me.userId completion:^(NSString *status,NSString *msg, CourtJoin *courtJoin){
        if ([status isEqualToString:STATUS_SUCCESS]) {
            
            self.courtJoinHolderView.hidden = NO;
            [SportProgressView dismiss];
            weakSelf.courtJoin = courtJoin;
            [weakSelf updateViewWithCourtJoin:weakSelf.courtJoin];
            weakSelf.rightTopView.rightButton.hidden = NO;
            weakSelf.infoTableViewHeight.constant = [weakSelf getTimeCellHeight] + [CourtJoinInfoCell getCellHeight]*(weakSelf.titleList.count-1);
            [weakSelf.infoTableView reloadData];
            
        } else {
            [SportProgressView dismissWithError:msg];
        }
        //无数据时处理分支
        if([courtJoin.courtUserId length] == 0){
            
            CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-20-44);
            
            if([status isEqualToString:STATUS_SUCCESS]){
                [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
            } else{
                [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
            }
            
        }else{
            [self removeNoDataView];
        }

        
        
    }];
}

- (void)didClickNoDataViewRefreshButton{
    [self queryData];
}

- (void) setJoinButtonEnable:(BOOL)enable {
    self.joinButton.enabled = enable;
    
    if (enable) {
        self.joinButton.layer.borderColor = [SportColor defaultColor].CGColor;
    } else {
        self.joinButton.layer.borderColor = [UIColor hexColor:@"aaaaaa"].CGColor;
    }
}

- (void)updateViewWithCourtJoin:(CourtJoin *)courtJoin {
    
    self.userNameLabel.text = self.courtJoin.nickName;
    [self.userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:self.courtJoin.avatarUrl] placeholderImage:[SportImage avatarDefaultImage]];
    self.courtJoinDescLabel.text = self.courtJoin.joinDescription;
    if ([self.courtJoin.gender length] == 0) {
        self.genderImageView.hidden = YES;
    }else {
        self.genderImageView.hidden = NO;
        
        UIImage *genderImage = [SportImage genderImageWithGender:courtJoin.gender];
        [self.genderImageView setImage:genderImage];
    }
    
    if (self.courtJoin.alreadyJoinNumber == 0) {
        self.alreadyJoinLabel.text = @"暂无人加入";
    } else {
        self.alreadyJoinLabel.text = [NSString stringWithFormat:@"已加入%d人",self.courtJoin.alreadyJoinNumber];
    }

    self.leftJoinLabel.text = courtJoin.leftJoinNumberMsg;
//    if (self.courtJoin.leftJoinNumber == 0) {
//        self.leftJoinLabel.text = @"无法加入";
//    } else {
//        self.leftJoinLabel.text = [NSString stringWithFormat:@"还可加入%d人",self.courtJoin.leftJoinNumber];
//    }
    
   
    User *me = [[UserManager defaultManager] readCurrentUser];
    if([me.userId isEqualToString:courtJoin.courtUserId]) {
        self.scrollViewBottomConstraint.constant = 0;
        self.joinButton.hidden = YES;
        self.sendMessageButton.hidden = YES;
    } else {
        self.joinButton.hidden = NO;
        self.sendMessageButton.hidden = NO;
        self.scrollViewBottomConstraint.constant = 90;
    }
    
    NSString *joinStr;
    if (courtJoin.available == JoinStatusAvailable) {
        joinStr = @"立即加入";
        [self setJoinButtonEnable:YES];
        
    } else {
        joinStr = courtJoin.disableMsg;
        [self setJoinButtonEnable:NO];
    }
    
    [self.joinButton setTitle:joinStr forState:UIControlStateNormal];
   
    [self updateBottomView];
    
    [self updateShareButton];
}

- (void)updateBottomView {
    
    if (self.courtJoin.status == JoinStatusRefund && self.courtJoin.userList.count == 0) {
        self.courtPoolFriendScrollView.hidden = YES;
        return;
    }
    
    
    for (UIView *view in self.courtPoolFriendScrollView.subviews) {
        if ([view isKindOfClass:[AvatarLabelView class]]) {
            [view removeFromSuperview];
        }
    }
    
    CGFloat width = [AvatarLabelView defaultSize].width;
    CGFloat height = [AvatarLabelView defaultSize].height;
    NSUInteger space = 25;
    int margin = 25;
    int index = 0;
    int x = margin;
    int y = 13;
    while (index < self.courtJoin.alreadyJoinNumber + self.courtJoin.leftJoinNumber) {
        AvatarLabelView *view = [AvatarLabelView createAvatarLabelViewWithFrame:(CGRectMake(x, y, width, height))];
        view.delegate = self;
        if (index < self.courtJoin.userList.count) {
            CourtJoinUser *user = self.courtJoin.userList[index];
            [view updateAvatarWithUser:user];
        } else {
            [view updateAvatarWithUser:nil];
        }
        
        [self.courtPoolFriendScrollView addSubview:view];
        x = x + width + space;
        
        index ++;
    }
    
    self.courtPoolFriendScrollView.contentSize = CGSizeMake(index * width + (index - 1) * space + 2*margin, self.courtPoolFriendScrollView.bounds.size.height);
}

-(void) updateShareButton {
    if (self.courtJoin.shareContent) {
        self.rightTopView.rightButton.hidden = NO;
        [self.rightTopView.rightButton addTarget:self
                                          action:@selector(clickShareButton:)
                                forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)clickShareButton:(id)sender
{
    [ShareView popUpViewWithContent:self.courtJoin.shareContent
                        channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatSession),@(ShareChannelWeChatTimeline), @(ShareChannelSina),@(ShareChannelQQ),  nil]
                     viewController:self delegate:self];
}

- (void)didShare:(ShareChannel)channel {
    if (channel == ShareChannelWeChatSession) {
        [MobClickUtils event:umeng_event_court_join_detail_share_success label:@"微信朋友圈"];
    }else if(channel == ShareChannelWeChatTimeline){
        [MobClickUtils event:umeng_event_court_join_detail_share_success label:@"微信好友"];
    } else if (channel == ShareChannelSina) {
        [MobClickUtils event:umeng_event_court_join_detail_share_success label:@"新浪"];
    } else if (channel == ShareChannelQQ) {
        [MobClickUtils event:umeng_event_court_join_detail_share_success label:@"QQ"];
    }

}

- (IBAction)clickVenuesButton:(id)sender {
    BusinessDetailController *controller = [[BusinessDetailController alloc]initWithBusinessId:self.courtJoin.businessId categoryId:self.courtJoin.categoryId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickJoinButton:(id)sender {
    if ([self isLoginAndShowLoginIfNot]) {
        [self submitOrder];
    }
}

- (void)queryNeedPay
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        
        self.startTime = mach_absolute_time();
        [OrderService queryNeedPayOrderCount:self userId:user.userId];
    }
}

- (void)didQueryNeedPayOrderCount:(NSString *)status
                            count:(NSUInteger)count
                            order:(Order *)order
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.needPayOrder = order;
    }
}

- (void)submitOrder {
    if (_needPayOrder) {
        UnpaidOrderAlertView *alertView = [UnpaidOrderAlertView createUnpaidOrderAlertView];
        alertView.delegate = self;
        [alertView updateViewWithOrder:_needPayOrder];
        [alertView show];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    
    [SportProgressView showWithStatus:@"加载中"];
    User *me = [[UserManager defaultManager] readCurrentUser];
    [CourtJoinService getCourtJoinInfo:self.courtJoinId userId:me.userId completion:^(NSString *status,NSString *msg, CourtJoin *courtJoin){
        if ([status isEqualToString:STATUS_SUCCESS]) {
            
            [SportProgressView dismiss];
            weakSelf.courtJoin = courtJoin;

            if (weakSelf.courtJoin.available) {
                [MobClickUtils event:umeng_event_court_join_confirm_order label:self.from];
                
                CourtJoinConfirmOrderController *controller = [[CourtJoinConfirmOrderController alloc] initWithCourtJoin:weakSelf.courtJoin];
                [weakSelf.navigationController pushViewController:controller animated:YES];
            } else {
                
                if(weakSelf.courtJoin.leftJoinNumber == 0 || weakSelf.courtJoin.status != JoinStatusPooling) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"球局状态发生了改变，无法加入" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                    [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    
                    return;
                }
                
                [weakSelf updateViewWithCourtJoin:weakSelf.courtJoin];
            }
            
        } else {
            [SportProgressView dismissWithError:msg];
        }
        
    }];
}

#define TAG_ALERT_VIEW_CANCEL_ORDER 2014121201
- (void)didClickUnpaidOrderAlertViewPayButton
{
    //    [OrderManager checkOrderStatus:_needPayOrder];
    //
    //    if (_needPayOrder.status == OrderStatusCancelled) {
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

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titleList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *value = self.titleList[indexPath.row];
    if ([value isEqualToString:TITLE_TIME] && self.courtJoin.productList.count > 1){
        return [self getTimeCellHeight];
    } else {
        return [CourtJoinInfoCell getCellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *value = self.titleList[indexPath.row];
    
    NSString *identifier = [CourtJoinInfoCell getCellIdentifier];
    CourtJoinInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    NSString *subValue = @"";
    NSAttributedString *subValueAtriStr = nil;
    BOOL isShowArrow = NO;
    if([value isEqualToString:TITLE_COST]){
        subValue = [PriceUtil toPriceStringWithYuan:self.courtJoin.price];
    }else if([value isEqualToString:TITLE_DATE]) {
        subValue = [DateUtil dateStringWithTodayAndOtherWeekday:self.courtJoin.bookDate];
    }else if ([value isEqualToString:TITLE_TIME]){
        NSMutableString *courtTimeStr = [NSMutableString string];
        int index = 0;
        for (Product *product in self.courtJoin.productList) {
            [courtTimeStr appendString:[NSString stringWithFormat:@"%@ %@", product.courtName, [product startTimeToEndTime]]];
            
            if (index < [self.courtJoin.productList count] - 1) {
                [courtTimeStr appendString:@"\n"];
            }
            
            index++;
        }
        
        subValue = courtTimeStr;
//        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:courtTimeStr];
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle setLineSpacing:10];
//        [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, courtTimeStr.length)];
//        
//        subValueAtriStr = attributeString;
    
    }else if ([value isEqualToString:TITLE_CATEGORY]) {
        subValue = self.courtJoin.categoryName;
      } else if ([value isEqualToString:TITLE_VENUE]) {
        subValue = self.courtJoin.businessName;
        isShowArrow = YES;
    }else if ([value isEqualToString:TITLE_ADDRESS]) {
        //不显示标题
        value = @"";
        subValue = self.courtJoin.address;
        isShowArrow = YES;
    }
    
    cell.userInteractionEnabled = isShowArrow;
    
    [cell updateViewWithTitle:value detail:subValue isShowArrow:isShowArrow];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *value = self.titleList[indexPath.row];

    if ([value isEqualToString:TITLE_VENUE]) {
        BusinessDetailController *controller = [[BusinessDetailController alloc]initWithBusinessId:self.courtJoin.businessId categoryId:self.courtJoin.categoryId];
        [self.navigationController pushViewController:controller animated:YES];

    }else if ([value isEqualToString:TITLE_ADDRESS]) {

        BusinessMapController *controller = [[BusinessMapController alloc] initWithLatitude:self.courtJoin.latitude
                                                                                  longitude:self.courtJoin.longtitude
                                                                               businessName:self.courtJoin.businessName
                                                                            businessAddress:self.courtJoin.address
                                                                             parkingLotList:nil
                                                                                 businessId:self.courtJoin.businessId
                                                                                 categoryId:self.courtJoin.categoryId
                                                                                       type:0];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
     [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

-(CGFloat) getTimeCellHeight {
    return self.courtJoin.productList.count > 1 ?[CourtJoinInfoCell getCellHeight]* 0.5  * (self.courtJoin.productList.count):[CourtJoinInfoCell getCellHeight];
}

- (IBAction)clickIMButton:(id)sender {
    if ([self isLoginAndShowLoginIfNot]) {
        [self doIMButton];
    }
}

-(void) doIMButton {
    [MobClickUtils event:umeng_event_court_join_detail_im];
    ConversationViewController *conversationVC = [[ConversationViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = self.courtJoin.courtUserId;
    conversationVC.title = self.courtJoin.nickName;
    
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (IBAction)clickUserAvatarButton:(id)sender {
    [self showUserDetailControllerWithUserId:self.courtJoin.courtUserId];
}

-(void)didClickAvatarButton:(NSString *)userId {
    
    [self showUserDetailControllerWithUserId:userId];
}

#pragma mark - LoginDelegate
- (void)didLoginAndPopController:(NSString *)parameter {
    if ([parameter isEqualToString:@"order"]) {
        [self submitOrder];
    } else if ([parameter isEqualToString:@"im"]) {
        [self doIMButton];
    }
}

- (void)showNoticePage
{
    NSString *key = @"has_show_court_join_page";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShowNoticePage =  [userDefaults boolForKey:key];
    if (hasShowNoticePage == NO) {
        [userDefaults setBool:YES forKey:key];
        CourtJoinGuideView *view = [CourtJoinGuideView createCourtJoinGuideView];
        view.superController = self;
        [view show];
    }
}

-(void) pushCourtJoinHelpController {
    BaseConfigManager *manager = [BaseConfigManager defaultManager];
    SportWebController *webController = [[SportWebController alloc]initWithUrlString:manager.courtJoinInstructionUrl title:@"什么是球局"];
    [self.navigationController pushViewController:webController animated:YES];


}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
