//
//  SelectedCourtJoinProductView.h
//  Sport
//
//  Created by qiuhaodong on 16/6/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourtJoin;

@interface SelectedCourtJoinProductView : UIView

+ (SelectedCourtJoinProductView *)createViewWithCourtJoin:(CourtJoin *)courtJoin;

@end
