//
//  MembershipCardListController.m
//  Sport
//
//  Created by 江彦聪 on 15/4/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MembershipCardListController.h"
#import "AddMembershipCardController.h"
#import "MembershipCardDetailController.h"
#import "SportPopupView.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "BaseConfigManager.h"
#import "UIScrollView+SportRefresh.h"
#import "UITableView+Utils.h"
#import "TipNumberManager.h"

@interface MembershipCardListController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *selectedCardList;
@property (assign, nonatomic) BOOL isBindOne;   //当扫描一张已绑定的会员卡时
@property (assign, nonatomic) int page;
@property (assign, nonatomic) int onePageCount;
@property (weak, nonatomic) IBOutlet UIButton *addCardButton;
@property (weak, nonatomic) IBOutlet UIButton *addNoneCardButton;
@property (weak, nonatomic) IBOutlet UIView *noCardView;
@property (weak, nonatomic) IBOutlet UIView *bindCardView;
@property (strong, nonatomic) IBOutlet UIView *headerTitleView;
@property (weak, nonatomic) IBOutlet UIButton *userCardRuleButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardInfoView;

@end

#define COUNT_ONE_PAGE  20
#define PAGE_START      1

#define TAG_SET_PASSWORD_NOTICE 0x001
#define TAG_SET_PASSWORD_DONE 0x002
#define TAG_ASK_FOR_BIND 0x003
#define TAG_BIND_DONE 0x004

@implementation MembershipCardListController


-(id)init
{
    self = [super init];
    if (self) {
        self.isBindOne = NO;
        self.title = @"场馆会员卡";
    }
    
    return self;
}

-(id)initWithBindOneCard:(MembershipCard *)card
{
    self = [super init];
    if (self) {
        self.selectedCardList[0] = card;
        self.isBindOne = YES;
        self.title = @"绑定会员卡";
    }
    
    return self;
}

-(void)setBindOneCard:(MembershipCard *)card
{
    self.selectedCardList[0] = card;
    self.isBindOne = YES;
    self.title = @"绑定会员卡";
    [self.tableView reloadData];
    return;
}

-(NSMutableArray *)selectedCardList
{
    if (_selectedCardList == nil) {
        _selectedCardList = [[NSMutableArray alloc]init];
    }
    
    return _selectedCardList;
}

-(NSMutableArray *)dataList
{
    if (_dataList == nil) {
        _dataList = [[NSMutableArray alloc]init];
    }
    
    return _dataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.page = PAGE_START;
    if (_onePageCount == 0) {
        self.onePageCount = COUNT_ONE_PAGE;
    }

    //Don't show bind button
    self.bindCardView.hidden = YES;
    self.noCardView.hidden = YES;
    self.noDataLabel.hidden = YES;
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    
    if (self.isBindOne == NO) {
        [self createRightTopButton:@"说明"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isBindOne == YES) {
        // 绑定一张扫描的会员卡，不显示右上角的扫描图标
        [self cleanRightTopButton];
    } else {
        [self updateMembershipCard];
    }
}

/**
 *  加载第一页推荐球馆数据
 */
- (void)loadNewData
{
    [self queryData];
}

/**
 *  加载更多推荐球馆数据
 */
- (void)loadMoreData
{
    [self queryData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickAddCardButton:(id)sender {
    [MobClickUtils event:umeng_event_card_page_click_add_card];
    
//    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
//        ZarBarViewController *controller = [[[ZarBarViewController alloc]init]autorelease];
//        [self.navigationController pushViewController:controller animated:YES];
    
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"抱歉，不支持此功能！"
//                                                   message:@"IOS版本太旧，请升级到IOS7.0以上"
//                                                  delegate:self
//                                         cancelButtonTitle:nil
//                                         otherButtonTitles:@"确定", nil];
//        [alertView show];
//        [alertView release];
//    }
//    else {
        AddMembershipCardController *controller = [[AddMembershipCardController alloc]init];
        
        [self.navigationController  pushViewController:controller animated:YES];
    //    }
}

- (void)clickRightTopButton:(id)sender {
    
    //[self clickAddCardButton:sender];
    [self pushCardRule];
}

- (void)showInputPassword
{
    [InputPasswordView popUpViewWithType:InputPasswordTypeSet
                                delegate:self
                                 smsCode:nil];

}

#pragma mark - InputPasswordViewDelegate
- (void)didFinishSetPayPassword:(NSString *)payPassword
                         status:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"设置支付密码成功"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    
    [self updateMembershipCard];
}

- (void)didHideInputPasswordView
{
    [self updateMembershipCard];
}

- (void)updateMembershipCard
{
    [self queryData];
    
    if(self.isBindOne == YES) {
        if (self.navigationItem.rightBarButtonItem == nil) {
            [self createRightTopImageButton:[SportImage scanBarButtonImage]];
        }
        self.title = @"会员卡";
        self.isBindOne = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
//    if ([_dataList count] == 0) {
//        return 0;
//    }
//    
//    return [_dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
//    if (section == 0) {
//        return 0;
//    } else {
//        if ([(NSArray *)[self.dataList objectAtIndex:section] count]) {
//            return self.headerTitleView.frame.size.height;
//        }
//        
//        return 0;
//    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return self.headerTitleView;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dataList count] == 0) {
        return 0;
    }
    
    //扫描一张已绑定的会员卡时
    if (_isBindOne) {
        if (section == 0) {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    
    return [(NSArray *)[_dataList objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MembershipCardCell getCellHeightWithIndex:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataList count] == 0 || [(NSArray *)[self.dataList objectAtIndex:indexPath.section] count] == 0 ) {
        return nil;
    }

    NSMutableArray *cardList = [self.dataList objectAtIndex:indexPath.section];
    
    MembershipCard *card = nil;
    if (_isBindOne) {
        card = self.selectedCardList[0];
    }
    else {
        card = [cardList objectAtIndex:indexPath.row];
    }
    
    NSString *identifier = [MembershipCardCell getCellIdentifier];
    MembershipCardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [MembershipCardCell createCell];
    }
    
    cell.delegate = self;
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [cell updateCellWithCard:card
                  isSelected:NO
                   indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataList count] == 0 || [(NSArray *)[self.dataList objectAtIndex:indexPath.section] count] == 0)
    {
        return;
    }
    
    NSMutableArray *cardArray = [self.dataList objectAtIndex:indexPath.section];
    MembershipCard *card = [cardArray objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0) {
        MembershipCardDetailController *controller = [[MembershipCardDetailController alloc]initWithCard:card] ;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

-(void) queryData
{
    //[SportProgressView showWithStatus:DDTF(@"kLoading")];

    [MembershipCardService getCardList:self];

}

# pragma mark MembershipCardServiceDelegate
- (void)didGetCardList:(NSArray *)cardList
                status:(NSString *)status
                   msg:(NSString *)msg
{
    //[SportProgressView dismiss];
    [self.tableView endLoad];
    NSMutableArray *bindedCardMutableArray = [NSMutableArray array];
    NSMutableArray *unbindedCardMutableArray = [NSMutableArray array];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //清除消息数
        NSUInteger count = [[TipNumberManager defaultManager] newCardCount];
        if (count > 0) {
            [UserService updateMessageCount:nil
                                     userId:[[UserManager defaultManager] readCurrentUser].userId
                                   deviceId:[SportUUID uuid]
                                       type:[@(MessageCountTypeNewCard) stringValue]
                                      count:count];
//            [[TipNumberManager defaultManager] setNewCardCount:0];
        }
        
        for (MembershipCard *card in cardList) {
                [bindedCardMutableArray addObject:card];
        }
        
        //不分页
        self.dataList[0] = bindedCardMutableArray;
        self.dataList[1] = unbindedCardMutableArray;

    }
    
    // 无网络
    if ([self.dataList count] == 0) {
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:self.view.bounds tips:@"网络错误"];
        
    }else if ([(NSArray *)[self.dataList objectAtIndex:0] count] == 0 && [(NSArray *)[self.dataList objectAtIndex:1] count] == 0) {
        
        //无任何会员卡（绑定或者待绑定）
        self.noDataLabel.hidden = NO;
    }
    else {
        self.noDataLabel.hidden = YES;
    }
    
    CGFloat footHeight = [UIScreen mainScreen].bounds.size.height - 20 - 44 -[bindedCardMutableArray count]*[MembershipCardCell getCellHeight];
    
    [self.tableView sizeFooterToFit:footHeight > self.cardInfoView.frame.size.height + 30?footHeight:self.cardInfoView.frame.size.height + 30];
    
    [self.tableView reloadData];
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (void)didBindCard:(NSString *)status
                msg:(NSString *)msg
{
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [MobClickUtils event:umeng_event_card_bind];
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        UIAlertView *alertView = nil;
        if (user.hasPayPassWord) {
            alertView = [[UIAlertView alloc] initWithTitle:@"添加成功！"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_BIND_DONE;
            
        }
        else {
            alertView = [[UIAlertView alloc] initWithTitle:@"添加成功！"
                                               message:@"请设置支付密码保障会员卡资金安全。"
                                              delegate:self
                                     cancelButtonTitle:@"暂时不用"
                                     otherButtonTitles:@"设置密码", nil];
            alertView.tag = TAG_SET_PASSWORD_NOTICE;
        }
        
        [alertView show];
    }else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"网络错误，请重试"];
        }
    }
}

#pragma mark MembershipCardCell delegate
-(void) didClickBindButton:(NSIndexPath *)indexPath
{
    // 已登陆用户，已绑定卡，再扫描时，isBindOne为Yes，selecteCard不为空
    if (_isBindOne != YES) {
        NSMutableArray *cardArray = [self.dataList objectAtIndex:indexPath.section];
        MembershipCard *card = [cardArray objectAtIndex:indexPath.row];

        //only single selected
        self.selectedCardList[0] = card;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否绑定会员卡"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"暂不绑定"
                                              otherButtonTitles:@"绑定", nil];
    alertView.tag = TAG_ASK_FOR_BIND;
    [alertView show];

}

#pragma mark Alert View delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ASK_FOR_BIND) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if (_selectedCardList == nil) {
                HDLog(@"selected card is null!");
                return;
            }
            
            MembershipCard *card = self.selectedCardList[0];
            NSString *userId = [[UserManager defaultManager]readCurrentUser].userId;
            
            // bind request
            [SportProgressView showWithStatus:@"绑定中"];
            [MembershipCardService bindCard:self
                                  cardNumber:card.cardNumber
                                      userId:userId
                                       phone:card.phone];
            
        }
    }else if (alertView.tag == TAG_SET_PASSWORD_NOTICE && buttonIndex != alertView.cancelButtonIndex) {
        [self showInputPassword];
    }
    else {
        [self updateMembershipCard];
    }
}

- (IBAction)clickUserCardRuleButton:(id)sender {
    [self pushCardRule];
}

- (void)pushCardRule {
    [MobClickUtils event:umeng_event_card_help_page];
    
    BaseConfigManager *manager = [BaseConfigManager defaultManager];
    
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:manager.userCardUrl title:@"会员卡使用说明"] ;
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)clickBackButton:(id)sender
{
    if (self.isBindOne == YES) {
        [self updateMembershipCard];
    }
    else
    {
        [super clickBackButton:sender];
    }
}

@end
