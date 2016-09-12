//
//  CoachFilterController.m
//  Sport
//
//  Created by liuzhiyi on 15/9/6.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachFilterController.h"
#import "UIImage+normalized.h"
#import "SportImage.h"
#import "UIColor+HexColor.h"
#import "BusinessCategory.h"
#import "UIView+Utils.h"
#import "UIColor+HexColor.h"

#define CATEGORY_BUTTON_HEIGHT 45

@interface CoachFilterController ()

@property (strong, nonatomic) UIButton *selectedItemButton;
@property (strong, nonatomic) UIButton *selectedSexButton;

@end

@implementation CoachFilterController

- (instancetype)initWithCategoryList:(NSArray *)categoryList {
    
    self = [super init];
    if(self) {
        self.categoryList = categoryList;
    }
    return self;
}

- (instancetype)initWithItem:(NSString *)item gender:(NSString *)gender categoryList:(NSArray *)categoryList{
    
    self = [super init];
    if(self) {
        self.item = item;
        self.gender = gender;
        self.categoryList = categoryList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"筛选";
    [self createRightTopButton:@"确定"];

    [self initLayout];
    
    [self initData];
}

- (void)initLayout {

    CGFloat buttonWidth = [[UIScreen mainScreen] bounds].size.width / 3;
    CGFloat buttonHeight = CATEGORY_BUTTON_HEIGHT;
    CGFloat categoryHolderViewHeight;
    
    //holderView高度
    if(0 != self.categoryList.count % 3) {//不能整除
        categoryHolderViewHeight = buttonHeight * (self.categoryList.count / 3 + 1) ;
    }else {//整除
        categoryHolderViewHeight = buttonHeight * (self.categoryList.count / 3) ;
    }
    self.categoryHolderViewHeightConstraint.constant = categoryHolderViewHeight;
    
    //根据数据源添加按钮
    for (int i = 0; i < self.categoryList.count / 3 + 1; i++) {
        
        for (int j = 0; j < 3; j++) {
            
            if( (3 * i + j + 1) > self.categoryList.count) {//数组越界
                break;
            }else {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(j * buttonWidth, i * buttonHeight, buttonWidth, buttonHeight)];
                [btn setTitle:((BusinessCategory *)self.categoryList[3 * i + j]).name forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor whiteColor]];
                [btn setTitleColor:[UIColor hexColor:@"222222"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor hexColor:@"5b73f2"] forState:UIControlStateSelected];
                
                [btn addTarget:self action:@selector(clickItemButton:) forControlEvents:UIControlEventTouchUpInside];
                
                //HelveticaNeue-UltraLight
                //HelveticaNeue-Light
                //ios8_2以下不能使用systemFontSize:weightUIFontWeightLight
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2) {
                    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0f weight:UIFontWeightLight]];
                }else {
                    [btn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.5f]];
                }
                [self.categoryHolderView addSubview:btn];
            }
        }
        
        UIImageView *horizontalSpaceLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_line_e6"]];
        horizontalSpaceLine.frame = CGRectMake(0, i * buttonHeight, [[UIScreen mainScreen] bounds].size.width, 1);
        [self.categoryHolderView addSubview:horizontalSpaceLine];
    }
    
    //底部按钮个数决定底线长度
    switch (self.categoryList.count % 3) {
        case 0:
        {
            UIImageView *horizontalSpaceLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_line_e6"]];
            horizontalSpaceLine.frame = CGRectMake(0, categoryHolderViewHeight, [[UIScreen mainScreen] bounds].size.width, 1);
            [self.categoryHolderView addSubview:horizontalSpaceLine];
            break;
        }
        case 1:
        {
            UIImageView *horizontalSpaceLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_line_e6"]];
            horizontalSpaceLine.frame = CGRectMake(0, categoryHolderViewHeight, [[UIScreen mainScreen] bounds].size.width / 3, 1);
            [self.categoryHolderView addSubview:horizontalSpaceLine];
            
            //多出一个按钮时,右边垂直分界线缩短
            self.rightVerticalLineBottomSpaceConstraint.constant = buttonHeight;
            break;
        }
        case 2:
        {
            UIImageView *horizontalSpaceLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_line_e6"]];
            horizontalSpaceLine.frame = CGRectMake(0, categoryHolderViewHeight, [[UIScreen mainScreen] bounds].size.width / 3 * 2, 1);
            [self.categoryHolderView addSubview:horizontalSpaceLine];
            break;
        }
        default:
            break;
    }
    
    //holderView背景颜色与view背景颜色一致
    [self.categoryHolderView setBackgroundColor:[SportColor defaultPageBackgroundColor]];
    
    //垂直分界线置于所有控件上层(避免按钮刷新后遮掩分界线)
    for (UIImageView *line in self.verticalCellLines) {
        [self.categoryHolderView bringSubviewToFront:line];
    }
}

- (void)initData {
    
    //--限制项目分类
    if(self.item.length > 0) {
        //初始化指定项目
        for (UIButton *btn in _categoryHolderView.subviews) {
            if([btn.titleLabel.text isEqualToString:self.item]) {
                btn.selected = YES;
                [btn setBackgroundColor:[UIColor hexColor:@"fafafa"]];
                self.selectedItemButton = btn;
                break;
            }
        }
    }else {//选中"不限"按钮
        for (UIButton *btn in _categoryHolderView.subviews) {
            if([btn.titleLabel.text isEqualToString:TITLE_GENDER_NO_LIMIT]) {
                btn.selected = YES;
                [btn setBackgroundColor:[UIColor hexColor:@"fafafa"]];
                self.selectedSexButton = btn;
                break;
            }
        }
    }
    
    //--限制性别
    if(self.gender.length > 0) {
        for (UIButton *btn in _sexHolderView.subviews) {
            if([btn.titleLabel.text isEqualToString:self.gender]) {
                btn.selected = YES;
                [btn setBackgroundColor:[UIColor hexColor:@"fafafa"]];
                self.selectedSexButton = btn;
                break;
            }
        }
    }else {//选中"不限"按钮
        self.allSexButton.selected = YES;
        [self.allSexButton setBackgroundColor:[UIColor hexColor:@"fafafa"]];
        self.selectedSexButton = self.allSexButton;
    }
}

- (IBAction)clickItemButton:(UIButton *)sender {
    
    [self.selectedItemButton setBackgroundColor:[UIColor hexColor:@"ffffff"]];
    self.selectedItemButton.selected = NO;
    sender.selected = YES;
    [sender setBackgroundColor:[UIColor hexColor:@"fafafa"]];
    self.selectedItemButton = sender;
    
}

- (IBAction)clickSexButton:(UIButton *)sender {
    
    [self.selectedSexButton setBackgroundColor:[UIColor hexColor:@"ffffff"]];
    self.selectedSexButton.selected = NO;
    sender.selected = YES;
    [sender setBackgroundColor:[UIColor hexColor:@"fafafa"]];
    self.selectedSexButton = sender;
}

- (void)clickRightTopButton:(id)sender {
    
    NSString *gender = TITLE_GENDER_NO_LIMIT;
    
    if([self.selectedSexButton.titleLabel.text isEqualToString:TITLE_GENDER_NO_LIMIT]) {
        gender = TITLE_GENDER_NO_LIMIT;
    }else if ([self.selectedSexButton.titleLabel.text isEqualToString:TITLE_GENDER_MALE]) {
        gender = TITLE_GENDER_MALE;
    }else if ([self.selectedSexButton.titleLabel.text isEqualToString:TITLE_GENDER_FEMALE]) {
        gender = TITLE_GENDER_FEMALE;
    }
    
    
    [_delegate didSelectedItem:self.selectedItemButton.titleLabel.text gender:gender];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
