//
//  BusinessDetailController.m
//  Sport
//
//  Created by haodong  on 14-8-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BusinessDetailController.h"
#import "Business.h"
#import "SportProgressView.h"
#import "UIButton+WebCache.h"
#import "BusinessCategory.h"
#import "UIView+Utils.h"
#import "DayBookingInfo.h"
#import "BookingDetailController.h"
#import "OtherServiceView.h"
#import "CharacteristicView.h"
#import "UserInfoController.h"
#import "UIUtils.h"
#import "BusinessMapController.h"
#import "CallBookController.h"
#import "UserManager.h"
#import "LoginController.h"
#import "SportPopupView.h"
#import "SingleBookingController.h"
#import "PriceUtil.h"
#import "HistoryManager.h"
#import <QuartzCore/QuartzCore.h>
#import "WriteReviewController.h"
#import "Review.h"
#import "BrowsePhotoView.h"
#import "ReviewListController.h"
#import "Goods.h"
#import "CollectAndShareButtonView.h"
#import "BusinessPhotoBrowser.h"
#import "BaseConfigManager.h"
#import "SportWebController.h"
#import "ForumEntranceView.h"
#import "ShareView.h"
#import "FastLoginController.h"
#import "BookWithPhoneController.h"
#import "BusinessPhoto.h"
#import "ParkingLot.h"
#import "NearbyVenuesView.h"
#import "MapBussinessView.h"
#import "PackageDetailController.h"
#import "UIView+ExtendTouchArea.h"
#import "ReportErrorView.h"

#define REPORT_ERROR_STRING @"场馆信息报错"
#define MARGIN_REPORT_BUTTON 20

@interface BusinessDetailController ()< ServiceViewDelegate,NearbyVenuesViewDelegate, UIAlertViewDelegate>
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *selectedCategoryId;
@property (strong, nonatomic) Business *business;
@property (strong, nonatomic) NSDateFormatter *dateFormat;
@property (strong, nonatomic) NSDate *callBookDate;
@property (assign, nonatomic) int callBookStartHour;
@property (assign, nonatomic) int callBookStartMinute;
@property (assign, nonatomic) int callBookDuration;
@property (strong, nonatomic) NSArray *commentList;
@property (assign, nonatomic) BOOL isSavedHistroy;
@property (strong, nonatomic) NSArray *reviewList;
@property (assign, nonatomic) int totalReviewCount;
@property (assign, nonatomic) BOOL isHasRunEvent;
@property (strong, nonatomic) NSArray *bookingStatisticsList;
@property (strong, nonatomic) ProductInfo *productInfo;
@property (strong, nonatomic) UIImage *businessImage;
@property (strong, nonatomic) CollectAndShareButtonView *rightTopView;
@property (assign, nonatomic) int serviceImageCount;
@property (assign, nonatomic) BOOL isNoDataViewShow;  //只要有一个接口返回没有数据，其他接口直接返回
@property (assign, nonatomic) BOOL callBookVenues;
@property (assign, nonatomic) BOOL nearbyCallBookVenuesQueryDataSuccess;
@property (copy, nonatomic) NSString *nearbyBusinessId;
@property (weak, nonatomic) IBOutlet UIView *addressHolderView;

@end

@implementation BusinessDetailController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithBusinessId:(NSString *)businessId
              categoryId:(NSString *)categoryId
{
    self = [super init];
    if (self) {
        self.businessId = businessId;
        self.selectedCategoryId = categoryId;
    }
    return self;
}

- (id)initWithBusiness:(Business *)business
            categoryId:(NSString *)categoryId
{
    self = [super init];
    if (self) {
        self.business = business;
        self.businessId = business.businessId;
        self.selectedCategoryId = categoryId;
    }
    return self;
}

#define  HEIGHT_HOLDERVIEW_TITLE 35         //各个holderview的标题高度
#define  SPACE_BETWEEN_HOLDERVIEW 8         //各个holderview中间的间距
#define  HEIGHT_SHADOW_HOLDERVIEW_BOTTOM 3  //hoderview底下阴影的高度
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"场馆详情";
    [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    
    [self initAboutCallBook];
    [self initStaticUI];
    [self updateBaseHolderView];
    //调用网络接口
    self.isNoDataViewShow = NO;
    [self queryBusinessDetailData];
    [self queryBookingInfoData];
    [self queryCommentData];
  }

- (void)queryHotTopic
{
    [ForumService hotTopic:self
                  venuesId:_businessId
                    userId:[[UserManager defaultManager] readCurrentUser].userId];
}

-(void)didHotTopic:(ForumEntrance *)forumEntrance status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS] && forumEntrance) {
        ForumEntranceView *view = [ForumEntranceView createViewWithForumEntrance:forumEntrance
                                                                      controller:self];
        [self.forumEntranceHolderView addSubview:view];
        [self.forumEntranceHolderView updateHeight:view.frame.size.height];
        
        [self updateAllHolderSite];
    }
}

- (BOOL)hasForumEntrance
{
    for (UIView *subView in self.forumEntranceHolderView.subviews) {
        if([subView isKindOfClass:[ForumEntranceView class]]) {
            return YES;
        }
    }
    return NO;
}

- (IBAction)clickImageButton:(id)sender {
    [MobClickUtils event:umeng_event_business_detail_click_gallery];
    
    BusinessPhotoBrowser *browser = [[BusinessPhotoBrowser alloc] initWithOpenIndex:0
                                                                         businessId:_business.businessId
                                                                         categoryId:_selectedCategoryId
                                                                         totalCount:_business.imageCount
                                                                           business:_business];

    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:browser];
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:modelNavigationController animated:YES completion:nil];
}

- (IBAction)clickPhoneButton:(id)sender {
    [MobClickUtils event:umeng_event_business_detail_click_phone];
    BOOL result = [UIUtils makePromptCall:_business.telephone];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

- (IBAction)clickAddressButton:(id)sender {
    [MobClickUtils event:umeng_event_business_detail_click_map];

    BusinessMapController *controller = [[[BusinessMapController alloc] init] initWithLatitude:_business.latitude
                                                                                      longitude:_business.longitude
                                                                                   businessName:_business.name
                                                                                businessAddress:_business.address
                                                                                parkingLotList:_business.parkingLotList
                                                                                    businessId:_businessId
                                                                                    categoryId:_business.defaultCategoryId
                                                                                          type:0];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickCallBookTimeButton:(id)sender {
    [_dateFormat setDateFormat:@"MM月dd日"];
    [SportStartAndEndTimePickerView popupPickerWithDelegate:self dataArray:[self createPickerDataSourse]];
}

#pragma mark - SportStartAndEndTimePickerView Delegate
- (void)didClickSportStartAndEndTimePickerViewOKButton:(SportStartAndEndTimePickerView *)sportPickerView {
    //Date
    NSInteger dateRow = [sportPickerView.dataPickerView selectedRowInComponent:0];
    NSDate *tommrow = [[NSDate date] dateByAddingTimeInterval:24 * 60 * 60];
    self.callBookDate = [tommrow dateByAddingTimeInterval: 24 * 60 * 60 * dateRow];
    //time
    NSInteger startHourRow = [sportPickerView.dataPickerView selectedRowInComponent:1];
    self.callBookStartHour = 9 + (int)(startHourRow / 2);
    if (startHourRow % 2 == 0) {
        self.callBookStartMinute = 0;
    } else {
        self.callBookStartMinute = 30;
    }
    //duration
    NSInteger durationRow = [sportPickerView.dataPickerView selectedRowInComponent:2];
    if (self.callBookStartHour + durationRow + 1 > 23) {
        self.callBookDuration = 24 - self.callBookStartHour;
    } else {
        self.callBookDuration = (int)(durationRow + 1);
    }
    
    [self updateAboutCallBook];
}

//设置静态的图片
#define TAG_LINE_IMAGE_VIEW             100
#define TAG_BACKGROUND_IMAGE_VIEW       101
#define TAG_BACKGROUND_ROUND_IMAGE_VIEW 102
#define TAG_NO_INFO_HOLDERVIEW          200
- (void)initStaticUI
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
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightTopView]; 
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
    //设置所有holderview的背景、横线
    for (UIView *firstSubview in self.mainScrollView.subviews) {
        for (UIView *secondSubiew in firstSubview.subviews) {
            
            //横线
            if (secondSubiew.tag == TAG_LINE_IMAGE_VIEW && [secondSubiew isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)secondSubiew setImage:[SportImage lineImage]];
            }
            
            //方角背景图
            if (secondSubiew.tag == TAG_BACKGROUND_IMAGE_VIEW && [secondSubiew isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)secondSubiew setImage:[SportImage whiteBackgroundImage]];
            }
            
            //圆角背景图
            if (secondSubiew.tag == TAG_BACKGROUND_ROUND_IMAGE_VIEW && [secondSubiew isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)secondSubiew setImage:[SportImage whiteBackgroundImage]];
            }
        }
    }
    
    //设置查看全部评论按钮
    UIImage *image = [[SportColor createImageWithColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1]] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    [self.allCommentsButton setBackgroundImage:image forState:UIControlStateHighlighted];
}

- (void)queryBusinessDetailData {
    self.isNoDataViewShow = NO;
    //加载过程中不能点击右上角分享
    self.navigationItem.rightBarButtonItem.enabled = NO;
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"加载场馆信息..."];
    [BusinessService queryBusinessDetail:self
                              businessId:_businessId
                              categoryId:_selectedCategoryId
                                  userId:user.userId];
}

- (void)didQueryBusinessDetail:(Business *)business
                        status:(NSString *)status
                           msg:(NSString *)msg {

    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (_isNoDataViewShow) {
        return;
    }
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self removeNoDataView];
        self.business = business;
        [self setTitle:business.name];
        
        //创建分类
        if ([self.categoryHolderView.subviews count] == 0
            && [self.business.categoryList count] > 0) {
            [self initCategoryScrollView];
        }
        
        [SportProgressView dismiss];
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
    //无数据时的提示
    if (business == nil) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
        }
    } else {
        [self removeNoDataView];
    }
    
    [self updateAboutCallBook];
    [self updateBaseHolderView];
    [self updateServiceHolderView];
    //改变各个holderView位置
    [self updateAllHolderSite];
    
    if (_isSavedHistroy == NO) {
        self.isSavedHistroy = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[HistoryManager defaultManager] saveBusiness:_business];
        });
    }
}

- (void)queryBookingInfoData {
    self.isNoDataViewShow = NO;
    [self.bookInfoActivityIndicatorView startAnimating];
    self.loadingTipsLabel.text = @"场地数据加载中，请稍后~";
    
    self.loadingHolderView.hidden = NO;
    self.bookInfoHolderView.hidden = YES;
    self.callBookHolderView.hidden = YES;
    self.singleHolderView.hidden = YES;
    [BusinessService queryBookingStatisticsList:self
                                     businessId:_businessId
                                     categoryId:_selectedCategoryId];
}

- (void)didQueryBookingStatisticsList:(NSArray *)list
                               status:(NSString *)status
                                  msg:(NSString *)msg
                            orderType:(int)orderType
                            goodsList:(NSArray *)goodsList {
    [self.bookInfoActivityIndicatorView stopAnimating];
    self.bookingStatisticsList = list;
    
    if (orderType == BookingTypeSingle) {
        self.productInfo = [[ProductInfo alloc] init];
        self.productInfo.type = orderType;
        self.productInfo.goodsList = goodsList;
    }
    
    if (_isNoDataViewShow) {
        return;
    }
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //更新预订信息
        if (orderType == BookingTypeTime
            && [list count] > 0) {
            self.callBookHolderView.hidden = YES;
            self.bookInfoHolderView.hidden = NO;
            self.singleHolderView.hidden = YES;
            
            self.callBookVenues = NO;
            
            [self updatebookInfoScrollView];
        } else if (orderType == BookingTypeSingle) {
            self.callBookHolderView.hidden = YES;
            self.bookInfoHolderView.hidden = YES;
            self.singleHolderView.hidden = NO;
            
            self.callBookVenues = NO;
            
            [self updateSingleHolderView];
        } else {
            self.callBookHolderView.hidden = NO;
            self.bookInfoHolderView.hidden = YES;
            self.singleHolderView.hidden = YES;
            
            [self queryNearbyVenues];
            self.callBookVenues = YES;
        }
        self.loadingHolderView.hidden = YES;
        [self removeNoDataView];
        
    } else {
        self.loadingHolderView.hidden = NO;
        self.reloadBookingButton.hidden = NO;
        self.loadingTipsLabel.text = @"网络错误";
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
        self.isNoDataViewShow = YES;
        
        self.bookInfoHolderView.hidden = YES;
        self.callBookHolderView.hidden = YES;
        self.singleHolderView.hidden = YES;
        
        self.callBookVenues = NO;
    }
    
    //改变各个holderView位置
    [self updateAllHolderSite];
    
    if (_isHasRunEvent == NO) {
        _isHasRunEvent = YES;
        if ([list count] > 0 || [goodsList count] > 0) {
            HDLog(@"1");
            [MobClickUtils event:umeng_event_show_business_detail label:@"在线预订"];
        } else {
            HDLog(@"2");
            [MobClickUtils event:umeng_event_show_business_detail label:@"电话预订"];
        }
    }
}

- (void)queryCommentData
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [BusinessService queryComments:self businessId:_businessId userId:user.userId navId:@"0" count:3 page:1];
}

- (void)didQueryComments:(NSArray *)commentList
            categoryList:(NSArray *)categoryList
              totalCount:(int)totalCount
               totalRank:(double)totalRank
                  status:(NSString *)status
                     msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.totalReviewCount = totalCount;
        self.reviewList = commentList;
    }
    
    [self updateCommentHolderView];
    
    //改变各个holderView位置
    [self updateAllHolderSite];
}

- (void)updateSingleHolderView {
    //移除旧的view
    for (UIView *subView in self.singleHolderView.subviews) {
        if ([subView isKindOfClass:[SingleGoodsView class]]) {
            [subView removeFromSuperview];
        }
    }
    //添加新的view
    CGFloat y = 0;
    CGFloat height = [SingleGoodsView height] + 10;
    int index = 0;
    for (Goods *goods in _productInfo.goodsList) {
        SingleGoodsView *view = [SingleGoodsView createSingleGoodsView];
        view.delegate = self;
        y = index * height;
        [view updateOriginY:y];
        [view updateWidth:_singleHolderView.frame.size.width];
        [view updateViewWithGoods:goods row:index];
        [self.singleHolderView addSubview:view];
        
        index ++;
    }
    
    [self.singleHolderView updateHeight:index * height - 10];
    [[_singleHolderView viewWithTag:TAG_BACKGROUND_ROUND_IMAGE_VIEW] updateHeight:_singleHolderView.frame.size.height];
}

- (IBAction)clickReloadBookingButton:(id)sender {
    self.reloadBookingButton.hidden = YES;
    [self queryBookingInfoData];
    [self queryBusinessDetailData];
}

- (void)didClickNoDataViewRefreshButton{
    self.reloadBookingButton.hidden = YES;
    [self queryBookingInfoData];
    [self queryBusinessDetailData];
}

- (void)didClickSingleGoodsViewBuyBackgroundButton:(Goods *)goods {
    [MobClickUtils event:umeng_event_click_venue_details_people_commodity];
    PackageDetailController *controller = [[PackageDetailController alloc] initWithPackage:(Package *)goods isSpecialSale:NO];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickSingleGoodsViewBuyButton:(Goods *)goods {
    [MobClickUtils event:umeng_event_click_venue_details_promptly_buy_button];
    if (![UserManager isLogin]) {
        FastLoginController *controller = [[FastLoginController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    SingleBookingController *controller = [[SingleBookingController alloc] initWithGoods:goods businessName:goods.businessName isSpecialSale:NO];
    [self.navigationController pushViewController:controller animated:YES];
}

#define WIDTH_ANNOUNCEMENT_TEXT_VIEW ([UIScreen mainScreen].bounds.size.width - 20)
#define TAG_RATING_BASE 10
#define MIN_HEIGHT_BASE_BACKGROUND 115
#define TAG_ADDRESSVIEW 2016080801
- (void)updateBaseHolderView
{
    [self.imageCountView setFrame:CGRectMake(self.imageButton.frame.origin.x + self.imageButton.frame.size.width - 15, self.imageButton.frame.origin.y + self.imageButton.frame.size.height - 15, 15, 15)];
    self.imageCountView.backgroundColor = [SportColor hex000000Color];
    self.imageCountView.alpha = 0.6;
    self.imageCountView.layer.masksToBounds = YES;
    self.imageCountView.layer.cornerRadius = 3;
    
    [self.imageCountLabel setFrame:CGRectMake(0, 3, 15, 10)];
    self.imageCountLabel.textAlignment = NSTextAlignmentCenter;
    self.imageCountLabel.font = [UIFont systemFontOfSize:10];
    self.imageCountLabel.textColor = [UIColor whiteColor];
    self.imageCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_business.imageCount];
    
    self.imageButton.layer.cornerRadius = 6;
    self.imageButton.layer.masksToBounds = YES;
    
    [self.imageButton sd_setBackgroundImageWithURL:[NSURL URLWithString:_business.imageUrl]
                                          forState:UIControlStateNormal
                                  placeholderImage:[SportImage defaultImage_143x115]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             self.businessImage = image;
    }];
    
    self.businessNameLabel.text = _business.name;
    
    self.rightTopView.leftButton.selected = _business.isCollect;
    
    if (_business.rating > 0) {
        self.ratingHolderView.hidden = NO;
        int zsPart = (int)_business.rating;
        for (int i = 0 ; i < 5 ; i ++) {
            UIImageView *imageView = (UIImageView *)[self.ratingHolderView viewWithTag:TAG_RATING_BASE + i];
            if (i < zsPart) {
                [imageView setImage:[SportImage star1Image]];
            } else if (_business.rating - i > 0) {
                [imageView setImage:[SportImage star2Image]];
            } else {
                [imageView setImage:[SportImage star3Image]];
            }
        }
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", _business.rating];
    } else {
        self.ratingHolderView.hidden = YES;
    }
    
    //BaseHolderView增加退款标识和文字说明
    if (self.business.canRefund) {
        self.baseRefundView.hidden = NO;
        if (self.business.refundTips.length > 0) {
            self.refundTipsLabel.text = self.business.refundTips;
        }else{
            self.refundTipsLabel.text = @"提前24小时可退款";
        }
    }else{
        self.baseRefundView.hidden = YES;
    }
    
    //公告
    for (id subView in self.baseHolderView.subviews) {
        if ([subView isKindOfClass:[UITextView class]]) {
            [subView removeFromSuperview];
        }
    }
    if ([_business.announcement length] > 0) {
        UITextView *view = [self createAnnouncementTextView];
        view.text = self.business.announcement;
        CGSize size = [view sizeThatFits:CGSizeMake(WIDTH_ANNOUNCEMENT_TEXT_VIEW, 600)];
        [view updateHeight:size.height];
        [view updateOriginY:MIN_HEIGHT_BASE_BACKGROUND + 5];
        [self.baseHolderView addSubview:view];
        [_baseHolderView updateHeight:view.frame.origin.y + view.frame.size.height + 5];
        [[_baseHolderView viewWithTag:TAG_BACKGROUND_IMAGE_VIEW] updateHeight:_baseHolderView.frame.size.height];
        [[_baseHolderView viewWithTag:TAG_LINE_IMAGE_VIEW] setHidden:NO];
    } else {
        [self.baseHolderView updateHeight:MIN_HEIGHT_BASE_BACKGROUND];
        [[_baseHolderView viewWithTag:TAG_LINE_IMAGE_VIEW] setHidden:YES];
    }
    
    //地址电话
    if ([self hasContact]) {
        UIView *businessAddressView = [_baseHolderView viewWithTag:TAG_ADDRESSVIEW];
        if (businessAddressView) {
            [businessAddressView removeFromSuperview];
        }
        businessAddressView = [self createBusinessAddressView];
        [businessAddressView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [_baseHolderView addSubview:businessAddressView];
        [businessAddressView updateOriginY:_baseHolderView.frame.size.height];
        [businessAddressView updateWidth:[[UIScreen mainScreen] bounds].size.width];
        [businessAddressView updateHeight:55.f];
        [_baseHolderView updateHeight:CGRectGetMaxY(businessAddressView.frame)];
    }
    
}

- (UITextView *)createAnnouncementTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - WIDTH_ANNOUNCEMENT_TEXT_VIEW) / 2, 0, WIDTH_ANNOUNCEMENT_TEXT_VIEW, 200)] ;
    textView.backgroundColor = [UIColor clearColor];
    [textView setTextColor:[UIColor hexColor:@"222222"]];
    textView.font = [UIFont systemFontOfSize:14];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    if ([textView respondsToSelector:@selector(setSelectable:)]) {
        textView.selectable = NO;
    }
    return textView;
}

- (UIView *)createBusinessAddressView {
    //todo 长按赋值地址
    UIView *busiAddressView = [[UIView alloc] init];
    UITapGestureRecognizer *addressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAddressButton:)];
    [busiAddressView addGestureRecognizer:addressGesture];
    [busiAddressView setBackgroundColor:[UIColor whiteColor]];
    [busiAddressView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [busiAddressView setTag:TAG_ADDRESSVIEW];
    
    UILabel *busiAddressLabel = [[UILabel alloc] init];
    [busiAddressLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [busiAddressLabel setText:_business.address];
    [busiAddressLabel setFont:[UIFont systemFontOfSize:15.f]];
    [busiAddressLabel setTextColor:[UIColor hexColor:@"222222"]];
    [busiAddressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [busiAddressView addSubview:busiAddressLabel];
    UIImageView *busiAddressImageView = [[UIImageView alloc] init];
    [busiAddressImageView setContentCompressionResistancePriority:800 forAxis:UILayoutConstraintAxisHorizontal];
    [busiAddressImageView setImage:[UIImage imageNamed:@"mapIcon"]];
    [busiAddressImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [busiAddressView addSubview:busiAddressImageView];
    UIView *vLineView = [[UIView alloc] init];
    [vLineView setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
    [vLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [busiAddressView addSubview:vLineView];
    UIButton *busiCallPhoneButton = [[UIButton alloc] init];
    [busiCallPhoneButton addTarget:self action:@selector(clickPhoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [busiCallPhoneButton setTouchExtendInset:UIEdgeInsetsMake(-15, -15, -15, -15)];
    [busiCallPhoneButton setContentCompressionResistancePriority:800 forAxis:UILayoutConstraintAxisHorizontal];
    [busiCallPhoneButton setImage:[UIImage imageNamed:@"MyCellPhoneIcon"] forState:UIControlStateNormal];
    [busiCallPhoneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [busiAddressView addSubview:busiCallPhoneButton];
    
    //Constraint
    NSDictionary *layoutView = NSDictionaryOfVariableBindings(busiAddressView, busiAddressLabel, busiAddressImageView, vLineView, busiCallPhoneButton);
    [busiAddressView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[busiAddressImageView]-15-[busiAddressLabel]->=15-[vLineView(0.5)]-15-[busiCallPhoneButton]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:layoutView]];
    [busiAddressView addConstraint:[NSLayoutConstraint constraintWithItem:vLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.f constant:20.f]];
    [busiAddressView addConstraint:[NSLayoutConstraint constraintWithItem:busiAddressLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:busiAddressView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    return busiAddressView;
}

- (void)initCategoryScrollView
{
    for (UIView *subView in self.categoryHolderView.subviews) {
        [subView removeFromSuperview];
    }
    
    CategoryButtonListView *view = [CategoryButtonListView createViewWithCategoryList:_business.categoryList
                                                                   selectedCategoryId:_selectedCategoryId
                                                                             delegate:self];
    [self.categoryHolderView addSubview:view];
}

- (void)didClickCategoryButtonListView:(NSString *)categoryId
{
    self.selectedCategoryId = categoryId;
    [self queryBusinessDetailData];
    [self queryBookingInfoData];
}

#pragma mark - BookingSimpleViewDelegate
- (void)didClickBookingSimpleView:(int)index
{
    BookingStatistics *statistics = [_bookingStatisticsList objectAtIndex:index];
    BookingDetailController *controller = [[BookingDetailController alloc] initWithBusinessId:_businessId
                                                                                    categoryId:_selectedCategoryId
                                                                                          date:statistics.date] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updatebookInfoScrollView
{
    for (UIView *subView in self.bookInfoScrollView.subviews) {
        if ([subView isKindOfClass:[BookingSimpleView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    int index = 0;
    CGFloat startX = 10;
    CGFloat space = 8;
    
    for (BookingStatistics *statistics in _bookingStatisticsList) {
        BookingSimpleView *view = [BookingSimpleView createBookingSimpleView];
        view.delegate = self;
        [view updatView:statistics index:index];
        [view updateOriginX:startX + index * (space + view.frame.size.width)];
        [view updateOriginY:0];
        [self.bookInfoScrollView addSubview:view];
        index ++;
    }
    [self.bookInfoScrollView setContentSize:CGSizeMake(startX + index * [BookingSimpleView defaultSize].width + (index - 1) * space + startX, _bookInfoScrollView.frame.size.height)];
    self.bookInfoScrollView.showsHorizontalScrollIndicator = NO;
}

- (void)updateCallBookTimeButton
{
    int endHour = _callBookStartHour + _callBookDuration;
    
    NSString *minuteStr = (_callBookStartMinute == 0 ? @"00" : @"30");
    NSString *buttonTitle = [NSString stringWithFormat:@"%@  %d:%@-%d:%@", [_dateFormat stringFromDate:_callBookDate], _callBookStartHour, minuteStr, endHour, minuteStr];
    [self.callBookTimeButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)updateCallBookPriceLabel
{
    NSString *priceStr = nil;
    if (_business.price == 0) {
        priceStr = @"暂未确定";
    } else {
        
        priceStr = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_business.price  * _callBookDuration]];
    }
    self.callBookPriceLabel.text = priceStr;
}

- (void)initAboutCallBook
{
    self.callBookHolderView.hidden = YES;
    
    self.callBookDate = [[NSDate date] dateByAddingTimeInterval:24 * 60 * 60];
    self.callBookStartHour = 18;
    self.callBookStartMinute = 0;
    self.callBookDuration = 2;
    
    self.dateFormat = [[NSDateFormatter alloc] init] ;
    [_dateFormat setDateFormat:@"MM月dd日"];
}

- (void)updateAboutCallBook
{
    [self updateCallBookTimeButton];
    [self updateCallBookPriceLabel];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 10;
    } else if (component == 1) {
        return 29;
    } else if (component ==2) {
        return 12;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return @"日期";
    } else if (component == 1) {
        return @"开始时间";
    } else if (component ==2) {
        return @"持续时长";
    }
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)] ;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    if (component == 0) {
        NSDate *tommrow = [[NSDate date] dateByAddingTimeInterval:24 * 60 * 60];
        NSDate *showDay = [tommrow dateByAddingTimeInterval: 24 * 60 * 60 *row];
        label.text = [_dateFormat stringFromDate:showDay];
    } else if (component == 1) {
        int hour = 9 + (int)row / 2;
        NSString *time =  nil;
        if (row % 2 == 0) {
            time = [NSString stringWithFormat:@"%d:00", hour];
        } else {
            time = [NSString stringWithFormat:@"%d:30", hour];
        }
        label.text = time;
    } else if (component ==2) {
        label.text = [NSString stringWithFormat:@"%d小时", (int)row + 1];
    }
    return label;
}

- (NSArray *)createPickerDataSourse {
    //日期
    NSMutableArray *dateList = [NSMutableArray array];
    NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:24 * 60 * 60];
    NSDate *showDay;
    for (int i = 0; i < 10; i ++) {
        showDay = [tomorrow dateByAddingTimeInterval:24 * 60 * 60 * i];
        [dateList addObject:[_dateFormat stringFromDate:showDay]];
    }
    //时间
    NSMutableArray *timeList = [NSMutableArray array];
    int hour;
    NSString *time;
    for (int i = 0; i < 29; i ++) {
        hour = 9 + (int)(i / 2);
        if(i % 2 == 0) {
            time = [NSString stringWithFormat:@"%d:00", hour];
        }else {
            time = [NSString stringWithFormat:@"%d:30", hour];
        }
        [timeList addObject:time];
    }
    //duration
    NSMutableArray *durationList = [NSMutableArray array];
    for (int i = 0; i < 4; i ++) {
        [durationList addObject:[NSString stringWithFormat:@"%d小时", (i + 1)]];
    }
    
    return [NSArray arrayWithObjects:dateList, timeList, durationList, nil];
}

- (IBAction)clickCallBookButton:(id)sender {
    [_dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateZeroHourString = [_dateFormat stringFromDate:_callBookDate];
    NSDate *dateZeroHour = [_dateFormat dateFromString:dateZeroHourString]; //一天的零时零分
    NSDate *startTime = [[dateZeroHour dateByAddingTimeInterval:_callBookStartHour * 60 * 60] dateByAddingTimeInterval:_callBookStartMinute * 60];
    BookWithPhoneController *controller = [[BookWithPhoneController alloc] initWithBusiness:_business categoryId:_selectedCategoryId startTime:startTime duration:_callBookDuration];
   
    [self.navigationController pushViewController:controller animated:YES];
}

//设置
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

- (void)didChangeServiceViewHeight:(CGFloat)height
{
    [self.serviceHolderView updateHeight:height];
    
    [self updateAllHolderSite];
}

- (void)didClickServiceViewCell:(NSIndexPath *)indexPath {
    ServiceGroup *serviceGroup = [self.business.serviceGroupList objectAtIndex:indexPath.section];
    Service *service = [serviceGroup.serviceList objectAtIndex:indexPath.row];
    if(service.isPark){
        BusinessMapController *businessMapController = [[BusinessMapController alloc] initWithLatitude:_business.latitude
                                                                                             longitude:_business.longitude
                                                                                          businessName:_business.name
                                                                                       businessAddress:_business.address
                                                                                        parkingLotList:_business.parkingLotList
                                                                                            businessId:_businessId
                                                                                            categoryId:_business.defaultCategoryId
                                                                                                  type:1];
        
        [self.navigationController pushViewController:businessMapController animated:YES];
    }
}

- (BOOL)hasService
{
    return ([self.business.serviceGroupList count] > 0);
}

-(BOOL)hasNearbyVenues {
    return ( _callBookVenues && _nearbyCallBookVenuesQueryDataSuccess );
}

//设置评论
- (BOOL)hasComment
{
    if ([_reviewList count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)updateCommentHolderView
{
    for (id subView in self.commentHolderView.subviews) {
        if ([subView isKindOfClass:[ReviewCell class]]) {
            [subView removeFromSuperview];
        }
    }
    
    CGFloat y = HEIGHT_HOLDERVIEW_TITLE;
    CGFloat oneHeight = 0;
    int index = 0;
    for (Review *review in _reviewList) {
        ReviewCell *cell = [ReviewCell createCell];
        cell.delegate = self;
        [cell updateCellWithReview:review
                             index:index];
        oneHeight = [cell heightWithReview:review];
        [cell updateOriginX:0];
        [cell updateOriginY:y];
        y += oneHeight;

        [self.commentHolderView addSubview:cell];
        
        index ++;

        if (index == 3) {
            break;
        }
    }
    
    UIView *noInfoHolderView = [_commentHolderView viewWithTag:TAG_NO_INFO_HOLDERVIEW];
    if ([self hasComment]) {
        noInfoHolderView.hidden = YES;
        _commentBottomHolderView.hidden = NO;
        _allCommentsTitleLabel.text = [NSString stringWithFormat:@"查看全部评论(%d)", _totalReviewCount];
        [_commentBottomHolderView updateOriginY: y];
        [_commentHolderView updateHeight:_commentBottomHolderView.frame.origin.y + _commentBottomHolderView.frame.size.height + HEIGHT_SHADOW_HOLDERVIEW_BOTTOM];
    } else {
        noInfoHolderView.hidden = NO;
        _commentBottomHolderView.hidden = YES;
        [_commentHolderView updateHeight:2 * HEIGHT_HOLDERVIEW_TITLE + HEIGHT_SHADOW_HOLDERVIEW_BOTTOM];
    }

    [[_commentHolderView viewWithTag:TAG_BACKGROUND_ROUND_IMAGE_VIEW] updateHeight:_commentHolderView.frame.size.height];
    
}

- (void)didClickReviewCellAvatarButton:(NSString *)userId
{
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:userId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickReviewCellImageButton:(NSUInteger)row
                            openIndex:(NSUInteger)openIndex
{
    BrowsePhotoView *view = [BrowsePhotoView createBrowsePhotoView];
 
    Review *review = [self.reviewList objectAtIndex:row];
    
    NSMutableArray *list = [NSMutableArray array];
    
    for (BusinessPhoto *photo in review.photoList) {
        [list addObject:photo.photoImageUrl];
    }
    
    [view showImageList:list openIndex:openIndex];
}

//设置电话、地址、交通
- (BOOL)hasContact
{
    if ([_business.telephone length] > 0
        || [_business.address length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

//更新各个holderview的位置
- (void)updateAllHolderSite
{
    
    CGFloat y = _baseHolderView.frame.origin.y + _baseHolderView.frame.size.height;
    
    [self.categoryHolderView updateOriginY:y - 1];
    y = y + _categoryHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    
    [self.loadingHolderView updateOriginY:y];
    [self.bookInfoHolderView updateOriginY:y];
    [self.callBookHolderView updateOriginY:y];
    [self.singleHolderView updateOriginY:y];
    
    if (_bookInfoHolderView.hidden == NO) {
        y = y + _bookInfoHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else if (_callBookHolderView.hidden == NO) {
        y = y + _callBookHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else if (_singleHolderView.hidden == NO) {
        if (_singleHolderView.frame.size.height > 0) {
            y = y + _singleHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
        }
    } else {
        y = y + _loadingHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    }
    
    if ([self hasForumEntrance]) {
        _forumEntranceHolderView.hidden = NO;
        [_forumEntranceHolderView updateOriginY:y];
        y = y + _forumEntranceHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else {
        _forumEntranceHolderView.hidden = YES;
    }
    
    if ([self hasService]) {
        _serviceHolderView.hidden = NO;
        [_serviceHolderView updateOriginY:y];
        y = y + _serviceHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else {
        _serviceHolderView.hidden = YES;
    }
    
    if ([self hasNearbyVenues]){
        _nearbyVenuesHolderView.hidden = NO;
        
        [_nearbyVenuesHolderView updateOriginY:y];
        y = y + _nearbyVenuesHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else {
        _nearbyVenuesHolderView.hidden = YES;
    }
    
    if ([self hasComment]) {
        _commentHolderView.hidden = NO;
        [_commentHolderView updateOriginY:y];
        y = y + _commentHolderView.frame.size.height + SPACE_BETWEEN_HOLDERVIEW;
    } else {
        _commentHolderView.hidden = YES;
    }
    
    //场馆报错
    [self configureReportButtonWithLayoutRulerY:&y];
    
    [self.mainScrollView setContentSize:CGSizeMake(_mainScrollView.frame.size.width, y)];
}

#define TAG_REPORT_BUTTON 2016081101
- (void)configureReportButtonWithLayoutRulerY:(CGFloat *)y {
    *y += (MARGIN_REPORT_BUTTON - SPACE_BETWEEN_HOLDERVIEW);
    UIButton *reportErrorButton = [_mainScrollView viewWithTag:TAG_REPORT_BUTTON];
    if (!reportErrorButton) {
        reportErrorButton = [[UIButton alloc] init];
        [reportErrorButton setTag:TAG_REPORT_BUTTON];
        [reportErrorButton addTarget:self action:@selector(handleReportError) forControlEvents:UIControlEventTouchUpInside];
        [self.mainScrollView addSubview:reportErrorButton];
    }
    [reportErrorButton updateOriginY:*y];
    [reportErrorButton updateHeight:20.f];
    [reportErrorButton updateWidth:120.f];
    [reportErrorButton updateOriginX:[[UIScreen mainScreen] bounds].size.width - 15 - CGRectGetWidth(reportErrorButton.frame)];
    NSAttributedString *reportErrorAttrString = [[NSAttributedString alloc] initWithString:REPORT_ERROR_STRING attributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle], NSForegroundColorAttributeName:[UIColor hexColor:@"aaaaaa"], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    //todo 有空研究用行距控制下划线距离
    [reportErrorButton setAttributedTitle:reportErrorAttrString forState:UIControlStateNormal];
    
    [reportErrorButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    *y += (MARGIN_REPORT_BUTTON + reportErrorButton.frame.size.height);
}

#define TAG_REPORT_ERROR_ALERT 2016081501
- (void)handleReportError {
    if ([UserManager isLogin]) {
        [ReportErrorView showViewWithVenuesId:_businessId categoryId:_selectedCategoryId];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"登录后才能得到相应的积分奖励，快去登录吧!" delegate:self cancelButtonTitle:@"继续报错" otherButtonTitles:@"登录", nil];
        alertView.tag = TAG_REPORT_ERROR_ALERT;
        [alertView show];
    }
}

- (void)queryNearbyVenues{
    
    [_dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateZeroHourString = [_dateFormat stringFromDate:_callBookDate];
    NSDate *dateZeroHour = [_dateFormat dateFromString:dateZeroHourString]; //一天的零时零分
    NSDate *startTime = [[dateZeroHour dateByAddingTimeInterval:_callBookStartHour * 60 * 60] dateByAddingTimeInterval:_callBookStartMinute * 60];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    NSString *startTimeStamp = [NSString stringWithFormat:@"%0.f", [startTime timeIntervalSince1970]];
    NSString *endTimeStamp = [NSString stringWithFormat:@"%0.f", [[startTime dateByAddingTimeInterval:_callBookDuration * 3600] timeIntervalSince1970]];
    
    //[SportProgressView showWithStatus:@"加载中"];
    //查看附近推荐场馆
    [BusinessService getNearbyVenues:self categoryId:_selectedCategoryId cityId:user.cityId venuesId:self.businessId startTime:startTimeStamp endTime:endTimeStamp userId:user.userId];
    
}

- (void)didGetNearbyVenusWithStatus:(NSString *)status msg:(NSString *)msg business:(Business *)business {
    
    if ([status isEqualToString:STATUS_SUCCESS] && business) {
        
        [NearbyVenuesView createNearbyVenuesViewWithBusiness:_business   //当前场馆
                                                  categoryId:_selectedCategoryId
                                                    delegate:self
                                                nearbyVenues:business  //附近场馆
                                             superHolderView:self.nearbyVenuesHolderView];
        
         self.nearbyBusinessId = business.businessId;
        
        _nearbyCallBookVenuesQueryDataSuccess = YES;
        
    } else {
        _nearbyCallBookVenuesQueryDataSuccess = NO;
    }
    
    [self updateAllHolderSite];
}

- (void)didClickNearbyVenuesViewButton{
    [MobClickUtils event:umeng_event_click_nearby_bussiness];
    
    BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:_nearbyBusinessId categoryId:_selectedCategoryId];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (IBAction)clickAllCommentsButton:(id)sender {
    [MobClickUtils event:umeng_event_business_detail_click_all_review];
    
    ReviewListController *controller = [[ReviewListController alloc] initWithBusinessId:_business.businessId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickAddCommentButton:(id)sender {
    if ([UserManager isLogin]) {
        
        WriteReviewController *controller = [[WriteReviewController alloc] init] ;
        
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - 收藏和分享
- (IBAction)clickCollectButton:(id)sender {
    [MobClickUtils event:umeng_event_business_detail_click_collect];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        
        if (_business.isCollect) {
            [SportProgressView showWithStatus:@"正在取消收藏..."];
            [BusinessService removeFavoriteBusiness:self
                                         businessId:_businessId
                                         categoryId:_business.defaultCategoryId
                                             userId:user.userId];
            
        } else {
            [SportProgressView showWithStatus:DDTF(@"kAddingFavorite")];
            [BusinessService addFavoriteBusiness:self
                                      businessId:_businessId
                                      categoryId:_business.defaultCategoryId
                                          userId:user.userId];
        }
        
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didAddFavoriteBusiness:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:DDTF(@"kAddFavoriteSuccess")];
        self.business.isCollect = YES;
        self.rightTopView.leftButton.selected = _business.isCollect;
        [self.rightTopView.leftButton setImage:[UIImage imageNamed:@"CollectSelectedIcon"] forState:UIControlStateHighlighted];
    } else {
        [SportProgressView dismissWithError:DDTF(@"kAddFavoriteFail")];
    }
}

- (void)didRemoveFavoriteBusiness:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"取消成功"];
        self.business.isCollect = NO;
        self.rightTopView.leftButton.selected = _business.isCollect;
        [self.rightTopView.leftButton setImage:[UIImage imageNamed:@"CollectSelectedIcon"] forState:UIControlStateHighlighted];
    } else {
        [SportProgressView dismissWithError:@"取消失败"];
    }
}

#define TAG_FIRST_SHARE     100
#define TAG_WEIXIN_SHARE    101
- (IBAction)clickShareButton:(id)sender {
    
    [MobClickUtils event:umeng_event_business_detail_click_share];
//    float price = _business.promotePrice > 0 ? _business.promotePrice:_business.price;
//    ShareContent *shareContent = [[ShareContent alloc] init] ;
//    shareContent.thumbImage = [UIImage imageNamed:@"defaultIcon"];
//    shareContent.title = @"我发现这个场馆不错，性价比非常高！我们去这里打球吧！";
//    shareContent.subTitle = [NSString stringWithFormat:@"%@,%@,￥%.0f元起", _business.name, _business.address,price];
//    
//    shareContent.image = nil;
//    shareContent.content = [NSString stringWithFormat:@"我发现这个场馆不错，性价比非常高！我们去这里打球吧！%@，地址:%@，￥%.0f元起", _business.name, _business.address,price];
//    shareContent.linkUrl = [NSString stringWithFormat:@"http://m.quyundong.com/court/detail?id=%@&cid=%@", _business.businessId, _selectedCategoryId];
//    
    [ShareView popUpViewWithContent:self.business.shareContent channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatTimeline), @(ShareChannelWeChatSession), @(ShareChannelSina), @(ShareChannelSMS), nil] viewController:self delegate:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_REPORT_ERROR_ALERT) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            FastLoginController *controller = [[FastLoginController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [ReportErrorView showViewWithVenuesId:_businessId categoryId:_selectedCategoryId];
        }
    }
}

@end
