//
//  FeedbackController.h
//  Sport
//
//  Created by haodong  on 13-10-28.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BaseService.h"

@interface FeedbackController : SportController<UITextViewDelegate, BaseServiceDelegate>

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *countTipsLabel;

@end
