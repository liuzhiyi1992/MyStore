//
//  CoachCancelReasonView.h
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachService.h"

@protocol CoachCancelReasonViewDelegate <NSObject>

-(void)didClickConfirmCancelButtonWithReasonId:(NSString *)reasonId;

@end

@interface CoachCancelReasonView : UIView<UITableViewDelegate, UITableViewDataSource,CoachServiceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) id<CoachCancelReasonViewDelegate>delegate;
+ (CoachCancelReasonView *)createCoachCancelReasonView;
- (void)show;
@end
