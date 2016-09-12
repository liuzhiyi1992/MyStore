//
//  NSObject+TabTitleButton.h
//  Sport
//
//  Created by 江彦聪 on 15/6/6.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (TabTitleButton)
@property (nonatomic, strong) UIButton *leftTitleButton;
@property (nonatomic, strong) UIButton *rightTitleButton;
@property (strong, nonatomic) UILabel *titleLabel;
@end
