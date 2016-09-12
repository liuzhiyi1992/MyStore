//
//  SearchBusinessController.m
//  Sport
//
//  Created by haodong  on 13-6-14.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SearchBusinessController.h"
#import "SearchManager.h"
#import "SportPopupView.h"
#import "UIView+Utils.h"
#import "SearchResultController.h"
#import "CityManager.h"
#import "NSDictionary+JsonValidValue.h"
#import "NSString+Utils.h"
#import "ForumSearchResultCell.h"
#import "BusinessSearchDataManager.h"
#import "SearchResultTableView.h"


#define CELLHEIGHT 50

@interface SearchBusinessController ()<UITextFieldDelegate,SearchResultTableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (strong, nonatomic) IBOutlet UIButton *goBackButton;
@property (strong, nonatomic) IBOutlet UIImageView *searchBackground;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *cleanButton;
@property (strong, nonatomic) IBOutlet UILabel *cityLocationLabel;
@property (strong, nonatomic) UIButton *allSearchButton;

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) SearchResultTableView *searchDataTableView;
@end

@implementation SearchBusinessController
- (NSMutableArray *)dataList{
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (void)dealloc {
    [self deregsiterKeyboardNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}


- (id)initWithControllertype:(ControllerType)controllerType{
    self = [super init];
    if (self) {
        self.controllerType = controllerType;
        //增加监听，当键盘出现或改变时收出消息
        [self registerForKeyboardNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([SearchManager tenSearchWords].count <= 4) {
            self.dataList = [NSMutableArray arrayWithArray:[SearchManager tenSearchWords]];
        }else{
            for (int i = 0; i < 4; i++) {
                [self.dataList addObject:[SearchManager tenSearchWords][i]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataTableView reloadData];
        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cityLocationLabel.font = [UIFont boldSystemFontOfSize:18];
    if ([CityManager readCurrentCityName].length > 0) {
        NSString *string = [NSString stringWithFormat:@"%@·%@",DDTF(@"kSearch"),[CityManager readCurrentCityName]];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:14.0] range:NSMakeRange(3, [CityManager readCurrentCityName].length)];
       
        self.cityLocationLabel.attributedText = attrString;
    }else{
        self.cityLocationLabel.text = DDTF(@"kSearch");
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    //iphone5以下屏幕:480
    //iphone5以上（包括iphone5）屏幕:568
    //HDLog(@"screenHeight:%f", screenHeight);
    [self.dataTableView updateHeight:screenHeight - 114];
    [self.dataTableView setSeparatorStyle:NO];
    
    self.searchDataTableView = [SearchResultTableView createSearchResultTableView];
    self.searchDataTableView.searchDelegate = self;
    [self.view addSubview:self.searchDataTableView];
    
    if (self.controllerType == ControllerTypeSearchResult) {
        self.searchTextField.text = self.transmitSearchText;
        [self.searchDataTableView reloadSearchResultTableViewWithText:self.transmitSearchText];
        [self.searchDataTableView setHidden:NO];
        [self.dataTableView setHidden:YES];
        [self.cleanButton setHidden:NO];
        [self.searchButton setBackgroundColor:[SportColor defaultColor]];
        [self.searchButton setEnabled:YES];
    }else{
        [self.searchDataTableView setHidden:YES];
        [self.dataTableView setHidden:NO];
        [self.cleanButton setHidden:YES];
        [self.searchButton setBackgroundColor:[SportColor hexAColor]];
        [self.searchButton setEnabled:NO];
    }
    
    [self initSearchUI];
}

- (void)textFieldTextChange {
    if(_searchTextField.text.length != 0) {
        [self awakenUpSearchButton];
    }
}

- (void)initSearchUI{
    if (iPhone6Plus) {
        [self.goBackButton updateOriginX:17];
    }else{
        [self.goBackButton updateOriginX:13.5];
    }
    
    self.allSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchTextField addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
    self.searchTextField.delegate = self;
    [self.searchTextField becomeFirstResponder];
    [self.searchBackground setImage:[[UIImage imageNamed:@"SearchBackground"] stretchableImageWithLeftCapWidth:15 topCapHeight:0]];
    
    self.searchButton.layer.cornerRadius = 3.0f;
    self.searchButton.layer.masksToBounds = YES;
}

- (IBAction)clickGoBackButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)clickCleanButton:(id)sender {
    [MobClickUtils event:umeng_event_click_search_input_clear];
    self.searchTextField.text = @"";
    self.cleanButton.hidden = YES;
    [self.searchButton setBackgroundColor:[SportColor hexAColor]];
    self.searchButton.enabled = NO;
    self.dataTableView.hidden = NO;
    self.searchDataTableView.hidden = YES;
}

- (IBAction)clickSearchButton:(UIButton *)sender {
    [self pushBusinessListView:self.searchTextField.text];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [SportColor hex6TextColor];
    }
        
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
        
    NSInteger tag = 100;
        
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.textColor = [SportColor hex6TextColor];
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        
    cell.textLabel.text = [_dataList objectAtIndex:indexPath.row];
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:tag];
    [button removeFromSuperview];
        
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_line"]];
    [image setFrame:(CGRect){
        0, 49, cell.contentView.frame.size.width, 1
    }];
    [cell.contentView addSubview:image];
    return cell;
}

#define BUTTON_TITLE_OPEN @"全部搜索记录"
#define BUTTON_TITLE_CLEAR @"清空搜索记录"

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    [self.allSearchButton setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CELLHEIGHT)];
    self.allSearchButton.backgroundColor = [UIColor whiteColor];
    [self.allSearchButton setTitleColor:[SportColor hexAColor] forState:UIControlStateNormal];
    [self.allSearchButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_line"]];
    [image setFrame:CGRectMake(0, 49, [UIScreen mainScreen].bounds.size.width, 1)];
    [self.allSearchButton addSubview:image];

    
    if ([SearchManager tenSearchWords].count > 4) {
        [self.allSearchButton setTitle:BUTTON_TITLE_OPEN forState:UIControlStateNormal];
    }else{
        [self.allSearchButton setTitle:BUTTON_TITLE_CLEAR forState:UIControlStateNormal];
    }
    
    if ([SearchManager tenSearchWords].count == self.dataList.count) {
        [self.allSearchButton setTitle:BUTTON_TITLE_CLEAR forState:UIControlStateNormal];
    }
    [self.allSearchButton addTarget:self action:@selector(clickClearHistory:) forControlEvents:UIControlEventTouchUpInside];
    return self.allSearchButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.dataList.count == 0) {
        return 0;
    }else{
        return CELLHEIGHT;
    }
}

- (void)clickClearHistory:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSString *title = button.currentTitle;
    if ([title isEqualToString:BUTTON_TITLE_CLEAR]) {
        [SearchManager clearTenSearchWords];
        [MobClickUtils event:umeng_event_click_clear_search_record];
    }else{
        [MobClickUtils event:umeng_event_click_all_search_record];
    }
    self.dataList = [NSMutableArray arrayWithArray:[SearchManager tenSearchWords]];
    [self.dataTableView reloadData];
}

- (void)awakenUpSearchButton {
    [self.cleanButton setHidden:NO];
    [self.searchButton setBackgroundColor:[SportColor defaultColor]];
    self.searchButton.enabled = YES;
}

- (void)sleepDownSearchButton {
    [self.cleanButton setHidden:YES];
    [self.searchButton setBackgroundColor:[SportColor hexAColor]];
    self.searchButton.enabled = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *word = nil;
    [MobClickUtils event:umeng_event_click_history_search_record];
    word = [_dataList objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushBusinessListView:word];
}

#pragma mark - SearchResultTableViewDelegate
- (void)didSelectedTableViewCellWithWord:(NSString *)word{
    [self pushBusinessListView:word];
}

- (void)pushBusinessListView:(NSString *)word
{
    NSString *clearWord = [word stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([clearWord length] == 0) {
        [SportPopupView popupWithMessage:@"请输入内容"];
        return;
    }
    
    if (self.block) {
        self.block(clearWord);
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [SearchManager saveMaxTenSearchWords:clearWord];
    
    [MobClickUtils event:umeng_event_search_business];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self pushBusinessListView:searchBar.text];
}

- (void)viewDidUnload {
    [self setDataTableView:nil];
    [super viewDidUnload];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [MobClickUtils event:umeng_event_search_business];
    [MobClickUtils event:umeng_event_click_search_window_form_search];
}

#pragma mark - TextViewDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.searchTextField.text.length > 0){
        [self.cleanButton setHidden:NO];
        [self.searchButton setBackgroundColor:[SportColor defaultColor]];
        self.searchButton.enabled = YES;
    }else{
        [self.cleanButton setHidden:YES];
        [self.searchButton setBackgroundColor:[SportColor hexAColor]];
        self.searchButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.searchTextField resignFirstResponder];
    [self pushBusinessListView:self.searchTextField.text];
    return YES;
}

#pragma mark --UITextFieldTextDidChangeNotification
- (void)textFieldDidChange:(NSNotification *)obj{
    //不选择高亮的字
    UITextField *textField = (UITextField *)obj.object;
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = nil;
    if (selectedRange) {
        position = [textField positionFromPosition:selectedRange.start offset:0];
    }
    
    // 没有高亮选择的字
    if (!position) {
        NSString *str = textField.text;
        if (str.length > 0){
            [self awakenUpSearchButton];
            self.dataTableView.hidden = YES;
            self.searchDataTableView.hidden = NO;
        }else{
            [self sleepDownSearchButton];
            self.dataTableView.hidden = NO;
            self.searchDataTableView.hidden = YES;
        }
        
        [self.searchDataTableView reloadSearchResultTableViewWithText:str];
    }
    
}
@end
