//
//  CoachCollectAndShareView.h
//  Sport
//
//  Created by quyundong on 15/9/6.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachCollectAndShareView : UIView
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

+ (CoachCollectAndShareView *)createCollectAndShareButtonView;

@end
