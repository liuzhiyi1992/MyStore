//
//  ConvertPointGoodsController.h
//  Sport
//
//  Created by haodong  on 14/11/21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PointService.h"

@class PointGoods;

@interface ConvertPointGoodsController : SportController <PointServiceDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIImageView *phoneBackgroundImageView;

- (instancetype)initWithPointGoods:(PointGoods *)pointGoods
                            drawId:(NSString *)drawId;

@end
