//
//  WebPayController.h
//  Sport
//
//  Created by haodong  on 15/4/1.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportWebController.h"

@protocol WebPayControllerrDelegate <NSObject>

@optional
- (void)didClickWebPayControllerBackButton:(BOOL)isFinishPay;
@end


@interface WebPayController : SportWebController

@property (assign, nonatomic) id<WebPayControllerrDelegate> delegate;

@end
