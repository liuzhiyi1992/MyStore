//
//  NoBlankSpaceView.m
//  Sport
//
//  Created by 冯俊霖 on 15/10/17.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "NoBlankSpaceView.h"

@interface NoBlankSpaceView()
@property (strong, nonatomic) IBOutlet UIButton *resetTimeButton;

@end

@implementation NoBlankSpaceView

+ (NoBlankSpaceView *)createNoBlankSpaceView{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NoBlankSpaceView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    NoBlankSpaceView *view = [topLevelObjects objectAtIndex:0];
    return view;
}

- (IBAction)clickResetTimeButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickResetTimeButton)]) {
        [self.delegate didClickResetTimeButton];
    }
}

@end
