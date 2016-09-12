//
//  EditSportPlanController.h
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"

@protocol EditSportPlanControllerDelegate <NSObject>
@optional
- (void)didClickEditSportPlanControllerBackButton:(NSString *)content tag:(int)tag;

@end

@interface EditSportPlanController : SportController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *inputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (assign, nonatomic) id<EditSportPlanControllerDelegate> delegate;

@property (assign, nonatomic) int maxLength;

- (instancetype)initWithContent:(NSString *)content tag:(int)tag;

@end
