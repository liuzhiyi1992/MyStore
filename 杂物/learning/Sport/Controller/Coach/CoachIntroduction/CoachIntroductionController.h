//
//  CoachIntroductionController.h
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "CoachItemCell.h"

@interface CoachIntroductionController : SportController <CoachItemCellDelegate>

- (instancetype)initWithCoachId:(NSString *)coachId;

@end
