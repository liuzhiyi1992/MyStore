//
//  LuckyDrawController.h
//  Sport
//
//  Created by haodong  on 14/11/17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PointService.h"

@interface LuckyDrawController : SportController<PointServiceDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UIView *drawHolderView;
@property (weak, nonatomic) IBOutlet UILabel *myPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIView *drawNewsHolderView;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
