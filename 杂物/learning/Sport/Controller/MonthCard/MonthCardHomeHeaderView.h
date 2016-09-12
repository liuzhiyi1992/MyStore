//
//  MonthCardHomeHeaderView.h
//  Sport
//
//  Created by 江彦聪 on 15/6/5.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthCard.h"
#import "MonthCardService.h"

@protocol MonthCardHomeHeaderViewDelegate <NSObject>
@optional
-(void)didClickBuyButton;
-(void)didClickAssistentButton;
-(void)didClickAvatarButton;
-(void)didClickQrCodeButton;
-(void)didClickRefreshButton;
@end


@interface MonthCardHomeHeaderView : UIView<MonthCardServiceDelegate, UIAlertViewDelegate>
+ (MonthCardHomeHeaderView *)createViewWithFrame:(CGRect)frame;
+ (MonthCardHomeHeaderView *)createView;
- (CGFloat)getCardHeightWithBounds:(CGRect)bounds;
-(void)updateViewWithCard:(MonthCard *)card;
-(void)updateViewWithFinishBuyCard:(MonthCard *)card;

-(void)updateAvatarImage:(NSString *)url;

-(void)clearView;

-(void)showRefreshButton;
#define TAG_UPLOAD_AVATAR 2015061601
-(void)doClickQrCodeButton:(MonthCard *)card
                  delegate:(id)delegate;

@property (assign,nonatomic) id<MonthCardHomeHeaderViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;

@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@end
