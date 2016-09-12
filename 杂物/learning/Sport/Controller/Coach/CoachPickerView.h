//
//  CoachPickerView.h
//  Sport
//
//  Created by 江彦聪 on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportPickerView.h"

@protocol CoachPickerViewDelegate <NSObject>
    
@end

@interface CoachPickerView : SportPickerView
+ (CoachPickerView *)createCoachPickerView;
@end
