//
//  PayHelpController.h
//  Sport
//
//  Created by haodong  on 14-6-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"

@interface PayHelpController : SportController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@end
