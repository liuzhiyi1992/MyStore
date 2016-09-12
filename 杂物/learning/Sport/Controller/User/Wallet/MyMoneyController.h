//
//  MyMoneyController.h
//  Sport
//
//  Created by haodong  on 15/3/21.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"

enum {
    TypeMoney = 0,
    TypePoint = 1
} MyMoneyControllerType;


@interface MyMoneyController : SportController

@property (weak, nonatomic) IBOutlet UIView *topHolderView;

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIView *inputHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *inputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *rechargeButton;
@property (weak, nonatomic) IBOutlet UITextField *rechargeTextField;
@property (weak, nonatomic) IBOutlet UIButton *goToShopButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHolderViewTopToSuperConstraint;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *verticalSpaceConstraint;


- (instancetype)initWithMoney:(float)money;

- (instancetype)initWithPoint:(int)point;

- (instancetype)initWithType:(int)myMoneyControllerType;
@end
