//
//  ShareFieldWillingSurveyView.h
//  Sport
//
//  Created by lzy on 16/4/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareFieldWillingSurveyView : UIView
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *itemButtons;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
+ (ShareFieldWillingSurveyView *)showWithOrderId:(NSString *)orderId;
@end
