//
//  SignInRecordsCabinetView.h
//  Sport
//
//  Created by lzy on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInRecordsCabinetView : UIView
@property (strong, nonatomic) IBInspectable UIImage *backgroundImage;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *rmbLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rmbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rewardSignImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rewardSignBottomConstraint;

@end
