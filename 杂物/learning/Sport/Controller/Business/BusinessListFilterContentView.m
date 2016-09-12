//
//  BusinessListFilterContentView.m
//  Sport
//
//  Created by qiuhaodong on 16/8/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessListFilterContentView.h"
#import "UIView+CreateViewFromXib.h"
#import "UIView+Utils.h"
#import "DropDownDataManager.h"

@interface BusinessListFilterContentView()
@property (weak, nonatomic) IBOutlet UIScrollView *buttonsHolderView;
@property (weak, nonatomic) IBOutlet UIControl *backgroundControl;

@property (weak, nonatomic) NSLayoutConstraint *superViewHeightConstraint;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *selectedId;
@property (assign, nonatomic) PullDownType pullDownType;
@property (copy, nonatomic) void (^finishHandler)(NSString *selectedId);
@property (copy, nonatomic) void (^dismissHandler)();

@property (strong, nonatomic) NSArray *dataList;

@end

@implementation BusinessListFilterContentView

#define HEIGHT_HEAD 45.0

+ (BusinessListFilterContentView *)showInSuperView:(UIView *)superView
                                      belowSubview:(UIView *)belowSubview
                         superViewHeightConstraint:(NSLayoutConstraint *)superViewHeightConstraint
                                        categoryId:(NSString *)categoryId
                                      pullDownType:(PullDownType)pullDownType
                                        selectedId:(NSString *)selectedId
                                     finishHandler:(void (^)(NSString *selectedId))finishHandler
                                    dismissHandler:(void (^)())dismissHandler {
    for (UIView *one in superView.subviews) {
        if ([one isKindOfClass:[BusinessListFilterContentView class]]) {
            [(BusinessListFilterContentView *)one privateDismiss];
        }
    }
    
    BusinessListFilterContentView *view = [self createXibView:@"BusinessListFilterContentView"];
    [superView insertSubview:view belowSubview:belowSubview];
    view.superViewHeightConstraint = superViewHeightConstraint;
    view.categoryId = categoryId;
    view.selectedId = selectedId;
    view.pullDownType = pullDownType;
    view.finishHandler = finishHandler;
    view.dismissHandler = dismissHandler;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    [view updateWidth:size.width];
    [view updateHeight:size.height];
    [view updateOriginY:HEIGHT_HEAD];
    
    [view addAllButtons];
    
    [view showAnimation];
    
    return view;
}

- (void)showAnimation {
    [self.buttonsHolderView updateOriginY: - self.buttonsHolderView.frame.size.height];
    self.backgroundControl.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.buttonsHolderView updateOriginY:0];
        self.backgroundControl.alpha = 1;
    } completion:^(BOOL finished) {
        self.superViewHeightConstraint.constant = self.frame.size.height;
    }];
}

- (IBAction)touchDownBackground:(id)sender {
    [self dismiss];
}

- (void)dismiss {
    if (self.dismissHandler) {
        self.dismissHandler();
    }
    
    [self privateDismiss];
}

- (void)privateDismiss {
    self.finishHandler = nil;
    self.dismissHandler = nil;
    self.superViewHeightConstraint.constant = HEIGHT_HEAD;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundControl.alpha = 0;
        [self.buttonsHolderView updateOriginY: - self.buttonsHolderView.frame.size.height];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#define WIDTH_BUTTON 65
#define HEIGHT_BUTTON 25
#define COUNT_ONE_LINE 4

- (void)addAllButtons {
    //读取数据
    NSArray *dataList = nil;
    DropDownDataManager *dataManager = [DropDownDataManager defaultManager];
    if (self.pullDownType == PullDownTypeCategory) {
        dataList = [dataManager categoryDropDownDataList];
    } else if (self.pullDownType == PullDownTypeRegion) {
        dataList = [dataManager regionDropDownDataList];
    } else if (self.pullDownType == PullDownFilter) {
        dataList = [dataManager filterDropDownDataListWithCategoryId:self.categoryId];
    } else if (self.pullDownType == PullDownTypeSort) {
        dataList = [dataManager sortDropDownDataList];
    }
    self.dataList = dataList;
    
    float space = ([UIScreen mainScreen].bounds.size.width - WIDTH_BUTTON * COUNT_ONE_LINE) / (COUNT_ONE_LINE + 1);
    float spaceY = 16;
    NSUInteger index = 0;
    
    CGFloat x = 0, y = 0;
    for (DropDownData *data in self.dataList) {
        UIButton *button = [self createOneButtonWithTitle:data.value];
        button.tag = index;
        x = space + (index % COUNT_ONE_LINE) * (space + WIDTH_BUTTON);
        y = spaceY + (index / COUNT_ONE_LINE) * (spaceY + HEIGHT_BUTTON);
        [button updateOriginX:x];
        [button updateOriginY:y];
        if ([self.selectedId isEqualToString:data.idString]) {
            button.selected = YES;
        }
        [self.buttonsHolderView addSubview:button];
        index ++;
    }
    CGFloat contentHeight = y + HEIGHT_BUTTON + spaceY;
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - 64 - 90;
    
    [self.buttonsHolderView updateHeight:MIN(contentHeight, maxHeight)];
    self.buttonsHolderView.contentSize = CGSizeMake(self.buttonsHolderView.frame.size.width, contentHeight);
}

- (UIButton *)createOneButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH_BUTTON, HEIGHT_BUTTON)];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[SportColor titleColor] forState:UIControlStateNormal];
    [button setTitleColor:[SportColor defaultBlueColor] forState:UIControlStateSelected];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setBackgroundImage:[SportImage grayBorderButtonImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[SportImage blueBorderButtonImage] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)clickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSUInteger index = button.tag;
    DropDownData *data = [self.dataList objectAtIndex:index];
    if (self.finishHandler) {
        self.finishHandler(data.idString);
    }
    [self dismiss];
}

@end
