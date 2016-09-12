//
//  CollectAndShareButtonView.h
//  Sport
//
//  Created by haodong  on 15/3/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectAndShareButtonView : UIView

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

+ (CollectAndShareButtonView *)createCollectAndShareButtonView;
+ (CollectAndShareButtonView *)createShareButtonView;
@end
