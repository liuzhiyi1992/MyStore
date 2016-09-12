//
//  SelectedProductView.h
//  Sport
//
//  Created by haodong  on 15/1/27.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;

@interface SelectedProductView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *courtNameLabel;

+ (SelectedProductView *)createSelectedProductView;

+ (CGSize)defaultSize;

- (void)updateViewWithValue1:(NSString *)value1 value2:(NSString *)value2;

@end
