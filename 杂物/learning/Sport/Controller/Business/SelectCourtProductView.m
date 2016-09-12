//
//  SelectCourtProductView.m
//  Sport
//
//  Created by qiuhaodong on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SelectCourtProductView.h"
#import "ProductView.h"
#import "Court.h"
#import "DayBookingInfo.h"
#import "UIView+Utils.h"
#import "Product.h"
#import "NSDate+Utils.h"

@interface SelectCourtProductView()<ProductViewDelegate>
@property (strong, nonatomic) NSMutableArray *allProductViews;
@property (strong, nonatomic) DayBookingInfo *dayBookingInfo;
@property (strong, nonatomic) NSArray *timeList;
@property (assign, nonatomic) CGFloat singleSpace;
@property (assign, nonatomic) BOOL isCardUser;
@property (assign, nonatomic) id<SelectCourtProductViewDelegate> clickProductDelegate;
@end

@implementation SelectCourtProductView

+ (UIColor *)canOrderColor {
    return COLOR_CAN_ORDER;
}

+ (UIColor *)orderedColor {
    return COLOR_ORDERED;
}

+ (UIColor *)myOrderColor {
    return COLOR_MY_ORDER;
}

+ (CGSize)oneProductViewSize {
    return [ProductView defaultSize];
}

#define SELECT_COURT_PRODUCT_VIEW_TAG 2016061402
+ (instancetype)showViewInSuperView:(UIView *)superView
                     dayBookingInfo:(DayBookingInfo *)dayBookingInfo
                           timeList:(NSArray *)timeList
                        singleSpace:(CGFloat)singleSpace
                         isCardUser:(BOOL)isCardUser
               clickProductDelegate:(id<SelectCourtProductViewDelegate>)clickProductDelegate
{
    SelectCourtProductView *view = [superView viewWithTag:SELECT_COURT_PRODUCT_VIEW_TAG];
    if (!view) {
        view = [[SelectCourtProductView alloc] initWithFrame:superView.bounds];
        view.showsHorizontalScrollIndicator = NO;
        view.tag = SELECT_COURT_PRODUCT_VIEW_TAG;
        [superView addSubview:view];
    }
    
    view.dayBookingInfo = dayBookingInfo;
    view.timeList = timeList;
    view.singleSpace = singleSpace;
    view.isCardUser = isCardUser;
    view.clickProductDelegate = clickProductDelegate;
    
    [view update];
    
    return view;
}

- (void)autoScrollToCurrentTime:(NSDate *)selectedDate
{
    //找出最早可预定的球局ProductView
    ProductView *earliestView = nil;
    for (ProductView *productView in self.allProductViews) {
        Product *product = productView.product;
        if ([product isCourtJoinProduct] && [product canBuy]) {
            if (earliestView == nil) {
                earliestView = productView;
            } else if (earliestView.product.startTimeHour > product.startTimeHour){
                earliestView = productView;
            }
        }
    }
    
    //如果找到,尽可能滑到使earliestView居中
    if (earliestView) {
        CGFloat offsetX = earliestView.frame.origin.x - (0.5 * self.frame.size.width);
        CGFloat offsetY = earliestView.frame.origin.y - (0.5 * self.frame.size.height);
        
        //防止出现滑动过大
        offsetX = MIN(self.contentSize.width - self.frame.size.width, offsetX);
        offsetY = MIN(self.contentSize.height - self.frame.size.height, offsetY);
        
        //防止出现负数
        offsetX = MAX(0, offsetX);
        offsetY = MAX(0, offsetY);
        
        [self setContentOffset:CGPointMake(offsetX, offsetY)];
    }
    
    //如果找不到，进行当天滑动到当前时间的处理
    else {
        if([selectedDate isToday]){
            NSInteger hour = [[NSDate date] hour];
            CGFloat contentOffsetOfCurrentTime = 0;
            
            for(int i =0; i<[self.timeList count] ; i++){
                
                NSString *timeForIndex = [self.timeList objectAtIndex:i];
                NSArray *component=[timeForIndex componentsSeparatedByString:@":"];
                if([component count]>=2){
                    NSString *firstComponent = [component objectAtIndex:0];
                    NSInteger intValueForFirstComponent =[firstComponent intValue];
                    if (hour == intValueForFirstComponent) {
                        contentOffsetOfCurrentTime  = self.singleSpace + (self.singleSpace + [ProductView defaultSize].height) * (i+1);
                        break;
                    }
                }
            }
            
            CGFloat contentOffsetToMax =self.contentSize.height-self.frame.size.height;
            
            //防止营业时间不够多导致向下偏移
            contentOffsetToMax = (contentOffsetToMax < 0 ? 0 : contentOffsetToMax);
            
            [self setContentOffset:CGPointMake(0, MIN(contentOffsetOfCurrentTime, contentOffsetToMax))];
        }
    }
    
    
}

- (ProductView *)productViewFromProductId:(NSString *)productId
{
    for (ProductView *view in self.allProductViews) {
        if ([view.product.productId isEqualToString:productId]) {
            return view;
        }
    }
    return nil;
}

- (void)selectedWithProductId:(NSString *)productId animated:(BOOL)animated
{
    ProductView *view = [self productViewFromProductId:productId];
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [view updateColor:YES];
        }];
    } else {
        [view updateColor:YES];
    }
}

- (void)disSelectedWithProductId:(NSString *)productId
{
    ProductView *view = [self productViewFromProductId:productId];
    [view updateColor:NO];
}

#pragma mark - 私有方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.allProductViews = [NSMutableArray array];
    }
    return self;
}

- (void)update
{
    NSArray *subViewList = [self subviews];
    for (UIView *subView in subViewList) {
        if ([subView isKindOfClass:[ProductView class]]) {
            ProductView *view = (ProductView *)subView;
            [view updateView:nil showPrice:NO];
            [view removeFromSuperview];
        }
    }
    
    int productIndex = 0;
    int courtIndex = 0;
    int hourIndex;
    CGFloat x = 0;
    CGFloat y = 0;
    for (Court *court in self.dayBookingInfo.courtList) {
        hourIndex = 0;
        for (NSString *time in self.timeList) {
            x = self.singleSpace + (self.singleSpace + [ProductView defaultSize].width) * courtIndex;
            y = self.singleSpace + (self.singleSpace + [ProductView defaultSize].height) * hourIndex;
            hourIndex ++;
            
            ProductView *view = nil;
            if ([_allProductViews count] > productIndex) {
                view = (ProductView *)[self.allProductViews objectAtIndex:productIndex];
            } else {
                view = [ProductView createProductView];
                [self.allProductViews addObject:view];
            }
            productIndex ++;
            
            view.delegate = self;
            Product *product  = [self findProductWithDayBookingInfo:self.dayBookingInfo courtId:court.courtId time:time];
            if (product == nil) {
                view.hidden = YES;
            } else {
                view.hidden = NO;
                
                //v1.97 会员不显示价钱
                BOOL showPrice = (self.isCardUser == NO);
                [view updateView:product showPrice:showPrice];
                [view updateOriginX:x];
                [view updateOriginY:y];
                [self addSubview:view];
            }
        }
        courtIndex ++;
    }
    self.contentSize = CGSizeMake(x + [ProductView defaultSize].width + self.singleSpace, y + [ProductView defaultSize].height + self.singleSpace);
}

- (Product *)findProductWithDayBookingInfo:(DayBookingInfo *)dayBookingInfo
                                   courtId:(NSString *)courtId
                                      time:(NSString *)time
{
    if (dayBookingInfo == nil){
        return nil;
    }
    Court *court = nil;
    for (Court *tmp in dayBookingInfo.courtList) {
        if ([tmp.courtId isEqualToString:courtId]) {
            court = tmp;
        }
    }
    if (court == nil) {
        return nil;
    }
    for (Product *tmp in court.productList) {
        if ([tmp.startTime isEqualToString:time]) {
            return tmp;
        }
    }
    return nil;
}

#pragma mark - ProductViewDelegate
- (void)didClickProductView:(Product *)product productView:(ProductView *)productView
{
    if ([self.clickProductDelegate respondsToSelector:@selector(didClickProduct:)]) {
        [self.clickProductDelegate didClickProduct:product];
    }
}

@end
