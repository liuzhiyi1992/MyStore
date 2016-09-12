//
//  CourseDetailController.m
//  Sport
//
//  Created by haodong  on 15/6/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CourseDetailController.h"
#import "CollectAndShareButtonView.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "ShareView.h"
#import "User.h"
#import "UserManager.h"
#import "MonthCard.h"
#import "LoginController.h"
#import "DateUtil.h"
#import "MonthCardFinishPayController.h"
#import "FastLoginController.h"
#import "SingleBookingController.h"

@interface CourseDetailController ()<UIWebViewDelegate,LoginDelegate>
@property(strong,nonatomic)CollectAndShareButtonView *rightTopView;

@property (weak, nonatomic) IBOutlet UIView *buttonSuperView;
@property (weak, nonatomic) IBOutlet UIButton *appointmentButton;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTtleLabel;
@property (strong, nonatomic) User *user;
@property (copy, nonatomic)NSString *endTime;
@property (weak, nonatomic) IBOutlet UIView *appointmentAlertView;

@property (weak, nonatomic) IBOutlet UIView *successView;

@property (weak, nonatomic) IBOutlet UIView *backEnableView;
@property (weak, nonatomic) IBOutlet UILabel *sucessLabel;

@end

@implementation CourseDetailController

-(id)initWithCourse:(MonthCardCourse *)course {
    self = [super init];
    if (self) {
        self.course = course;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initStaticUI];
    [self loadWebView];
    self.title = @"课程介绍";
    self.myWebView.delegate = self;
    self.appointmentAlertView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    self.successView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    self.appointmentAlertView.layer.cornerRadius = 5;
    self.successView.layer.cornerRadius = 5;
    self.appointmentButton.layer.cornerRadius = 5;
    
    //[self.appointmentButton setBackgroundColor:[UIColor grayColor]];
    //[self.appointmentButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    self.appointmentButton.enabled = YES;
    [self.appointmentButton setTitle:@"预约课程" forState:UIControlStateNormal];
    self.mainTitleLabel.text = @"";
    self.subTtleLabel.text = @"";

    //[[MonthCardService defaultService] getMonthCardInfo:(id)self userId:self.user.userId];
    // Do any additional setup after loading the view from its nib.
}

//-(void)refreshBottomButton
//{
//    self.user = [[UserManager defaultManager] readCurrentUser];
//    if (self.user.userId == nil) {
//        [self.appointmentButton setBackgroundColor:[UIColor grayColor]];
//        [self.appointmentButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
//        self.appointmentButton.enabled = YES;
//        [self.appointmentButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
//        [self.appointmentButton setTitle:@"加入动Club即可预约" forState:UIControlStateNormal];
//        HDLog(@"Error! no user id");
//        return;
//    }
//    
//    self.appointmentButton.enabled = NO;
//    [[MonthCardService defaultService] checkCourseStatus:(id)self userId:self.user.userId courseId:self.course.courseId];
//}

-(void)viewWillAppear:(BOOL)animated
{
    //[self refreshBottomButton];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initStaticUI
{
    //创建右上角的收藏、分享按钮
    if (_rightTopView == nil) {
        self.rightTopView = [CollectAndShareButtonView createCollectAndShareButtonView];
        self.rightTopView.leftButton.hidden = YES;
        [self.rightTopView.rightButton addTarget:self
                                          action:@selector(clickShareButton:)
                                forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightTopView] ;
        self.navigationItem.rightBarButtonItem = buttonItem;
    }

}

-(void)queryData
{
//    [[MonthCardService defaultService] checkCourseStatus:(id)self userId:self.user.userId courseId:self.course.courseId];
    [self loadWebView];
}

- (void)loadWebView
{
    NSURL *url = [NSURL URLWithString:self.course.courseUrl];
    if (url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.myWebView loadRequest:request];
        [SportProgressView showWithStatus:@"加载中..."];
    }
    else{
        [SportPopupView popupWithMessage:DDTF(@"无法打开网页")];
    }
}


#pragma mark-------------------------回调－－－－－－－－－－－
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeNoDataView];
    [SportProgressView dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SportProgressView dismiss];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
    [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([GoSportUrlAnalysis isGoSportScheme:request.URL]) {
        [GoSportUrlAnalysis pushControllerWithUrl:request.URL NavigationController:self.navigationController];
        return NO;
    } else {
        return YES;
    }
}

//- (void)didBookCourse:(NSString *)status
//                  msg:(NSString *)msg;
//{
//    [SportProgressView dismiss];
//    if ([status isEqualToString:STATUS_SUCCESS]) {
//        
//        [MobClickUtils event:umeng_event_month_course_detail_click_book label:@"预约成功"];
//        
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"预约成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//       // [alertView release];
//        //[self refreshBottomButton];
//    }else{
//        
//        [MobClickUtils event:umeng_event_month_course_detail_click_book label:@"预约失败"];
//        
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"预约失败！" delegate:self cancelButtonTitle:@"请重试" otherButtonTitles:nil, nil];
//        [alertView show];
//      //  [alertView release];
//    }
//}

//- (void)didCheckCourseStatus:(int)courseStatus
//                      status:(NSString *)status
//                         msg:(NSString *)msg
//{
//       if ([status isEqualToString:STATUS_SUCCESS]) {
//        [self removeNoDataView];
//        if (courseStatus==0) {
//            self.appointmentButton.enabled = YES;
//            [self.appointmentButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
//            [self.appointmentButton setTitle:@"加入动Club即可预约" forState:UIControlStateNormal];
//        }
//        else if (courseStatus==1) {
//            self.appointmentButton.enabled = YES;
//            [self.appointmentButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
//            [self.appointmentButton setTitle:@"立即预约" forState:UIControlStateNormal];
//        }
//        else if (courseStatus==2) {
//            self.appointmentButton.enabled = YES;
//            [self.appointmentButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
//            [self.appointmentButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
//            [self.appointmentButton setTitle:@"预约前请先上传头像" forState:UIControlStateNormal];
//        }
//        else if (courseStatus==3 || courseStatus==6) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            self.mainTitleLabel.text = @"不可预约";
//            self.subTtleLabel.text = @"您的动Club会员被冻结";
//        }
//        else if (courseStatus==4) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            self.mainTitleLabel.text = @"不可预约";
//            self.subTtleLabel.text = @"您的动Club会员已过期";
//        }
//        else if (courseStatus==5) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            self.mainTitleLabel.text = @"不可预约";
//            self.subTtleLabel.text = @"今日已消费";
//        }
//        else if (courseStatus==6) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            self.mainTitleLabel.text = @"不可预约";
//            self.subTtleLabel.text = @"您的动Club会员被冻结";
//        }
//        else if (courseStatus==7) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            self.mainTitleLabel.text = @"不可预约";
//            self.subTtleLabel.text = @"本月该馆的消费次数已用完";
//        }
//        else if (courseStatus==4 || courseStatus==8) {
//            self.appointmentButton.enabled = YES;
//            [self.appointmentButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
//            self.mainTitleLabel.text = @"续费即可预约";
//            NSDate* cardEndTime = [[UserManager defaultManager] readCurrentUser].monthCard.endTime;
//            self.endTime = [DateUtil stringFromDate:cardEndTime DateFormat:@"M月d日"];
//            if (courseStatus==4) {
//                self.subTtleLabel.text = [NSString stringWithFormat:@"您的动Club会员已在%@过期",self.endTime];
//            } else {
//                self.subTtleLabel.text = [NSString stringWithFormat:@"您的动Club会员将在%@过期",self.endTime];
//            }
//        }
//        else if (courseStatus==9) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            self.mainTitleLabel.text = @"不可预约";
//            self.subTtleLabel.text = @"今日已预约其他课程";
//        }
//        else if (courseStatus==10) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            [self.appointmentButton setTitle:@"已预约" forState:UIControlStateNormal];
//        }
//        else if (courseStatus==20) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            [self.appointmentButton setTitle:@"该课程不存在" forState:UIControlStateNormal];
//        }
//        else if (courseStatus==21) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            [self.appointmentButton setTitle:@"该课程已结束" forState:UIControlStateNormal];
//        }
//        else if (courseStatus==22) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            self.mainTitleLabel.text = @"不可预约";
//            self.subTtleLabel.text = @"预约人数已满";
//        }
//        else if (courseStatus==23) {
//            [self.appointmentButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateDisabled];
//            [self.appointmentButton setTitle:@"课程已开始" forState:UIControlStateNormal];
//        } else {
//            self.appointmentButton.enabled = NO;
//            [self.appointmentButton setTitle:@"未知状态" forState:UIControlStateNormal];
//        }
//    } else {
//        //无网络时的提示
//        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
//        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
//    }
//}

#pragma mark-----------button处理事件－－－－－－－－－－－－－－－－－－－－－－－－－－
- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (IBAction)clickShareButton:(id)sender {
    
    [MobClickUtils event:umeng_event_month_course_detail_click_share];
    
    ShareContent *shareContent = [[ShareContent alloc] init] ;
    shareContent.thumbImage = [UIImage imageNamed:@"defaultIcon"];
    shareContent.title = @"趣运动-动Club";
    shareContent.subTitle = self.course.courseName;
    shareContent.image = nil;
    shareContent.content = [NSString stringWithFormat:@"我在动Club上发现一个不错的课程，我们一起去上课吧。%@，地址:%@", _course.courseName, _course.venuesName];
    shareContent.linkUrl = self.course.courseUrl;
    
    [ShareView popUpViewWithContent:shareContent channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatTimeline), @(ShareChannelWeChatSession), @(ShareChannelSina), @(ShareChannelSMS), nil] viewController:self delegate:nil];
}

#define TAG_BOOKING 20150617
- (IBAction)clickAppointmentButton:(UIButton *)sender {
    
    if (![UserManager isLogin]) {
        FastLoginController *controller = [[FastLoginController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    SingleBookingController *controller = [[SingleBookingController alloc] initWithCourse:self.course];
    [self.navigationController pushViewController:controller animated:YES];
    
    
//    if ([sender.titleLabel.text isEqualToString:@"立即预约"]) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"是否预约该课程？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        alertView.tag = TAG_BOOKING;
//        [alertView show];
//        [alertView release];
////        [self.view addSubview:self.backEnableView];
////        [self.view addSubview:self.appointmentAlertView];
//    }
//    if ([sender.titleLabel.text isEqualToString:@"加入动Club即可预约"] ||
//        [self.mainTitleLabel.text isEqualToString:@"续费即可预约"]) {
//        if ([self isLoginAndShowLoginIfNotWithMessage:@"buy"]) {
//            [self pushRechargeController];
//        }
//
//    }
//    
//    if ([sender.titleLabel.text isEqualToString:@"预约前请先上传头像"]) {
//        [MobClickUtils event:umeng_event_month_course_detail_click_upload_portrait];
//        
//        MonthCardFinishPayController *controller = [[MonthCardFinishPayController alloc]init];
//        [self.navigationController pushViewController:controller animated:YES];
//        [controller release];
//    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_BOOKING) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [MonthCardService bookCourse:(id)self goodsId:self.course.courseId userId:self.user.userId];
            [SportProgressView showWithStatus:DDTF(@"正在帮您预约...") hasMask:YES];
        } else {
            [MobClickUtils event:umeng_event_month_course_detail_click_book label:@"取消预约"];
        }
    }
}

//- (IBAction)clickedSureOrCancelButton:(UIButton *)sender {
//    [self.appointmentAlertView removeFromSuperview];
//    if ([sender.titleLabel.text isEqualToString:@"确定"]) {
//
//        [[MonthCardService defaultService] bookCourse:(id)self goodsId:self.course.courseId userId:self.user.userId];
//        [SportProgressView showWithStatus:DDTF(@"正在帮您预约...") hasMask:YES];
//        
//    }else{
//        [self.backEnableView removeFromSuperview];
//    }
//}

//- (IBAction)clickedXcancelButton:(UIButton *)sender {
//    [self.successView removeFromSuperview];
//    [self.backEnableView removeFromSuperview];
//}

-(void)pushRechargeController
{
    [MobClickUtils event:umeng_event_month_course_detail_click_buy];
    MonthCardRechargeController *controller = [[MonthCardRechargeController alloc]init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)isLoginAndShowLoginIfNotWithMessage:(NSString *)message
{
    if ([UserManager isLogin]) {
        return YES;
    } else {
        LoginController *controller = [[LoginController alloc] init];
       
        controller.loginDelegate = self;
        controller.loginDelegateParameter = message;
        [self.navigationController pushViewController:controller animated:YES];
        return NO;
    }
}

- (void)didLoginAndPopController:(NSString *)parameter
{
    //buy
    if ([parameter isEqualToString:@"buy"]) {
        [self pushRechargeController];
    }
}


//- (void)dealloc {
//    [_appointmentButton release];
//    [_myWebView release];
//    [_rightTopView release];
//    [_course release];
//    [_buttonSuperView release];
//    [_mainTitleLabel release];
//    [_subTtleLabel release];
//    [_user release];
//    [_endTime release];
//    [_appointmentAlertView release];
//    [_backEnableView release];
//    [_successView release];
//    [_sucessLabel release];
//    [super dealloc];
//}
@end
