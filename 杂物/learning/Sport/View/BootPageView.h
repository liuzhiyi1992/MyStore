//
//  BootPageView.h
//  Sport
//
//  Created by haodong  on 14-5-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayPageControl.h"

@interface BootPageView : UIView<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet GrayPageControl *pageControl;

+ (BootPageView *)createBootPageView;

- (void)show;

@end
