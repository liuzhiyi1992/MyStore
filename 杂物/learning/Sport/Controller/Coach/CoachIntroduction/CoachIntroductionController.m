//
//  CoachIntroductionController.m
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachIntroductionController.h"
#import "UIView+Utils.h"
#import "Coach.h"
#import "CoachTimeView.h"
#import "CoachPhoto.h"
#import "SportMWPhoto.h"
#import "PostPhoto.h"
#import "SportMWPhotoBrowser.h"
#import "ConversationViewController.h"
#import "CoachCommentListController.h"
#import "LoginController.h"
#import "AlbumSingleView.h"
#import "CoachAddressView.h"
#import "CoachService.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "CoachOrderController.h"
//#import "CoachCollectAndShareView.h"
#import "ShareView.h"
#import "SportProgressView.h"
#import "GoSportUrlAnalysis.h"
#import "BasicInfoView.h"
#import "UIColor+HexColor.h"
#import "CoachInfoHolderView.h"
#import "CoachBookingInfoHolderView.h"
#import "CoachOrderController.h"
#import "CollectAndShareButtonView.h"

#define COACH_DISPLAY_STATUS_SHOW       @"1"
#define COACH_DISPLAY_STATUS_NOT        @"0"
#define COACH_DISPLAY_STATUS_EDIT       @"2"
#define COACH_DISPLAY_STATUS_BANNED     @"3"
#define COACH_DISPLAY_STATUS_SOLDOFF    @"4"

#define DISPLAY_EDIT_TIPS               @"陪练资料已修改，审核中……"
#define DISPLAY_BANNED_TIPS             @"陪练暂时下线"
#define DISPLAY_SOLDOFF_TIPS            @"陪练已被下线"

@interface CoachIntroductionController () <UIScrollViewDelegate,AlbumSingleViewDelegate,CoachServiceDelegate>

@property (assign, nonatomic) BOOL isShowTransparentBar;
@property (copy, nonatomic) NSString *coachId;
@property (strong, nonatomic) NSArray *coachBookingInfoList;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *photoHolderView;
@property (strong, nonatomic) UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIView *baseHolderView;
@property (weak, nonatomic) IBOutlet UIView *timeHolderView;
@property (strong, nonatomic) NSMutableArray *photoList;
@property (strong, nonatomic) Coach *coach;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoHolderViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *commentEntranceView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainScrollViewBottomConstraint;
@property (strong, nonatomic) CollectAndShareButtonView *rightTopView;
@property (copy, nonatomic) NSString *urlString;
@property (strong, nonatomic) UILabel *photoCountLabel;
@property (weak, nonatomic) IBOutlet UIView *tipsView;
@property (assign, nonatomic) BOOL isRefreshData;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) dispatch_semaphore_t updateSemaphore;
@property (strong, nonatomic) dispatch_queue_t updateQueue;

@end

@implementation CoachIntroductionController


#define SPACE   6
#define WIDTH  ([UIScreen mainScreen].bounds.size.width - SPACE * 4) / 3

- (instancetype)initWithCoachId:(NSString *)coachId {
    self = [super init];
    if (self) {
        self.coachId = coachId;
        self.isRefreshData = YES;
    }
    return self;
}
-(void) dealloc {
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //使用signal协调多个服务请求
    self.updateSemaphore = dispatch_semaphore_create(0);
    self.updateQueue = dispatch_queue_create("serviceQueue", DISPATCH_QUEUE_CONCURRENT);
    
    //底层先creatTitleLabel,避免而后得到数据再创建出现闪烁飞入
    self.title = @"";
//    [self createCollectAndShareButtonView];
    self.photoHolderViewHeightConstraint.constant = WIDTH + 88;
    self.photoScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 6, [UIScreen mainScreen].bounds.size.width, WIDTH)];
    self.photoScrollView.bounces = NO;
    [self.photoHolderView addSubview:self.photoScrollView];
    self.bottomView.hidden = YES;
    [self initPhotoCountLabel];
    self.mainScrollView.hidden = YES;
    self.tipsView.hidden = YES;
    [self.commentButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
}

- (void)initPhotoCountLabel {
    self.photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - SPACE - 32, WIDTH - 10, 32, 16)];
    [self.photoHolderView addSubview:self.photoCountLabel];
    self.photoCountLabel.textColor = [UIColor whiteColor];
    self.photoCountLabel.font = [UIFont systemFontOfSize:10.0];
    self.photoCountLabel.textAlignment = NSTextAlignmentCenter;
    self.photoCountLabel.layer.cornerRadius = 1;
    self.photoCountLabel.clipsToBounds = YES;
    self.photoCountLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryNeedPay];
    if (self.isRefreshData) {
        [self queryData];
    }
}

- (void)createCollectAndShareButtonView
{
    //创建右上角的收藏、分享按钮
    if (_rightTopView == nil) {
        self.rightTopView = [CollectAndShareButtonView createCollectAndShareButtonView];
        [self.rightTopView.leftButton addTarget:self
                                            action:@selector(clickCollectButton:)
                                  forControlEvents:UIControlEventTouchUpInside];
        [self.rightTopView.rightButton addTarget:self
                                          action:@selector(clickShareButton:)
                                forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightTopView] ;
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
}

#define TAG_PHOTO   2015072201
- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中..."];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [CoachService getCoachInfo:self userId:user.userId coachId:self.coachId];
    [CoachService getCoachBespeakTime:self coachId:_coachId];
}

- (void)queryNeedPay
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        [UserService getMessageCountList:nil
                                   userId:user.userId
                                 deviceId:[SportUUID uuid]];
    }
}

- (void)queryUserInfoData {
    User *user = [[UserManager defaultManager] readCurrentUser];
    [CoachService getCoachInfo:self userId:user.userId coachId:self.coachId];
}

- (void)didClickNoDataViewRefreshButton {
    [self queryData];
}

- (void)trunkUpdateUI {
    //两个接口成功，取消菊花
    [SportProgressView dismiss];
    [self updateTimeView];
    self.mainScrollView.hidden = NO;
    [self removeNoDataView];
}

- (void)didGetCoachInfo:(Coach *)coach status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.coach = coach;
        self.photoList = [NSMutableArray array];
        CoachPhoto *onePhoto = [[CoachPhoto alloc] init];
        onePhoto.photoUrl = self.coach.avatarOriginalUrl;
        onePhoto.thumbUrl = self.coach.avatarUrl;
        [self.photoList addObject:onePhoto];
        [self.photoList addObjectsFromArray:self.coach.photoList];
        self.urlString = [self createShareUrl];
        [self updateAllUserInfoView];
        
        //signal监听
        __weak CoachIntroductionController *weakSelf = self;
        dispatch_async(weakSelf.updateQueue, ^{
            dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 40 * NSEC_PER_SEC);
            if (weakSelf.updateSemaphore == nil) {
                return;
            }
            
            long pass = dispatch_semaphore_wait(weakSelf.updateSemaphore, timeout);
            if (pass == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf trunkUpdateUI];
                });
            }
        });
        
        if ([coach.isShow isEqualToString:@"1"]) {
            self.tipsView.hidden = YES;
        }else {
            self.tipsView.hidden = NO;
            UILabel *tipsLabel = (UILabel *)[self.tipsView viewWithTag:10];
            if([coach.isShow isEqualToString:COACH_DISPLAY_STATUS_EDIT]) {//资料修改
                tipsLabel.text = DISPLAY_EDIT_TIPS;
            }else if ([coach.isShow isEqualToString:COACH_DISPLAY_STATUS_BANNED]) {//封禁
                tipsLabel.text = DISPLAY_BANNED_TIPS;
            }else if ([coach.isShow isEqualToString:COACH_DISPLAY_STATUS_SOLDOFF]) {//下架
                tipsLabel.text = DISPLAY_SOLDOFF_TIPS;
            }
        }
    } else {
        //只要有一个失败，取消菊花
        [SportProgressView dismiss];
        [self removeNoDataView];
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
    }
}

- (void)didGetCoachBookingInfo:(NSArray *)infoList status:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.coachBookingInfoList = infoList;
        
        //signal发送
        __weak CoachIntroductionController *weakSelf = self;
        dispatch_async(weakSelf.updateQueue, ^{
           dispatch_semaphore_signal(weakSelf.updateSemaphore);
        });
    } else {
        //只要有一个失败，取消菊花
        [SportProgressView dismiss];
        [self removeNoDataView];
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
    }
}

- (void)updateAllUserInfoView {
    [self updateBaseUserInfo];
    [self updateAlbumView];
    [self updateBaseView];
    if (self.coach.commentCount == 0) {
        [self.commentEntranceView removeFromSuperview];
    } else {
        self.commentEntranceView.hidden = NO;
    }
}

- (void)updateBaseUserInfo {
    //避免网络不好时也可以点击进入下一个页面
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId isEqualToString:self.coachId]) {
        self.bottomView.hidden = YES;
        self.mainScrollViewBottomConstraint.constant = 0;
        [self cleanRightTopButton];
        [self createCollectAndShareButtonView];
        self.rightTopView.leftButton.hidden = YES;
    }else if ( ! [self.coach.isShow isEqualToString:COACH_DISPLAY_STATUS_SHOW]) {
        self.bottomView.hidden = YES;
        self.mainScrollViewBottomConstraint.constant = 0;
        [self cleanRightTopButton];
    }else {
        self.bottomView.hidden = NO;
        self.mainScrollViewBottomConstraint.constant = 49;
        [self createCollectAndShareButtonView];
    }
    BasicInfoView *basicInfoView = [BasicInfoView createBasicInfoView];
    basicInfoView.frame = CGRectMake(0, WIDTH +SPACE + 8, [UIScreen mainScreen].bounds.size.width, 74);
    [basicInfoView updateWithUser:self.coach];
    [self.photoHolderView addSubview:basicInfoView];
    self.title = self.coach.name;
    self.rightTopView.leftButton.selected = self.coach.isCollect;
    self.commentCountLabel.text = [NSString stringWithFormat:@"%d条",self.coach.commentCount];
    self.photoCountLabel.text = [NSString stringWithFormat:@"共%@张",[@(self.photoList.count) stringValue]];
    self.photoCountLabel.backgroundColor = [UIColor hexColor:@"000000" withAlpha:0.5];
}

- (void)updateAlbumView
{
    for (UIView *subView in self.photoScrollView.subviews) {
        if ([subView isKindOfClass:[AlbumSingleView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    int index = 0;
    CGFloat startX = SPACE;
    CGFloat space = SPACE;
    
    for (CoachPhoto *onePhoto in self.photoList) {
        AlbumSingleView *view = [AlbumSingleView createBookingSimpleView];
        CGRect frame = view.frame;
        frame.size = CGSizeMake(WIDTH, WIDTH);
        view.frame = frame;
        view.delegate = (id)self;
        [view updatView:onePhoto index:index];
        [view updateOriginX:startX + index * (space + view.frame.size.width)];
        [view updateOriginY:0];
        [self.photoScrollView addSubview:view];
        index ++;
    }
    [self.photoScrollView setContentSize:CGSizeMake(startX + index * WIDTH + (index - 1) * space + startX, self.photoScrollView.frame.size.height)];
    self.photoScrollView.showsHorizontalScrollIndicator = NO;
}

#define TAG_BASE    2015072202
- (void)updateBaseView
{
    [[self.baseHolderView viewWithTag:TAG_BASE] removeFromSuperview];
//    CoachAddressView *view = [CoachAddressView createViewWithCoach:self.coach];
    CoachInfoHolderView *view = [CoachInfoHolderView createViewWithCoach:self.coach];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    
    view.tag = TAG_BASE;
    [self.baseHolderView addSubview:view];
    
    [self.baseHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views]];
    [self.baseHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
}

#define TAG_TIME    2015072302
- (void)updateTimeView
{
    [[self.timeHolderView viewWithTag:TAG_TIME] removeFromSuperview];
    
    CoachTimeView *timeView = [CoachTimeView createViewWithCoachBookingInfoList:self.coachBookingInfoList];
    
    CoachBookingInfoHolderView *bookingInfoHolderView = [CoachBookingInfoHolderView creatCoachBookingInfoHolderViewWithProjectList:_coach.coachProjectsList];
    bookingInfoHolderView.superViewController = self;
    
    [bookingInfoHolderView.drawerHolderView addSubview:timeView];
    
    timeView.translatesAutoresizingMaskIntoConstraints = NO;
    bookingInfoHolderView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableDictionary *views = [NSMutableDictionary dictionary];
    [views addEntriesFromDictionary:@{@"timeView":timeView,@"headerView":bookingInfoHolderView.headerView,@"bookingInfoHolderView":bookingInfoHolderView}];
    
    [bookingInfoHolderView.drawerHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[timeView]|" options:0 metrics:nil views:views]];
    [bookingInfoHolderView.drawerHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timeView]|" options:0 metrics:nil views:views]];
    
    bookingInfoHolderView.tag = TAG_TIME;

    [self.timeHolderView addSubview:bookingInfoHolderView];
    [self.timeHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bookingInfoHolderView]|" options:0 metrics:nil views:views]];
    [self.timeHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bookingInfoHolderView]|" options:0 metrics:nil views:views]];
}

#define TAG_COMMENT    2015072701

- (void)didClickAlbumSingleView:(int)index
{
    self.isRefreshData = NO;
    NSMutableArray *list = [NSMutableArray array];
    int i = 0;
    for (CoachPhoto *onePhoto in self.photoList) {
        SportMWPhoto *mwPhoto = [SportMWPhoto photoWithURL:[NSURL URLWithString:onePhoto.photoUrl]];
        mwPhoto.index = i++;
        [list addObject:mwPhoto];
    }
    SportMWPhotoBrowser *controller = [[SportMWPhotoBrowser alloc] initWithPhotoList:list openIndex:index];
    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:modelNavigationController animated:YES completion:nil];
}

- (IBAction)clickCollectButton:(id)sender {
    [MobClickUtils event:umeng_event_business_detail_click_collect];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        
        if (self.coach.isCollect) {
            [SportProgressView showWithStatus:@"正在取消收藏..."];
            [CoachService userCollectionCoach:self userId:user.userId coachId:self.coachId type:2];
            
        } else {
            [SportProgressView showWithStatus:DDTF(@"kAddingFavorite")];
            [CoachService userCollectionCoach:self userId:user.userId coachId:self.coachId type:1];
        }
        
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didUserCollectionCoach:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        [self queryUserInfoData];
    } else {
        [SportProgressView dismissWithError:DDTF(@"kAddFavoriteFail")];
    }
}

- (NSString *)createShareUrl {
    NSString *urlString = [NSString stringWithFormat:@"gosport://share_info?url=%@&img_url=%@&thumb_url=%@&title=趣运动陪练%@&description=%@",self.coach.coachShareUrl,self.coach.avatarOriginalUrl,self.coach.avatarUrl,self.coach.name,self.coach.introduction];
    
    return urlString;
}

- (IBAction)clickShareButton:(id)sender {
    self.isRefreshData = NO;
    [MobClickUtils event:umeng_event_month_course_detail_click_share];
    
    if ([self.urlString length] > 0) {
        NSString *urlStr = [self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        ShareContent *shareContent = [GoSportUrlAnalysis shareContentWithUrlQuery:url.query];
        [ShareView popUpViewWithContent:shareContent
                            channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatSession), @(ShareChannelQQ),nil]
                         viewController:self delegate:nil];
    }else {
        [SportPopupView popupWithMessage:@"分享还没准备好"];
    }
}

- (IBAction)clickChatButton:(id)sender {
    self.isRefreshData = NO;
    [MobClickUtils event:umeng_event_click_coach_detail_chat];
    if ([self isLoginAndShowLoginIfNot]) {
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([user.userId isEqualToString:self.coach.coachId]) {
            [SportPopupView popupWithMessage:@"不可与自己聊天"];
            return;
        }
        
        if ([self previousControllerIsConversationController]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        ConversationViewController *_conversationVC = [[ConversationViewController alloc]init];
        _conversationVC.conversationType = ConversationType_PRIVATE;
        _conversationVC.targetId = self.coach.rongId;
//        _conversationVC.userName = self.coach.name;
        _conversationVC.title = self.coach.name;
        
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }
}

- (IBAction)clickBookButton:(id)sender {
    [MobClickUtils event:umeng_event_click_coach_detail_booking];
    if ([self isLoginAndShowLoginIfNot]) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([user.userId isEqualToString:self.coach.coachId]) {
            [SportPopupView popupWithMessage:@"不可预约自己"];
            return;
        }
        
        CoachOrderController *controller = [[CoachOrderController alloc] initWithCoach:self.coach project:self.coach.coachProjectsList[0]] ;
        [self.navigationController pushViewController:controller animated:YES];
        self.isRefreshData = YES;
    }
}

- (IBAction)clickCommentEntranceButton:(UIButton *)sender {
    self.isRefreshData = NO;
    CoachCommentListController *controller = [[CoachCommentListController alloc] initWithCoachId:self.coach.coachId type:2];
    [self.navigationController pushViewController:controller animated:YES];
}


- (BOOL)previousControllerIsConversationController //前一个Controller是否CoachConversationViewController
{
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 2) {
        if ([[self.navigationController.viewControllers objectAtIndex:count - 2] isKindOfClass:[ConversationViewController class]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark - CoachItemCell Click Delegate
- (void)coachItemDidBookingWithProject:(CoachProjects *)project {
    [MobClickUtils event:umeng_event_click_coach_detail_booking];
    if ([self isLoginAndShowLoginIfNot]) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([user.userId isEqualToString:self.coach.coachId]) {
            [SportPopupView popupWithMessage:@"不可预约自己"];
            return;
        }
        CoachOrderController *controller = [[CoachOrderController alloc] initWithCoach:self.coach project:project];
        [self.navigationController pushViewController:controller animated:YES];
        self.isRefreshData = YES;
    }
}

@end
