//
//  SportNavigationTitleView.h
//  Sport
//
//  Created by 江彦聪 on 8/15/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SportNavigationTitleView : UIView
+ (SportNavigationTitleView *)createSportNavigationTitleView;

@property (weak, nonatomic) IBOutlet UIButton *leftButton1;
@property (weak, nonatomic) IBOutlet UIButton *leftButton2;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightButton1; //从最右边数起
@property (weak, nonatomic) IBOutlet UIButton *rightButton2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftButton1Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftButton2Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightButton1Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightButton2Width;
@property (weak, nonatomic) IBOutlet UIView *titleView;

-(void) showButtonWithIndex:(int)index;
-(void) hideButtonWithIndex:(int)index;
@end
