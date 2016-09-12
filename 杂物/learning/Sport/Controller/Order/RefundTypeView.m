//
//  RefundTypeView.m
//  Sport
//
//  Created by haodong  on 15/3/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "RefundTypeView.h"
#import "RefundWay.h"

@interface RefundTypeView()
@property (strong, nonatomic) RefundWay *refundWay;
@property (assign, nonatomic) NSUInteger index;
@end

@implementation RefundTypeView


+ (RefundTypeView *)createWithRefundWay:(RefundWay *)refundWay
                                  index:(NSUInteger)index
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RefundTypeView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    RefundTypeView *view = [topLevelObjects objectAtIndex:0];
    
    view.refundWay = refundWay;
    view.index = index;
    
    view.titleLabel.text = refundWay.title;
    view.subtitleLabel.text = refundWay.subTitle;
    
    if (index == 0) {
        [view.topLineImageView setImage:[SportImage lineImage]];
        [view.bottomLineImageView setImage:[SportImage lineImage]];
    } else {
        [view.bottomLineImageView setImage:[SportImage lineImage]];
    }
    
    [view updateSelectStatus:NO];
    
    return view;
}

- (void)updateSelectStatus:(BOOL)isSelected
{
    if (isSelected) {
        [self.rightImageView setImage:[SportImage radioButtonSelectedImage]];
    } else {
        [self.rightImageView setImage:[SportImage radioButtonUnselectedImage]];
    }
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didSelectRefundTypeView:)]) {
        [_delegate didSelectRefundTypeView:_refundWay];
    }
}

@end
