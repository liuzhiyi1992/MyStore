//
//  CallBookController.h
//  Sport
//
//  Created by haodong  on 14-4-26.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BusinessService.h"

@class Business;

@interface CallBookController : SportController<BusinessServiceDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *orderTopBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *businessAddressTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *summitButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIImageView *nameBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImageView;

@property (weak, nonatomic) IBOutlet UIView *timeHolderView;
@property (weak, nonatomic) IBOutlet UIView *nameHolderView;

@property (weak, nonatomic) IBOutlet UIButton *mrButton;
@property (weak, nonatomic) IBOutlet UIButton *msButton;
@property (weak, nonatomic) IBOutlet UIView *moveLineView;

@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

- (instancetype)initWithBusiness:(Business *)business
              selectedCategoryId:(NSString *)selectedCategoryId
                       startTime:(NSDate *)startTime
                        duration:(int)duration;

@end
