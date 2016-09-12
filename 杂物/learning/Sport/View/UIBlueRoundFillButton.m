//
//  BlueRoundFillButton.m
//  Sport
//
//  Created by 江彦聪 on 16/7/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UIBlueRoundFillButton.h"

@implementation UIBlueRoundFillButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initRoundButton];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initRoundButton];
}

-(void) initRoundButton {
    
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.masksToBounds = YES;
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultBlueColor]] forState:UIControlStateNormal];
}
@end
