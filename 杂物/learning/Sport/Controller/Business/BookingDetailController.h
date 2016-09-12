//
//  BookingDetailController.h
//  Sport
//
//  Created by haodong  on 13-7-18.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BookingDateView.h"
#import "OrderService.h"
#import "BusinessService.h"
#import "UnpaidOrderAlertView.h"

@class Business;

@interface BookingDetailController : SportController<UIScrollViewDelegate, BookingDateViewDelegate, OrderServiceDelegate, BusinessServiceDelegate, UnpaidOrderAlertViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *dateHolderView;
@property (weak, nonatomic) IBOutlet UIView *timeHolderView;
@property (weak, nonatomic) IBOutlet UIView *courtNameHolderView;
@property (weak, nonatomic) IBOutlet UIView *productHolderView;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UILabel *promoteMessageLabel;

@property (weak, nonatomic) IBOutlet UIView *firstExampleView;
@property (weak, nonatomic) IBOutlet UIView *secondExampleView;
@property (weak, nonatomic) IBOutlet UIView *thirdExampleView;

@property (weak, nonatomic) IBOutlet UIView *selectedProductHolderView;
@property (weak, nonatomic) IBOutlet UIView *exampleHolderView;

@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIView *courseTypeHolderView;
@property (weak, nonatomic) IBOutlet UIView *courseTypeBackgroundHolderView;
@property (weak, nonatomic) IBOutlet UIView *moveLineView;

- (id)initWithBusinessId:(NSString *)businessId
              categoryId:(NSString *)categoryId
                    date:(NSDate *)date;

@end
