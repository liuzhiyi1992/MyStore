//
//  PaySingleOrderView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PaySingleOrderView.h"
#import "UIView+SportBackground.h"
#import "UIView+Utils.h"

@interface PaySingleOrderView()
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation PaySingleOrderView

+ (PaySingleOrderView *)createViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PaySingleOrderView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    PaySingleOrderView *view = (PaySingleOrderView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view sportUpdateAllBackground];
    view.categoryLabel.text = order.categoryName;
    view.businessNameLabel.text = order.businessName;
    view.goodsNameLabel.text = order.goodsName;
    view.countLabel.text  = [NSString stringWithFormat:@"%d", order.count];
    return view;
}

@end
