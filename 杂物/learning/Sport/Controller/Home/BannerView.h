//
//  BannerView.h
//  Sport
//
//  Created by xiaoyang on 16/5/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportLazyScrollView.h"
#import "MainControllerCategory.h"
@class SportAd;

@protocol BannerViewDelegate <NSObject>
@optional

-(void)didCLickBannerViewBanner:(SportAd *)banner;
- (void)didClickCategaryButton:(NSString *)categoryName categoryId:(NSString *)categoryId;
- (void)defaultCategorySelect:(NSString *)categoryName currentCategoryIsDefaultSelect:(BOOL)currentCategoryIsDefaultSelect defaultCategoryId:(NSString *)defaultCategoryId;
@end

@interface BannerView : UIView<SportLazyScrollViewDelegate>
@property (assign, nonatomic) id<BannerViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *categaryHolderView;
@property (weak, nonatomic) IBOutlet UIButton *firstCategaryButton;
@property (weak, nonatomic) IBOutlet UIButton *secondCategaryButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdCategaryButton;
@property (weak, nonatomic) IBOutlet UIButton *fourCategaryButton;
@property (weak, nonatomic) IBOutlet UIButton *fiveCategaryButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BottomImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categaryHolderViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categaryRelateSuperViewLeftConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *categaryBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *categaryBottomImageView;
+ (BannerView *)createBannerViewWithDelegate:(id<BannerViewDelegate>)delegate
                            fatherHolderView:(UIView *)fatherHolderView;

- (void)updateViewWithBannerList:(NSArray *)bannerList
                    mainControllerCategory:(MainControllerCategory*)mainControllerCategory;

-(void)pauseTimer;
-(void)resumeTimer;

@end
