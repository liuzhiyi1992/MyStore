//
//  PayDelayDefaultOrderView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayDelayDefaultOrderView.h"
#import "UIView+SportBackground.h"
#import "UIView+Utils.h"

@interface PayDelayDefaultOrderView()
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;

@end

@implementation PayDelayDefaultOrderView


+ (PayDelayDefaultOrderView *)createViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayDelayDefaultOrderView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    PayDelayDefaultOrderView *view = (PayDelayDefaultOrderView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    view.businessNameLabel.text = order.businessName;
    view.orderNumberLabel.text = order.orderNumber;
    return view;
}

@end
