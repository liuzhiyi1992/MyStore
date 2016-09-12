//
//  CourtJoinGuideView.h
//  Sport
//
//  Created by 江彦聪 on 16/7/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourtJoinGuideView : UIView
+ (CourtJoinGuideView *)createCourtJoinGuideView;
- (void)show;

@property (weak, nonatomic) UIViewController *superController;
@end
