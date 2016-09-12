//
//  CreateActivityController.m
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "CreateActivityController.h"
#import "UIView+Utils.h"
#import "CircleProjectManager.h"
#import "SportPopupView.h"
#import "UserManager.h"
#import "SportProgressView.h"

@interface CreateActivityController ()

@property (strong, nonatomic) CircleProject *selectedProject;
@property (assign, nonatomic) int selectedThemeId;  //id从0开始，就是index
@property (strong, nonatomic) NSArray *peopleCoutList;
@property (assign, nonatomic) int selectedPeopleCountIndex;
@property (assign, nonatomic) int selectedCostType;  //费用方式
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (assign, nonatomic) int selecedNingmengType;  //柠檬方式0:无，1：送，2：索取
@property (assign, nonatomic) int ningmengCount;
@property (strong, nonatomic) NSDate *promiseEndTime; //报名的截止时间

@property (assign, nonatomic) BOOL hasOpenRequire;
@property (copy, nonatomic) NSString *selectedRequireGender;
@property (assign, nonatomic) int selectedRequireMinAge;
@property (assign, nonatomic) int selectedRequireMaxAge;
@property (assign, nonatomic) int selectedRequireLevel;

@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@end

#define TAG_BACKGROUND_IAMGE_VIEW_2 88  //有描边的背景图的tag
#define TAG_BACKGROUND_IAMGE_VIEW   89  //背景图的tag
#define TAG_PULL_DOWN_BUTTON        90  //下拉按钮的的tag
#define TAG_PROJECT_START           100 //项目的单选按钮tag：100,101,102
#define TAG_THEME_START             150 //主题的单选按钮tag：150,151,152,153
#define TAG_PEOPLE_COUNT_START      200 //人数的单选按钮tag：200,201,202
#define TAG_COST_TYPE_START         250 //费用方式的单选按钮tag：250,251,252,253
#define TAG_NINGMENG_TYPE_START     300 //柠檬方式的单选按钮tag：300,301,302
#define TAG_REQUIRE_LEVEL_START     350 //要求的水平的单选按钮tag：350,351,352,353

#define TAG_PICKER_PROJECT          20
#define TAG_PICKER_PEOPLE_COUNT     21
#define TAG_PICKER_ACTIVITY_TIME    22
#define TAG_PICKER_PROMISE_END_TIME 23
#define TAG_PICKER_REQUIRE_GENDER   24
#define TAG_PICKER_REQUIRE_MIN_AGE  25
#define TAG_PICKER_REQUIRE_MAX_AGE  26
#define TAG_PICKER_LEMON_COUNT      27

#define TAG_TEXT_FIELD_COST         40
#define TAG_TEXT_FIELD_ADDRESS      41

@implementation CreateActivityController

- (void)viewDidUnload {
    [self setSelectProjectButton:nil];
    [self setThemeSelectedBackgroundImageView:nil];
    [self setSelectPeopleCountButton:nil];
    [self setTotalCostTextField:nil];
    [self setCostTypeSelectedBackgroundImageView:nil];
    [self setActivityTimeButton:nil];
    [self setNingmengTypeSelectedBackgroundImageView:nil];
    [self setAddressTextField:nil];
    [self setProimseEndTimeButton:nil];
    [self setDescTextView:nil];
    [self setRequireSwitchButton:nil];
    [self setRequireHolderView:nil];
    [self setRequireGenderButton:nil];
    [self setRequireMinAgeButton:nil];
    [self setRequireMaxAgeButton:nil];
    [self setRequireLevelSelectedBackgroundImageView:nil];
    [self setClearControl:nil];
    [self setDescTipsLabel:nil];
    [super viewDidUnload];
}

- (IBAction)touchDownBackground:(id)sender {
    [self.totalCostTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
    [self.descTextView resignFirstResponder];
    self.clearControl.hidden = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self touchDownBackground:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.clearControl.hidden = NO;
    if (textField.tag == TAG_TEXT_FIELD_COST) {
        [(UIScrollView *)(self.view) setContentOffset:CGPointMake(0, 110)];
    } else if (textField.tag == TAG_TEXT_FIELD_ADDRESS) {
        [(UIScrollView *)(self.view) setContentOffset:CGPointMake(0, 500)];
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.clearControl.hidden = NO;
    [(UIScrollView *)(self.view) setContentOffset:CGPointMake(0, 660)];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([_descTextView.text length] > 0) {
        self.descTipsLabel.hidden = YES;
    } else {
        self.descTipsLabel.hidden = NO;
    }
}

- (void)updateAllBackgroundImageView{
    NSMutableArray *allSubViews = [NSMutableArray arrayWithArray:[self.view subviews]];
    [allSubViews addObjectsFromArray:[self.requireHolderView subviews]];
    
    for (UIView *subView in allSubViews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            if (subView.tag == TAG_BACKGROUND_IAMGE_VIEW) {
                UIImageView *iv = (UIImageView *)subView;
                [iv setImage:[SportImage inputBackground2Image]];
            } else if (subView.tag == TAG_BACKGROUND_IAMGE_VIEW_2) {
                UIImageView *iv = (UIImageView *)subView;
                [iv setImage:[SportImage inputBackground3Image]];
            }
        }
        if (subView.tag == TAG_PULL_DOWN_BUTTON
            && [subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            [button setBackgroundImage:[SportImage inputBackground2Image] forState:UIControlStateNormal];
        }
    }
    
    //主题的选择背景
    [self.themeSelectedBackgroundImageView setImage:[SportImage blueButtonImage]];
    
    [self.costTypeSelectedBackgroundImageView setImage:[SportImage blueButtonImage]];
    
    [self.ningmengTypeSelectedBackgroundImageView setImage:[SportImage blueButtonImage]];
    
    [self.requireLevelSelectedBackgroundImageView setImage:[SportImage blueButtonImage]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发布活动";
    [self.view setBackgroundColor:[SportColor defaultPageBackgroundColor]];
    [self.view updateHeight:[UIScreen mainScreen].bounds.size.height - 64];
    [(UIScrollView *)(self.view) setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 1100)];
    
    [self updateAllBackgroundImageView];
    [self initTheme];
    [self initProject];
    [self initPeopleCount];
    [self initCost];
    [self initCostType];
    [self initAcvitityTime];
    [self initNingmengType];
    [self initPromiseEndTime];
    [self initRequire];
    [self initRequireGender];
    [self initMinAge];
    [self initMaxAge];
    [self initRequireLevel];
    
    [self createRightTopButton:@"提交"];
    
    [MobClickUtils event:umeng_event_enter_create_activity_page];
}

#define TAG_SUBMIT_ALERTVIEW                2014051701
#define TAG_INPUT_LEMON_COUNT_ALERTVIEW     2014051702

- (void)clickRightTopButton:(id)sender
{
    [self submit];
}

- (void)submit
{
    HDLog(@"click create");
    [self.totalCostTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
    [self.descTextView resignFirstResponder];
    
    if (_selectedProject == nil) {
        [SportPopupView popupWithMessage:@"请选择项目"];
        return;
    }
    
    if (_selectedThemeId == -1) {
        [SportPopupView popupWithMessage:@"请选择主题"];
        return;
    }
    
    if (_selectedPeopleCountIndex == -1) {
        [SportPopupView popupWithMessage:@"请选择人数"];
        return;
    }
    
//    if ([_totalCostTextField.text length] == 0) {
//        [SportPopupView popupWithMessage:@"请输入总费用"];
//        return;
//    }
    
    if (_startTime == nil) {
        [SportPopupView popupWithMessage:@"请选择活动的时间"];
        return;
    }
    
    if ([_addressTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入地址"];
        return;
    }
    
    if ([_descTextView.text length] > 140) {
        [SportPopupView popupWithMessage:@"备注不可超过140字"];
        return;
    }
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    NSInteger peopleCount = _selectedPeopleCountIndex + 2;
    
    if (_selecedNingmengType == 1) {
        if (user.lemonCount < (peopleCount - 1) * _ningmengCount)
        {
            [SportPopupView popupWithMessage:@"你的柠檬数不足"];
            return;
        } else {
            NSString *message = [NSString stringWithFormat:@"发布该活动将花费%d个柠檬",(int)((peopleCount - 1) * _ningmengCount)];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_SUBMIT_ALERTVIEW;
            [alertView show];
        }
        
        return;
    }
    
    [self createActivity];
}

- (void)createActivity
{
    [MobClickUtils event:umeng_event_submit_create_activity];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    [SportProgressView showWithStatus:@"正在创建"];
    [ActivityService createActivity:self
                              proId:_selectedProject.proId
                            actName:_selectedThemeId
                            actCost:_selectedCostType
                             userId:user.userId
                       peopleNumber:(int)_selectedPeopleCountIndex + 2
                            address:_addressTextField.text
                          startTime:[formatter stringFromDate:_startTime]
                            endTime:[formatter stringFromDate:_promiseEndTime]
                       giveIntegral:(int)_ningmengCount
                       integralType:_selecedNingmengType
                            actDesc:_descTextView.text
                             minAge:(int)_selectedRequireMinAge
                             maxAge:(int)_selectedRequireMaxAge
                         sportLevel:_selectedRequireLevel
                             gender:_selectedRequireGender
                           latitude:_latitude
                          longitude:_longitude
                       actCostTotal:[_totalCostTextField.text intValue]];
    
//    [SportProgressView showWithStatus:@"正在创建"];
//    [[ActivityService defaultService] createActivity:self
//                                               proId:_selectedProject.proId
//                                             actName:_selectedThemeId
//                                             actCost:_selectedCostType
//                                              userId:@"1498"
//                                        peopleNumber:_selectedPeopleCountIndex + 2
//                                             address:_addressTextField.text
//                                           startTime:[formatter stringFromDate:_startTime]
//                                             endTime:[formatter stringFromDate:_promiseEndTime]
//                                        giveIntegral:_ningmengCount
//                                        integralType:_selecedNingmengType
//                                             actDesc:_descTextView.text
//                                              minAge:_selectedRequireMinAge
//                                              maxAge:_selectedRequireMaxAge
//                                          sportLevel:_selectedRequireLevel
//                                              gender:_selectedRequireGender
//                                            latitude:31.22735
//                                           longitude:121.4407
//                                        actCostTotal:[_totalCostTextField.text intValue]];
    
}

- (void)didCreateActivity:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"创建成功"];
        if ([_delegate respondsToSelector:@selector(didCreateActivitySuccess)]) {
            [_delegate didCreateActivitySuccess];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

#pragma mark - 项目
- (void)initProject
{
    int index = 0;
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_PROJECT_START + index];
        [button setTitle:pro.proName forState:UIControlStateNormal];
        index ++;
    }
    [self udpateProjectButtons];
}

- (void)udpateProjectButtons
{
    int selectedIndex = -1;
    int index = 0;
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        if ([self.selectedProject.proId isEqualToString:pro.proId]) {
            selectedIndex = index;
        }
        index ++;
    }
    
    for (int i =0 ; i < 3; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_PROJECT_START + i];
        if (selectedIndex == i) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    if (selectedIndex >= 0) {
        [self.selectProjectButton setTitle:_selectedProject.proName forState:UIControlStateNormal];
    } else {
        [self.selectProjectButton setTitle:@"请选择" forState:UIControlStateNormal];
    }
}

- (IBAction)clickProjectRadioButton:(id)sender
{
    UIButton *selectedButton = (UIButton *)sender;
    
    NSInteger selectedIndex = selectedButton.tag - TAG_PROJECT_START;
    NSArray *list = [[CircleProjectManager defaultManager] circleProjectList];
    if ([list count] > selectedIndex) {
        self.selectedProject= [list objectAtIndex:selectedIndex];
        [self udpateProjectButtons];
    }
}


- (IBAction)clickProjectSelectButton:(id)sender {
    NSMutableArray *nameList = [NSMutableArray array];
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        [nameList addObject:pro.proName];
    }
    
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_PROJECT;
    view.delegate = self;
    view.dataList = nameList;
    [view show];
}

#pragma mark - SportPickerViewDelegate
- (void)didClickSportPickerViewOKButton:(SportPickerView *)sportPickerView row:(NSInteger)row
{
    if (sportPickerView.tag == TAG_PICKER_PROJECT) {
        self.selectedProject= [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:row];
        [self udpateProjectButtons];
    }
    
    if (sportPickerView.tag == TAG_PICKER_PEOPLE_COUNT) {
        self.selectedPeopleCountIndex= (int)row;
        [self udpatePeopleCountButtons];
    }
    
    if (sportPickerView.tag == TAG_PICKER_LEMON_COUNT) {
        self.ningmengCount= (int)row + 1;
        [self updateNingmengTypeButtons];
    }
    
    if (sportPickerView.tag == TAG_PICKER_REQUIRE_GENDER) {
        if (row == 0) {
            self.selectedRequireGender = @"";
        }if (row == 1) {
            self.selectedRequireGender = @"m";
        } else if (row == 2){
            self.selectedRequireGender = @"f";
        }
        [self udateRequireGenderButton];
    }
    
    if (sportPickerView.tag == TAG_PICKER_REQUIRE_MIN_AGE) {
        self.selectedRequireMinAge = 15 + (int)row;
        [self udateRequireMinAgeButton];
    }
    
    if (sportPickerView.tag == TAG_PICKER_REQUIRE_MAX_AGE) {
        self.selectedRequireMaxAge = 15 + (int)row;
         [self udateRequireMaxAgeButton];
    }
}

#pragma mark - 主题
- (void)initTheme
{
    self.selectedThemeId = 0;
    [self updateThemeButtons];
}

- (void)updateThemeButtons
{
    for (int i = 0 ; i < 4; i ++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_THEME_START + i];
        if (i == _selectedThemeId) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_THEME_START + _selectedThemeId];
    [UIView animateWithDuration:0.08 animations:^{
        [self.themeSelectedBackgroundImageView updateCenterX:button.center.x];
    }];
}

- (IBAction)clickThemeRadioButton:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    int selectedIndex = (int)selectedButton.tag - TAG_THEME_START;
    self.selectedThemeId = selectedIndex;
    [self updateThemeButtons];
}

#pragma mark - 人数
- (void)initPeopleCount
{
    self.selectedPeopleCountIndex = -1;
    self.peopleCoutList = [NSArray arrayWithObjects:@"2人",@"3人",@"4人",@"5人",@"6人",@"7人",@"8人",@"9人", nil];
    
    int index = 0;
    for (NSString *title in _peopleCoutList) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_PEOPLE_COUNT_START + index];
        [button setTitle:title forState:UIControlStateNormal];
        index ++;
    }
    [self udpateProjectButtons];
}

- (void)udpatePeopleCountButtons
{
    for (int i =0 ; i < 3; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_PEOPLE_COUNT_START + i];
        if (i == _selectedPeopleCountIndex) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    if (_selectedPeopleCountIndex >= 0) {
        NSString *title = [_peopleCoutList objectAtIndex:_selectedPeopleCountIndex];
        [self.selectPeopleCountButton setTitle:title forState:UIControlStateNormal];
    } else {
        [self.selectPeopleCountButton setTitle:@"请选择" forState:UIControlStateNormal];
    }
}

- (IBAction)clickPeopleCountRadioButton:(id)sender
{
    UIButton *selectedButton = (UIButton *)sender;
    
    self.selectedPeopleCountIndex = (int)selectedButton.tag - TAG_PEOPLE_COUNT_START;
    [self udpatePeopleCountButtons];
}

- (IBAction)clickPeopleCountSelectButton:(id)sender {
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_PEOPLE_COUNT;
    view.delegate = self;
    view.dataList = _peopleCoutList;
    [view show];
}

#pragma mark - 总费用
- (void)initCost
{
    //self.totalCostTextField.text = @"0";
}

#pragma mark - 费用方式
- (void)initCostType
{
    self.selectedCostType = 0;
    [self updateCostTypeButtons];
}

- (void)updateCostTypeButtons
{
    for (int i = 0 ; i < 3; i ++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_COST_TYPE_START + i];
        if (i == _selectedCostType) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_COST_TYPE_START + _selectedCostType];
    [UIView animateWithDuration:0.08 animations:^{
        [self.costTypeSelectedBackgroundImageView updateCenterX:button.center.x];
    }];
}

- (IBAction)clickCostTypeRadioButton:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    int selectedIndex = (int)selectedButton.tag - TAG_COST_TYPE_START;
    self.selectedCostType = selectedIndex;
    [self updateCostTypeButtons];
}

#pragma mark - 活动时间
- (void)initAcvitityTime
{
    [self updateActivityTimeButton];
}

- (void)updateActivityTimeButton
{
    if (_startTime == nil) {
        [self.activityTimeButton setTitle:@"请选择" forState:UIControlStateNormal];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd    HH:mm"];
        NSString *str = [NSString stringWithString:[formatter stringFromDate:_startTime]];
        [self.activityTimeButton setTitle:str forState:UIControlStateNormal];
    }
}

- (IBAction)clickActivityTimeButton:(id)sender {
    SportTimePickerView *view = [SportTimePickerView createSportTimePickerView];
    view.datePickerView.minimumDate = [NSDate date];
    view.tag = TAG_PICKER_ACTIVITY_TIME;
    view.delegate = self;
    [view show];
}

//- (NSArray *)activityTimeList
//{
//    //月日
//    NSMutableArray *list1 = [NSMutableArray array];
//    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
//    [formatter setDateFormat:@"MM月dd日"];
//    NSDate *today = [NSDate date];
//    NSTimeInterval oneDayInterval = 24 * 60 * 60;
//    for (int i = 0 ; i < 100 ; i ++) {
//        NSString *title = [formatter stringFromDate:[today dateByAddingTimeInterval:i * oneDayInterval]];
//        [list1 addObject:title];
//    }
//    
//    //时
//    NSMutableArray *list2 = [NSMutableArray array];
//    for (int i = 0 ; i < 24 ; i ++) {
//        NSString *title = [NSString stringWithFormat:@"%d时", i];
//        [list2 addObject:title];
//    }
//    
//    //分
//    NSMutableArray *list3 = [NSMutableArray array];
//    for (int i = 0 ; i < 60 ; i ++) {
//        NSString *title = [NSString stringWithFormat:@"%d分", i];
//        [list3 addObject:title];
//    }
//    
//    //持续多少小时
//    NSMutableArray *list4 = [NSMutableArray array];
//    for (int i = 0 ; i < 10 ; i ++) {
//        NSString *title = [NSString stringWithFormat:@"持续%d小时", i+1];
//        [list4 addObject:title];
//    }
//    
//    NSMutableArray *totalList = [NSMutableArray arrayWithObjects:list1, list2, list3, list4, nil];
//    return totalList;
//}
//
//- (void)didClickSportStartAndEndTimePickerViewOKButton:(SportStartAndEndTimePickerView *)sportPickerView
//{
//    //日期
//    int dateRow = [sportPickerView.dataPickerView selectedRowInComponent:0];
//    NSDate *selectedDay = [[NSDate date] dateByAddingTimeInterval:24 * 60 * 60 * dateRow];
//    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *dateZeroHourString = [formatter stringFromDate:selectedDay];
//    NSDate *dateZeroHour = [formatter dateFromString:dateZeroHourString]; //一天的零时零分
//    
//    //小时
//    int hourRow = [sportPickerView.dataPickerView selectedRowInComponent:1];
//    
//    //分
//    int muRow = [sportPickerView.dataPickerView selectedRowInComponent:2];
//    
//    self.startTime = [[dateZeroHour dateByAddingTimeInterval:hourRow * 60 * 60] dateByAddingTimeInterval:muRow * 60];
//    
//    //持续多少小时
//    int chixuRow = [sportPickerView.dataPickerView selectedRowInComponent:3];
//    self.endTime = [_startTime dateByAddingTimeInterval:60 * 60 * (chixuRow +1)];
//    
//    [self updateActivityTimeButton];
//}
//
//- (void)updateActivityTimeButton
//{
//    if (_startTime == nil || _endTime == nil) {
//        [self.activityTimeButton setTitle:@"请选择" forState:UIControlStateNormal];
//    } else {
//        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//        NSMutableString *str = [NSMutableString stringWithString:[formatter stringFromDate:_startTime]];
//        [formatter setDateFormat:@"HH:mm"];
//        [str appendFormat:@"-%@", [formatter stringFromDate:_endTime]];
//        [self.activityTimeButton setTitle:str forState:UIControlStateNormal];
//    }
//}


#pragma mark - 柠檬交易方式
- (void)initNingmengType
{
    self.selecedNingmengType = 0;
    self.ningmengCount = 0;
    
    [self updateNingmengTypeButtons];
}

- (void)updateNingmengTypeButtons
{
    for (int i = 0 ; i < 3; i ++) {
        UIButton *one = (UIButton *)[self.view viewWithTag:TAG_NINGMENG_TYPE_START + i];
        if (i == _selecedNingmengType) {
            one.selected = YES;
        } else {
            one.selected = NO;
        }
    }
    
    [self updateNingmengTypeButtonTitles];
    
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_NINGMENG_TYPE_START + _selecedNingmengType];
    [UIView animateWithDuration:0.08 animations:^{
        [self.ningmengTypeSelectedBackgroundImageView updateCenterX:button.center.x];
    }];
}

- (void)updateNingmengTypeButtonTitles
{
    for (int i = 0 ; i < 3; i ++) {
        HDLog(@"TYPE:%d, COUNT:%d", (int)_selecedNingmengType, (int)_ningmengCount);
        
        UIButton *aButton = (UIButton *)[self.view viewWithTag:TAG_NINGMENG_TYPE_START + i];
        
        if (i == 0) {
            [aButton setTitle:@"无" forState:UIControlStateNormal];
        }
        
        if (i == 1) {
            if (_selecedNingmengType == 1 && _ningmengCount > 0) {
                [aButton setTitle:[NSString stringWithFormat:@"赠送%d个", _ningmengCount] forState:UIControlStateNormal];
            } else {
                [aButton setTitle:@"赠送" forState:UIControlStateNormal];
            }
        }
        
        if (i == 2) {
            if (_selecedNingmengType == 2 && _ningmengCount > 0) {
                [aButton setTitle:[NSString stringWithFormat:@"索取%d个", _ningmengCount] forState:UIControlStateNormal];
            } else {
                [aButton setTitle:@"索取" forState:UIControlStateNormal];
            }
        }
    }
}

- (IBAction)clickNingmengRadioButton:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    int selectedIndex = (int)selectedButton.tag - TAG_NINGMENG_TYPE_START;
    self.selecedNingmengType = selectedIndex;
    
    if (selectedIndex > 0) {
        [self showInputLemonCountView];
        //[self showSelectLemonCount];
    } else {
        self.ningmengCount = 0;
        [self updateNingmengTypeButtons];
    }
}

//- (void)showSelectLemonCount
//{
//    NSString *typeString = (_selecedNingmengType == 1 ? @"赠送" : @"索取");
//    NSMutableArray *mu = [NSMutableArray array];
//    for (int i = 0; i < 100 ; i ++) {
//        [mu addObject:[NSString stringWithFormat:@"%@%d个", typeString, i + 1]];
//    }
//    SportPickerView *view = [SportPickerView createSportPickerView];
//    view.tag = TAG_PICKER_LEMON_COUNT;
//    view.delegate = self;
//    view.dataList = mu;
//    [view show];
//}

- (void)showInputLemonCountView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入柠檬数" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = TAG_INPUT_LEMON_COUNT_ALERTVIEW;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_INPUT_LEMON_COUNT_ALERTVIEW) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            int count = [textField.text intValue];
            self.ningmengCount = count;
            if (_ningmengCount == 0) {
                self.selecedNingmengType = 0;
            }
            [self updateNingmengTypeButtons];
        } else {
            self.ningmengCount = 0;
            self.selecedNingmengType = 0;
            [self updateNingmengTypeButtons];
        }
    } else {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self createActivity];
        }
    }
}
#pragma mark - 地址
- (IBAction)clickMapButton:(id)sender {
    LocateInMapController *controller = [[LocateInMapController alloc] initWithDelegate:self SelectedLatitude:_latitude selectedLongtitude:_longitude isShowSelectedLocation:NO];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didLocateInMap:(NSString *)address
              latitude:(double)latitude
             longitude:(double)longitude
isShowSelectedLocation:(BOOL)isShowSelectedLocation;
{
    self.addressTextField.text = address;
    self.latitude = latitude;
    self.longitude = longitude;
}

#pragma mark - 截止时间
- (IBAction)clickPromiseEndTimeButton:(id)sender {
    SportTimePickerView *view = [SportTimePickerView createSportTimePickerView];
    view.datePickerView.minimumDate = [NSDate date];
    if (_startTime) {
        view.datePickerView.maximumDate = _startTime;
    }
    view.tag = TAG_PICKER_PROMISE_END_TIME;
    view.delegate = self;
    [view show];
}

- (void)initPromiseEndTime
{
    [self updatePromiseEndTimeButton];
}

- (void)updatePromiseEndTimeButton
{
    if (_promiseEndTime == nil) {
        [self.proimseEndTimeButton setTitle:@"请选择" forState:UIControlStateNormal];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd    HH:mm"];
        [self.proimseEndTimeButton setTitle:[formatter stringFromDate:_promiseEndTime] forState:UIControlStateNormal];
    }
}

- (void)didClickSportTimePickerViewOKButton:(SportTimePickerView *)sportTimePickerView selectedTime:(NSDate *)selectedTime
{
    if (sportTimePickerView.tag == TAG_PICKER_PROMISE_END_TIME) {
        self.promiseEndTime = selectedTime;
        [self updatePromiseEndTimeButton];
    } else if (sportTimePickerView.tag == TAG_PICKER_ACTIVITY_TIME){
        self.startTime = selectedTime;
        [self updateActivityTimeButton];
    }
}

#pragma mark - 应约者要求
- (void)initRequire
{
    self.requireHolderView.hidden = YES;
}

- (IBAction)clickRequireSwitchButton:(id)sender {
    self.requireSwitchButton.selected = !self.requireSwitchButton.selected;
    if (_requireSwitchButton.selected) {
        _hasOpenRequire = YES;
        self.requireHolderView.hidden = NO;
        
        [MobClickUtils event:umeng_event_click_promise_user_require];
    } else {
        _hasOpenRequire = NO;
        self.requireHolderView.hidden = YES;
    }
}

#pragma mark - 性别
- (void)initRequireGender
{
    self.selectedRequireGender = nil;
    [self udateRequireGenderButton];
}

- (void)udateRequireGenderButton
{
    if (_selectedRequireGender == nil) {
        [self.requireGenderButton setTitle:@"请选择" forState:UIControlStateNormal];
    } else {
        NSString *title = nil;
        if ([_selectedRequireGender isEqualToString:@"m"]) {
            title = @"男";
        } else if ([_selectedRequireGender isEqualToString:@"f"])
        {
            title = @"女";
        } else {
            title = @"不限";
        }
        [self.requireGenderButton setTitle:title forState:UIControlStateNormal];
    }
}

- (IBAction)clickRequireGenderButton:(id)sender {
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_REQUIRE_GENDER;
    view.delegate = self;
    view.dataList = [NSArray arrayWithObjects:@"不限", @"男", @"女", nil];
    [view show];
}

#pragma mark - 最小年龄
- (void)initMinAge
{
    _selectedRequireMinAge = -1;
    [self udateRequireMinAgeButton];
}

- (void)udateRequireMinAgeButton
{
    if (_selectedRequireMinAge == -1) {
        [self.requireMinAgeButton setTitle:@"请选择" forState:UIControlStateNormal];
    } else {
        NSString *title = [NSString stringWithFormat:@"%d岁", _selectedRequireMinAge];
        [self.requireMinAgeButton setTitle:title forState:UIControlStateNormal];
    }
}

- (NSArray *)ageList
{
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 15; i < 71; i ++) {
        [list addObject:[NSString stringWithFormat:@"%d岁", i]];
    }
    return list;
}

- (IBAction)clickRequireMinAgeButton:(id)sender {
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_REQUIRE_MIN_AGE;
    view.delegate = self;
    view.dataList = [self ageList];
    [view show];
}

#pragma mark - 最大年龄
- (void)initMaxAge
{
    _selectedRequireMaxAge = -1;
    [self udateRequireMaxAgeButton];
}

- (void)udateRequireMaxAgeButton
{
    if (_selectedRequireMaxAge == -1) {
        [self.requireMaxAgeButton setTitle:@"请选择" forState:UIControlStateNormal];
    } else {
        NSString *title = [NSString stringWithFormat:@"%d岁", _selectedRequireMaxAge];
        [self.requireMaxAgeButton setTitle:title forState:UIControlStateNormal];
    }
}

- (IBAction)clickRequireMaxAgeButton:(id)sender {
    SportPickerView *view = [SportPickerView createSportPickerView];
    view.tag = TAG_PICKER_REQUIRE_MAX_AGE;
    view.delegate = self;
    view.dataList = [self ageList];
    [view show];
}

#pragma mark - 水平
- (void)initRequireLevel
{
    self.selectedRequireLevel = 0;
    [self updateRequireLevelButtons];
}

- (void)updateRequireLevelButtons
{
    for (int i =0 ; i < 5; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_REQUIRE_LEVEL_START + i];
        if (_selectedRequireLevel == i) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_REQUIRE_LEVEL_START + _selectedRequireLevel];
    [UIView animateWithDuration:0.08 animations:^{
        [self.requireLevelSelectedBackgroundImageView updateCenterX:button.center.x];
    }];
}

- (IBAction)clickRequireLevelRadioButton:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    int selectedIndex = (int)selectedButton.tag - TAG_REQUIRE_LEVEL_START;
    self.selectedRequireLevel = selectedIndex;
    [self updateRequireLevelButtons];
}

@end
