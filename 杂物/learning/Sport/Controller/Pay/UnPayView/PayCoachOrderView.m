//
//  PayCoachOrderView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/25.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayCoachOrderView.h"
#import "Order.h"
#import "UIView+Utils.h"
#import "UIView+SportBackground.h"
#import "DateUtil.h"

@interface PayCoachOrderView()

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation PayCoachOrderView


+ (PayCoachOrderView *)createViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayCoachOrderView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    PayCoachOrderView *view = (PayCoachOrderView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view sportUpdateAllBackground];
    view.categoryLabel.text = order.coachCategory;
    view.addressLabel.text = order.coachAddress;
    
    NSString *startTimeString = [DateUtil stringFromDate:order.coachStartTime DateFormat:[NSString stringWithFormat:@"yyyy年M月d日(%@)HH:mm-",[DateUtil ChineseWeek2:order.coachStartTime]]];
    view.timeLabel.text = [startTimeString stringByAppendingString:[DateUtil stringFromDate:order.coachEndTime DateFormat:@"HH:mm"]];
    
    return view;
}

@end
