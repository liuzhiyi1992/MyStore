//
//  RecommendDetailAlertView.h
//  Sport
//
//  Created by xiaoyang on 16/7/26.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RecommendDetailAlertViewDelegate <NSObject>
@optional
- (void)didSelectedPosition;
- (void)didClickSubmitButtonWithBusinessNameTextfieldText:(NSString *)businessNameTextfieldText;
- (void)updateTextFieldText:(NSString *)text;
@end

@interface RecommendDetailAlertView : UIView<UITextFieldDelegate>
@property (assign, nonatomic) id<RecommendDetailAlertViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UITextField *businessNameTextfield;
@property (weak, nonatomic) IBOutlet UIControl *clearControl;
@property (weak, nonatomic) IBOutlet UIButton *selectedAddressButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

+ (RecommendDetailAlertView *)createRecommendDetailAlertView;
- (void)show;

@end
