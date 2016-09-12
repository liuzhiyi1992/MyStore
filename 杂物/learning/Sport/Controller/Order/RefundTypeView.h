//
//  RefundTypeView.h
//  Sport
//
//  Created by haodong  on 15/3/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class RefundWay;

@protocol RefundTypeViewDelegate <NSObject>
@optional
- (void)didSelectRefundTypeView:(RefundWay *)refundWay;
@end

@interface RefundTypeView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (weak, nonatomic) IBOutlet UIImageView *topLineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImageView;

@property (assign, nonatomic) id<RefundTypeViewDelegate> delegate;

+ (RefundTypeView *)createWithRefundWay:(RefundWay *)refundWay index:(NSUInteger)index;

- (void)updateSelectStatus:(BOOL)isSelected;

@end
