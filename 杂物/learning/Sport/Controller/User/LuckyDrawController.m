//
//  LuckyDrawController.m
//  Sport
//
//  Created by haodong  on 14/11/17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "LuckyDrawController.h"
#import "UIView+Utils.h"
#import "User.h"
#import "UserManager.h"
#import "PointGoods.h"
#import "SportProgressView.h"
#import "SportWebController.h"
#import "DrawRecordController.h"
#import "ConvertPointGoodsController.h"
#import "BaseConfigManager.h"
#import "SportPopupView.h"

@interface LuckyDrawController ()
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isLoadSuccess;
@property (copy, nonatomic) NSString *errorMessage;
@property (assign, nonatomic) BOOL isAround;

@property (strong, nonatomic) NSArray *itemList;
@property (assign, nonatomic) int onceUsePoint;

@property (copy, nonatomic) NSString *resultGoodsId;
@property (copy, nonatomic) NSString *resultDrawId;

@property (strong, nonatomic) NSArray *newsList;

@property (copy, nonatomic) NSString *drawRuleUrl;

@end

@implementation LuckyDrawController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抽奖";
    
    [self initBaseUI];
    
    [self updateMyPoint];
    
    self.mainScrollView.hidden = YES;
    [self.activityIndicatorView startAnimating];
    [self queryData];
    
    [self queryNews];
    
    [MobClickUtils event:umeng_event_enter_lucky_draw];
}

#define COUNT_ALL_ITEM 12
#define TAG_BUTTON_BASE 200
#define TAG_LABLE_BASE 300
- (void)initBaseUI
{
    [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height+10)];
    
    for (UIView *subView in self.drawHolderView.subviews) {
        if ([subView isKindOfClass:[UILabel class]] && subView.tag >= TAG_LABLE_BASE && subView.tag < TAG_LABLE_BASE + COUNT_ALL_ITEM) {
            [(UILabel *)subView setText:@""];
        }
    }
    
    [self.recordButton setBackgroundImage:[SportImage drawOrangeButtonImage] forState:UIControlStateNormal];
    [self.helpButton setBackgroundImage:[SportImage drawOrangeButtonImage] forState:UIControlStateNormal];
}

- (void)updateMyPoint
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    self.myPointLabel.text = [NSString stringWithFormat:@"%d", user.point];
    
    if (_onceUsePoint <= 0) {
        self.onceUsePoint = 10;
    }
    self.tipsLabel.text = [NSString stringWithFormat:@"每次抽奖将消耗%d个积分，获得的奖品可点击中奖记录进行查看。", _onceUsePoint];
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中..."];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [PointService queryPointGoodsList:self userId:user.userId type:@"1"];
}

- (void)didQueryPointGoodsList:(NSArray *)list
                        status:(NSString *)status
                           msg:(NSString *)msg
                       myPoint:(int)myPoint
                      onceUsePoint:(int)onceUsePoint
                  pointRuleUrl:(NSString *)pointRuleUrl
                   drawRuleUrl:(NSString *)drawRuleUrl
{
    [self.activityIndicatorView stopAnimating];
    self.mainScrollView.hidden = NO;
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.itemList = list;
        self.onceUsePoint = onceUsePoint;
        
        self.drawRuleUrl = drawRuleUrl;
        
        [self updateItems];
        [self updateMyPoint];
    }
    
    //无数据时的提示
    if ([list count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有抽奖数据了"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (void)updateItems
{
    int index = 0;
    for (PointGoods *goods in _itemList) {
        UILabel *label = (UILabel *)[self.drawHolderView viewWithTag:TAG_LABLE_BASE + index];
        label.text = goods.title;
        index ++;
    }
}

#define TAG_ALERT_VIEW_POINT_NOT_ENOUGH 2014121501
- (IBAction)clickDrawButton:(id)sender {
    
    [MobClickUtils event:umeng_event_click_draw_button];
    
    if (_isAround == NO) {
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        if (user.point < _onceUsePoint) {
            NSString *message = @"您的积分不足";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"如何获取积分",nil];
            alertView.tag = TAG_ALERT_VIEW_POINT_NOT_ENOUGH;
            [alertView show];
            return;
        }
        
        self.isAround = YES;
        
        [self clearItems];
        
        [self showLoading];
        [self luckyDraw];
    }
}

- (void)luckyDraw
{
    self.isLoading = YES;
    User *user = [[UserManager defaultManager] readCurrentUser];
    [PointService luckyDraw:self userId:user.userId];
}

- (void)didLuckyDraw:(NSString *)status
                 msg:(NSString *)msg
              drawId:(NSString *)drawId
             goodsId:(NSString *)goodsId
               point:(int)point
{
    self.isLoading = NO;
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.isLoadSuccess = YES;
        self.resultGoodsId = goodsId;
        self.resultDrawId = drawId;
        
    } else {
        self.isLoadSuccess = NO;
        self.errorMessage = msg;
    }
}

- (void)showLoading
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int i = 0;
        while (YES) {
            int yu = i % 12;
            if (_isLoading == NO && yu == 0 ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (_isLoadSuccess) {
                        int index = [self findResultIndexWithResultGoodsId:_resultGoodsId];
                        [self showResult:index];
                    } else {//网络请求失败
                        self.isAround = NO;
                        [self clearItems];
                        [SportPopupView popupWithMessage:self.errorMessage];
                    }
                });
                break;
                
            } else {
                if (yu == 0) {
                    i = 0;
                }
                
                [NSThread sleepForTimeInterval:0.08];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self changeItemImage:i];
                });
                
                i ++;
            }
        }
    });
}

- (int)findResultIndexWithResultGoodsId:(NSString *)goodsId
{
    int index = 0;
    for (PointGoods *goods in _itemList) {
        if ([goods.goodsId isEqualToString:goodsId]) {
            return index;
        }
        index ++;
    }
    
    return -1;
}

- (void)showResult:(int)resultIndex
{
    if (resultIndex < 0) {
        [self clearItems];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int allCount = 2 * COUNT_ALL_ITEM + resultIndex + 1;
        
        for (int i = 0 ; i < allCount ; i ++) {
            
            if (i > allCount - 12) {
                [NSThread sleepForTimeInterval:0.08 + (i - (allCount - 12)) * 0.06];
            } else {
                [NSThread sleepForTimeInterval:0.08];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int index = i % COUNT_ALL_ITEM;
                [self changeItemImage:index];
                
                if (i == allCount - 1) {
                    [self showResultAlert];
                    [self updateMyPoint];
                    self.isAround = NO;
                }
                
            });
            
        }
    });
}

#define TAG_SHOW_DRAW_RESULT    2014112201
- (void)showResultAlert
{
    PointGoods *resultGoods = nil;
    for (PointGoods *goods in _itemList) {
        if ([_resultGoodsId isEqualToString:goods.goodsId]) {
            resultGoods = goods;
        }
    }
    
    if (resultGoods.type == PointGoodsTypePhysical) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:resultGoods.subTitle delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"马上领奖", nil];
        alertView.tag = TAG_SHOW_DRAW_RESULT;
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:resultGoods.subTitle delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_SHOW_DRAW_RESULT) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            
            PointGoods *resultGoods = nil;
            for (PointGoods *goods in _itemList) {
                if ([_resultGoodsId isEqualToString:goods.goodsId]) {
                    resultGoods = goods;
                }
            }
            
            if (resultGoods.type == PointGoodsTypePhysical) {
                ConvertPointGoodsController *controller = [[ConvertPointGoodsController alloc] initWithPointGoods:resultGoods drawId:_resultDrawId] ;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    } else if (alertView.tag == TAG_ALERT_VIEW_POINT_NOT_ENOUGH) {
         if (alertView.cancelButtonIndex != buttonIndex) {
             
             NSString *opintRuleUrl = [[BaseConfigManager defaultManager] creditRuleUrl];
             
             SportWebController *controller = [[SportWebController alloc] initWithUrlString:opintRuleUrl title:@"积分规则"];
             [self.navigationController pushViewController:controller animated:YES];
         }
    }
}

- (void)changeItemImage:(int)currentIndex
{
    int lastIndex = 0;
    if (currentIndex == 0) {
        lastIndex = 11;
    } else {
        lastIndex = currentIndex - 1;
    }
    
    [(UIButton *)[self.drawHolderView viewWithTag:TAG_BUTTON_BASE + lastIndex] setSelected:NO];
    [(UIButton *)[self.drawHolderView viewWithTag:TAG_BUTTON_BASE + currentIndex] setSelected:YES];
}

- (void)clearItems
{
    for (int i = 0 ; i < 12; i ++) {
        [(UIButton *)[self.drawHolderView viewWithTag:TAG_BUTTON_BASE + i] setSelected:NO];
    }
}

//中奖新闻
- (void)queryNews
{
    [PointService queryDrawNewsList:self];
}

- (void)didQueryDrawNewsList:(NSArray *)newsList status:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.newsList = newsList;
        
        [self showAllNews];
    }
}

- (void)showAllNews
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int i = 0;
        
        while (YES) {
            [NSThread sleepForTimeInterval:3.2];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for (int k = 0 ; k < 5; k ++) {
                    UILabel *label = (UILabel *)[self.drawNewsHolderView viewWithTag:10 + k];
                    
                    NSString *text = nil;
                    if ([_newsList count] > i + k) {
                        text = [_newsList objectAtIndex:i + k];
                    } else {
                        text = @"";
                    }
                    label.text = text;
                }
                
                [self.drawNewsHolderView updateOriginX:[UIScreen mainScreen].bounds.size.width];
                [UIView animateWithDuration:0.6 animations:^{
                    [self.drawNewsHolderView updateOriginX:53];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.4 delay:2.2 options:UIViewAnimationOptionLayoutSubviews animations:^{
                        [self.drawNewsHolderView updateOriginX:0 - self.drawNewsHolderView.frame.size.width];
                    } completion:^(BOOL finished) {
                    }];
                }];
            });
            
            i += 5;
            if (i == 20) {
                i = 0;
            }
        }
        
    });
}

- (IBAction)clickItemButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag - TAG_BUTTON_BASE;
    
    if ([_itemList count] > 0) {
        PointGoods *goods = [_itemList objectAtIndex:index];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:goods.desc delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)clickHelpButton:(id)sender {
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:_drawRuleUrl title:@"抽奖规则"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickRecordButton:(id)sender {
    DrawRecordController *controller = [[DrawRecordController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
