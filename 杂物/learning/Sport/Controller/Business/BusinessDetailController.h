//
//  BusinessDetailController.h
//  Sport
//
//  Created by haodong  on 14-8-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BusinessService.h"
#import "BookingSimpleView.h"
#import <MessageUI/MessageUI.h>
#import "SNSService.h"
#import "QQManager.h"
#import "ReviewCell.h"
#import "SingleGoodsView.h"
#import "ServiceCell.h"
#import "ForumService.h"
#import "FacilityView.h"
#import "ServiceView.h"
#import "CategoryButtonListView.h"
#import "SportStartAndEndTimePickerView.h"

@interface BusinessDetailController : SportController<BusinessServiceDelegate, BookingSimpleViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, SNSServiceDelegate, QQManagerDelegate, ReviewCellDelegate, SingleGoodsViewDelegate, ForumServiceDelegate, CategoryButtonListViewDelegate, SportStartAndEndTimePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UIView *baseHolderView;
@property (weak, nonatomic) IBOutlet UIView *categoryHolderView;
@property (weak, nonatomic) IBOutlet UIView *singleHolderView;
@property (weak, nonatomic) IBOutlet UIView *bookInfoHolderView;
@property (weak, nonatomic) IBOutlet UIView *callBookHolderView;
@property (weak, nonatomic) IBOutlet UIView *loadingHolderView;

@property (weak, nonatomic) IBOutlet UIView *serviceHolderView;

@property (weak, nonatomic) IBOutlet UIView *commentHolderView;
@property (weak, nonatomic) IBOutlet UIView *nearbyVenuesHolderView;

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;

@property (weak, nonatomic) IBOutlet UIView *ratingHolderView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *bookInfoScrollView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bookInfoActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *loadingTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloadBookingButton;

@property (weak, nonatomic) IBOutlet UIButton *callBookTimeButton;
@property (weak, nonatomic) IBOutlet UILabel *callBookPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *callBookButton;

@property (weak, nonatomic) IBOutlet UIView *commentBottomHolderView;
@property (weak, nonatomic) IBOutlet UILabel *allCommentsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *allCommentsButton;

@property (weak, nonatomic) IBOutlet UIView *forumEntranceHolderView;
@property (strong, nonatomic) IBOutlet UIView *baseRefundView;
@property (strong, nonatomic) IBOutlet UILabel *refundTipsLabel;
@property (strong, nonatomic) IBOutlet UIView *imageCountView;
@property (strong, nonatomic) IBOutlet UILabel *imageCountLabel;

- (id)initWithBusinessId:(NSString *)businessId
              categoryId:(NSString *)categoryId;

- (id)initWithBusiness:(Business *)business
            categoryId:(NSString *)categoryId;

@end
