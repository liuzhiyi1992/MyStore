//
//  PointGoodsDetailController.h
//  Sport
//
//  Created by haodong  on 14/11/13.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PointService.h"

@class PointGoods;

@interface PointGoodsDetailController : SportController<UIAlertViewDelegate, PointServiceDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalPointLabel;
@property (weak, nonatomic) IBOutlet UIView *originalPointLineView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *originalPointHolderView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;


- (instancetype)initWithPointGoods:(PointGoods *)pointGoods;

@end
