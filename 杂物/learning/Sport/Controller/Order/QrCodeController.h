//
//  QrCodeController.h
//  Sport
//
//  Created by haodong  on 15/3/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"

@class Order;

@interface QrCodeController : SportController

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

- (instancetype)initWithOrder:(Order *)order;

@end
