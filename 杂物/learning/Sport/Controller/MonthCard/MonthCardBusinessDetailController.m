//
//  MonthCardBusinessDetailController.m
//  Sport
//
//  Created by qiuhaodong on 15/6/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardBusinessDetailController.h"
#import "MonthCardService.h"
#import "UIButton+WebCache.h"
#import "Business.h"
#import "UIView+Utils.h"
#import "FacilityView.h"
#import "ServiceView.h"
#import "BusinessPhotoBrowser.h"
#import "UIUtils.h"
#import "SportPopupView.h"
#import "BusinessMapController.h"
#import "MonthCardRechargeController.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import "ShareView.h"
#import "MonthCardFinishPayController.h"
#import "LoginController.h"
#import "BusinessCategory.h"
#import "UIImageView+WebCache.h"

@interface MonthCardBusinessDetailController ()<MonthCardServiceDelegate, LoginDelegate, ServiceViewDelegate>

@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *categoryId;
@property (strong, nonatomic) Business *business;
@property (assign, nonatomic) int monthCardStatus;

@property (weak, nonatomic) IBOutlet UIView *categoryHolderView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIButton *mainImageButton;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UIView *baseHolderView;

@property (weak, nonatomic) IBOutlet UIView *facilityHolderView;
@property (weak, nonatomic) IBOutlet UIView *serviceHolderView;
@property (weak, nonatomic) IBOutlet UIView *contactHolderView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UILabel *statusTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusSubTitleLabel;
@property (assign, nonatomic) BOOL isClickButton;
@property (weak, nonatomic) IBOutlet UIView *smallCategoryImageListHolderView;

@end

@implementation MonthCardBusinessDetailController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithBusinessId:(NSString *)businessId
                        categoryId:(NSString *)categoryId
{
    self = [super init];
    if (self) {
        self.businessId = businessId;
        self.categoryId = categoryId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"场馆介绍";
    [self.bottomHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - self.bottomHolderView.frame.size.height];
    [self.mainScrollView updateHeight:self.bottomHolderView.frame.origin.y];
    [self.view sportUpdateAllBackground];
    [self createRightTopImageButton:[SportImage shareButtonImage]];
    [self.bottomButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    self.bottomHolderView.hidden = YES;
    self.isClickButton = NO;
    [self queryData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isClickButton == YES) {
        [self queryData];
        self.isClickButton = NO;
    }
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_month_business_detail_click_share];
    
    ShareContent *shareContent = [[ShareContent alloc] init] ;
    shareContent.thumbImage = [UIImage imageNamed:@"defaultIcon"];
    shareContent.title = _business.name;
    shareContent.subTitle = _business.address;
    
    shareContent.image = nil;
    shareContent.content = [NSString stringWithFormat:@"我在动Club上发现一个不错的场馆，我们一起去运动吧。%@，地址:%@", _business.name, _business.address];
    shareContent.linkUrl = _business.monthCardShareUrl;
    
    [ShareView popUpViewWithContent:shareContent channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatTimeline), @(ShareChannelWeChatSession), @(ShareChannelSina), @(ShareChannelSMS), nil] viewController:self delegate:nil];
}

- (void)queryData
{
    [MonthCardService venuesInfo:self
                      businessId:_businessId
                      categoryId:_categoryId];
}

- (void)didVenuesInfo:(Business *)business monthCardStatus:(int)monthCardStatus status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.business = business;
        self.monthCardStatus = monthCardStatus;
        [self updateAllInfoUI];
        [self removeNoDataView];
    } else {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height - 20 - 44);
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (void)updateAllInfoUI
{
    [self updateBaseHolderView];
    [self updateCategoryHolderView];
    [self updateFacilityHolderView];
    [self updateServiceHolderView];
    [self updateContactHolderView];
    
    [self updateBottomButtonStatus];
    
    [self updateAllViewSite];
}

- (void)updateCategoryImageList
{
    for (UIView *subView in self.smallCategoryImageListHolderView.subviews) {
        [subView removeFromSuperview];
    }

    int index = 0;
    CGFloat space = 4;
    for (BusinessCategory *category in self.business.categoryList) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)] ;
        [imageView updateOriginX:(space + imageView.frame.size.width) * index];
        [self.smallCategoryImageListHolderView addSubview:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:category.smallImageUrl]];
        index ++;
    }
}

#define WIDTH_ANNOUNCEMENT_TEXT_VIEW ([UIScreen mainScreen].bounds.size.width - 20)
#define MIN_HEIGHT_BASE_BACKGROUND 115
#define TAG_RATING_BASE 10
#define TAG_NOTICE  2015061901
- (void)updateBaseHolderView
{
    [self.mainImageButton sd_setImageWithURL:[NSURL URLWithString:_business.imageUrl]
                                    forState:UIControlStateNormal
                            placeholderImage:[SportImage defaultImage_143x115]];
    
    self.businessNameLabel.text = _business.name;
    
    [self updateCategoryImageList];
    
    //设置温馨提示
    [[_baseHolderView viewWithTag:TAG_NOTICE] removeFromSuperview];
    
    if ([_business.moncardNotice length] > 0) {
        UITextView *view = [self createAnnouncementTextView];
        view.tag = TAG_NOTICE;
        view.text = self.business.moncardNotice;
        CGSize size = [view sizeThatFits:CGSizeMake(WIDTH_ANNOUNCEMENT_TEXT_VIEW, 600)];
        [view updateHeight:size.height];
        [view updateOriginY:MIN_HEIGHT_BASE_BACKGROUND + 5];
        [self.baseHolderView addSubview:view];
        
        [_baseHolderView updateHeight:view.frame.origin.y + view.frame.size.height + 5];
        [[_baseHolderView viewWithTag:100] setHidden:NO];
    } else {
        [self.baseHolderView updateHeight:MIN_HEIGHT_BASE_BACKGROUND];
        [[_baseHolderView viewWithTag:100] setHidden:YES];
    }
}

- (UITextView *)createAnnouncementTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - WIDTH_ANNOUNCEMENT_TEXT_VIEW) / 2, 0, WIDTH_ANNOUNCEMENT_TEXT_VIEW, 200)] ;
    textView.backgroundColor = [UIColor clearColor];
    [textView setTextColor:[UIColor colorWithRed:93.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:1]];
    textView.font = [UIFont systemFontOfSize:14];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    if ([textView respondsToSelector:@selector(setSelectable:)]) {
        textView.selectable = NO;
    }
    return textView;
}

//设置categoryHolderView
- (void)updateCategoryHolderView
{
    for (UIView *subView in self.categoryHolderView.subviews) {
        [subView removeFromSuperview];
    }
    
    CategoryButtonListView *view = [CategoryButtonListView createViewWithCategoryList:_business.categoryList
                                                                   selectedCategoryId:_categoryId
                                                                             delegate:self];
    [self.categoryHolderView addSubview:view];
}

- (void)didClickCategoryButtonListView:(NSString *)categoryId
{
    self.categoryId = categoryId;
    [self queryData];
}

//设置facilityHolderView
- (void)updateFacilityHolderView
{
    for (UIView *subView in self.facilityHolderView.subviews) {
        [subView removeFromSuperview];
    }
    
    FacilityView *view = [FacilityView createViewWithFacilityList:self.business.facilityList
                                                       businessId:self.business.businessId
                                                       categoryId:self.business.defaultCategoryId
                                                       controller:self
                                                  imageTotalCount:self.business.imageCount];
    [self.facilityHolderView addSubview:view];
    [self.facilityHolderView updateHeight:view.frame.size.height];
}

//设置serviceHolderView
- (void)updateServiceHolderView
{
    for (UIView *subView in self.serviceHolderView.subviews) {
        [subView removeFromSuperview];
    }
    
    ServiceView *view = [ServiceView createViewWithServiceList:self.business.serviceGroupList
                                                    controller:self
                                                      delegate:self];
    [self.serviceHolderView addSubview:view];
    [self.serviceHolderView updateHeight:view.frame.size.height];
}

- (BOOL)hasFacility
{
    return ([self.business.facilityList count] > 0);
}

- (BOOL)hasService
{
    return ([self.business.serviceGroupList count] > 0);
}

//设置电话、地址
- (BOOL)hasContact
{
    if ([_business.telephone length] > 0
        || [_business.address length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)updateContactHolderView
{
    self.phoneLabel.text = _business.telephone;
    self.addressLabel.text = _business.address;
}

#define  SPACE_BETWEEN_HOLDERVIEW 8
- (void)updateAllViewSite
{
    CGFloat y = _baseHolderView.frame.origin.y + _baseHolderView.frame.size.height;
    
    [self.categoryHolderView updateOriginY:y];
    y = y + _categoryHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    
    if ([self hasFacility]) {
        _facilityHolderView.hidden = NO;
        [_facilityHolderView updateOriginY:y];
        y = y + _facilityHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else {
        _facilityHolderView.hidden = YES;
    }
    
    if ([self hasService]) {
        _serviceHolderView.hidden = NO;
        [_serviceHolderView updateOriginY:y];
        y = y + _serviceHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else {
        _serviceHolderView.hidden = YES;
    }
    
    if ([self hasContact]) {
        _contactHolderView.hidden = NO;
        [_contactHolderView updateOriginY:y];
        y = y + _contactHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else {
        _contactHolderView.hidden = YES;
    }
    
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, y)];
}

- (IBAction)clickMainImageButton:(id)sender {
    [MobClickUtils event:umeng_event_month_business_detail_click_gallery];
    BusinessPhotoBrowser *browser = [[BusinessPhotoBrowser alloc] initWithOpenIndex:0
                                                                         businessId:_businessId
                                                                         categoryId:_categoryId
                                                                         totalCount:_business.imageCount
                                                                           business:nil];
    
    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:browser];
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:modelNavigationController animated:YES completion:nil];
    
}

- (IBAction)clickPhoneButton:(id)sender {
    [MobClickUtils event:umeng_event_month_business_detail_click_phone];
    BOOL result = [UIUtils makePromptCall:_business.telephone];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

- (IBAction)clickAddressButton:(id)sender {
    [MobClickUtils event:umeng_event_month_business_detail_click_address];
    BusinessMapController *controller = [[[BusinessMapController alloc] init] initWithLatitude:_business.latitude
                                                                                      longitude:_business.longitude
                                                                                businessName:_business.name
                                                                                businessAddress:_business.address
                                                                                parkingLotList:nil
                                                                                    businessId:_business.businessId
                                                                                    categoryId:_categoryId                                                                                         type:0];
    [self.navigationController pushViewController:controller animated:YES];
}

#define IMAGE_1 [SportImage blueButtonImage]
#define IMAGE_2 [SportImage orangeButtonImage]
#define IMAGE_3 [SportImage grayButtonImage]
- (void)updateBottomButtonStatus
{
    self.bottomHolderView.hidden = NO;
    NSArray *titleArray = nil;
    UIImage *buttonImage = nil;
    BOOL canClick = NO;
    switch (self.monthCardStatus) {
        case 1:
        case 5:
        case 9:
        case 8:
            titleArray = @[@"无需预约，直接到店消费即可"];
            buttonImage = IMAGE_3;
            break;
        case 7:
            titleArray = @[@"不可使用",@"本月该场馆的消费次数已用完"];
            buttonImage = IMAGE_3;
            break;
        case 0:
            titleArray = @[@"加入动Club，即可使用"];
            buttonImage = IMAGE_2;
            canClick = YES;
            break;
        case 4:
            titleArray = @[@"续费即可以使用", @"你的动Club会员已过期"];
            buttonImage = IMAGE_2;
            canClick = YES;
            break;
        case 3:
        case 6:
            titleArray = @[@"不可使用",@"你的动Club会员被冻结"];
            buttonImage = IMAGE_3;
            break;
        case 2:
            titleArray = @[@"使用前请先上传头像"];
            buttonImage = IMAGE_1;
            canClick = YES;
            break;
        default:
            titleArray = @[@"未知状态"];
            buttonImage = IMAGE_3;
            canClick = YES;
            break;
    }
    
    self.statusTitleLabel.text = [titleArray objectAtIndex:0];
    if ([titleArray count] > 1) {
        self.statusSubTitleLabel.hidden = NO;
        self.statusSubTitleLabel.text = [titleArray objectAtIndex:1];
    } else {
        self.statusSubTitleLabel.hidden = YES;
        [self.statusTitleLabel updateCenterY:self.bottomButton.center.y];
    }
    [self.bottomButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    self.bottomButton.userInteractionEnabled = canClick;
}

- (IBAction)clickBottomButton:(id)sender {
    self.isClickButton = YES;
    switch (self.monthCardStatus) {
        case 0:
        case 4:
        {
            if (![UserManager isLogin]) {
                LoginController *controller = [[LoginController alloc] init] ;
                controller.loginDelegate = self;
                controller.loginDelegateParameter = @"buy";
                [self.navigationController pushViewController:controller animated:YES];
            } else {
                [self pushRechargeController];
            }
            break;
        }
        case 2:
        {
            [MobClickUtils event:umeng_event_month_business_detail_click_upload_portrait];
            MonthCardFinishPayController *controller = [[MonthCardFinishPayController alloc] init] ;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)pushRechargeController
{
    [MobClickUtils event:umeng_event_month_business_detail_click_buy];
    MonthCardRechargeController *controller = [[MonthCardRechargeController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didLoginAndPopController:(NSString *)parameter
{
    if ([parameter isEqualToString:@"buy"]) {
        [self pushRechargeController];
    }
}

@end
