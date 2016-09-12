//
//  SportPlusMinusView.h
//  Sport
//
//  Created by 江彦聪 on 16/8/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SportPlusMinusViewDelegate <NSObject>

-(void) updateSelectNumber:(int) number;

@end

@interface SportPlusMinusView : UIView

@property (assign, nonatomic) int countNumber;
@property (assign, nonatomic) int maxNumber;
@property (assign, nonatomic) int minNumber;
@property (assign, nonatomic) id<SportPlusMinusViewDelegate> delegate;

+ (SportPlusMinusView *)createSportPlusMinusViewWithMaxNumber:(int) maxNumber
                                                    minNumber:(int) minNumber;

- (void)updateMinusButtonAndPlusButton;
@end
