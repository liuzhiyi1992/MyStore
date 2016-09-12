//
//  InputGoodsCountView.h
//  Sport
//
//  Created by haodong  on 15/1/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputGoodsCountViewDelegate <NSObject>
@optional
- (void)didClickInputGoodsCountViewCancelButton;
- (void)didClickInputGoodsCountViewOKButton:(int)count;
- (void)didClickBackground;
@end


@interface InputGoodsCountView : UIView<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *line2ImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomHoldeView;

@property (weak, nonatomic) IBOutlet UIImageView *inputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (assign, nonatomic) id<InputGoodsCountViewDelegate> delegate;

+ (InputGoodsCountView *)createInputGoodsCountView;

- (void)updateViewCount:(int)count maxCount:(int)maxCount;

- (void)show;

- (void)updateMinusButtonAndPlusButton;
@end
