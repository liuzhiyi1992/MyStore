//
//  SignInRecordsCabinetView.m
//  Sport
//
//  Created by lzy on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SignInRecordsCabinetView.h"


@interface SignInRecordsCabinetView()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation SignInRecordsCabinetView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"SignInRecordsCabinetView" owner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = self.bounds;
}


- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImageView.image = backgroundImage;
}

@end
