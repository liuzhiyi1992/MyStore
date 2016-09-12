//
//  PayDelayView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayDelayView.h"
#import "PayDelayDefaultOrderView.h"
#import "UIView+Utils.h"
#import "UIUtils.h"
#import "SportPopupView.h"

@interface PayDelayView()



//@property (weak, nonatomic) IBOutlet UIView *orderHolderView;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
- (IBAction)call:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *keWuLabel;
@property (weak, nonatomic) IBOutlet UIButton *phone;

@end

@implementation PayDelayView


+ (PayDelayView *)createViewWithOrder:(Order *)order
                             delegate:(id<PayDelayViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayDelayView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    PayDelayView *view = (PayDelayView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
   view.delegate = delegate;

    view.frame=[UIScreen mainScreen].bounds;
    
    
    view.phone.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height-110, [UIScreen mainScreen].bounds.size.width, 22);
    
    
    
    view.phone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    
    view.phone.titleLabel.textAlignment =NSTextAlignmentCenter;
    view.keWuLabel.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height-126, [UIScreen mainScreen].bounds.size.width, 20);
    
   
    
    [view.keWuLabel setTextAlignment:NSTextAlignmentCenter];
    return view;
}

- (IBAction)clickRefreshButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPayDelayViewRefreshButton)]) {
        [_delegate didClickPayDelayViewRefreshButton];
    }
}



- (IBAction)call:(id)sender {
    BOOL result = [UIUtils makePromptCall:@"4000410480"];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }

}
@end
