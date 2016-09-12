//
//  BlueRoundStokeButton.m
//  Sport
//
//  Created by 江彦聪 on 16/7/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UIBlueRoundStokeButton.h"

@implementation UIBlueRoundStokeButton

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
    
    self.layer.borderColor = [SportColor defaultBlueColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.masksToBounds = YES;
    [self setTitleColor:[SportColor content2Color] forState:UIControlStateDisabled];
    [self setTitleColor:[SportColor defaultBlueColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultBlueColor]] forState:UIControlStateHighlighted];
}

-(void) setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
         self.layer.borderColor = [SportColor defaultBlueColor].CGColor;
    } else {
         self.layer.borderColor = [SportColor content2Color].CGColor;
    }

}

@end
