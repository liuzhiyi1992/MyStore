//
//  CoachAuthenticationInfoView.m
//  Sport
//
//  Created by liuzhiyi on 15/10/9.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "CoachAuthenticationInfoView.h"
#import "UIView+Utils.h"

@interface CoachAuthenticationInfoView ()
@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) NSArray *dateList;
@end

@implementation CoachAuthenticationInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (CoachAuthenticationInfoView *)createCoachAuthenticationInfoViewWithDateList:(NSArray *)dateList {
    CoachAuthenticationInfoView *view = [[NSBundle mainBundle] loadNibNamed:@"CoachAuthenticationInfoView" owner:self options:nil][0];
    view.dateList = dateList;
    return view;
}

- (void)show{
    
    [self updateUI];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.frame = CGRectMake(0, 64, window.frame.size.width, window.frame.size.height);
    [window addSubview:self];
    
    self.mainContentView.alpha = 0;
    self.mainContentView.transform = CGAffineTransformMakeScale(0, 0);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.mainContentView.alpha = 1;
        self.mainContentView.transform = CGAffineTransformMakeScale(1, 1);
    }completion:^(BOOL finished) {
    }];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)updateUI {
    NSMutableString *tempString = [NSMutableString string];
    for (NSString *str in _dateList) {
        [tempString appendFormat:@"%@\n\n", str];
    }
    if(tempString.length > 2) {
        self.contentLabel.text = [tempString substringToIndex:tempString.length - 2];
    }else {
        self.contentLabel.text = tempString;
    }
}

- (IBAction)clickcloseButton:(id)sender {
    [self dismiss];
}

@end
