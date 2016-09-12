//
//  PayDefaultOrderView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayDefaultOrderView.h"
#import "DateUtil.h"
#import "ProductDetailGroupView.h"
#import "UIView+Utils.h"
#import "UIView+SportBackground.h"

@interface PayDefaultOrderView()
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@end

@implementation PayDefaultOrderView


+ (PayDefaultOrderView *)createViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayDefaultOrderView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    PayDefaultOrderView *view = (PayDefaultOrderView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view sportUpdateAllBackground];
    
    //分类，球馆名，日期
    view.businessNameLabel.text = order.businessName;
    view.categoryLabel.text = order.categoryName;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:order.useDate];
    NSString *weekString = [DateUtil ChineseWeek2:order.useDate];
    view.dateLabel.text = [NSString stringWithFormat:@"%@ (%@)", weekString, dateString];
    
    //详细场次
    ProductDetailGroupView *detailView = [ProductDetailGroupView createProductDetailGroupView];
    BOOL showPrice = (order.type != OrderTypeMembershipCard);
    [detailView updateViewWithOrder:order showPrice:showPrice];
    [detailView updateOriginX:0];
    [detailView updateOriginY:86];
    [view addSubview:detailView];
    [view updateHeight:detailView.frame.origin.y + detailView.frame.size.height];
    return view;
}

@end
