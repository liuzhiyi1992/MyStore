//
//  SportNavigationTitleView.m
//  Sport
//
//  Created by 江彦聪 on 8/15/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import "SportNavigationTitleView.h"

@implementation SportNavigationTitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (SportNavigationTitleView *)createSportNavigationTitleView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportNavigationTitleView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    SportNavigationTitleView *view = (SportNavigationTitleView *)[topLevelObjects objectAtIndex:0];
    view.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    return view;
}

//- (void)setFrame:(CGRect)frame {
//    [super setFrame:CGRectMake(0, 0, self.superview.bounds.size.width, self.superview.bounds.size.height)];
//}

-(void) hideButtonWithIndex:(int)index {
    UIButton *button = (UIButton *)[self viewWithTag:index+100];
    button.hidden = YES;
    switch (index) {
        case 0:
            self.leftButton1Width.constant = 0;
            break;
        case 1:
            self.leftButton2Width.constant = 0;
            break;
        case 2:
            self.rightButton2Width.constant = 0;
            break;
        case 3:
            // 右边增加一个margin，但是不缩小点击面积
            self.rightButton1Width.constant = 0;
        default:
            break;
    }
}

#define TAG_BUTTON_BASE 100
-(void) showButtonWithIndex:(int)index {
    UIButton *button = (UIButton *)[self viewWithTag:index+100];
    button.hidden = NO;
    
    switch (index) {
        case 0:
            self.leftButton1Width.constant = 49;
            break;
        case 1:
            self.leftButton2Width.constant = 44;
            break;
        case 2:
            self.rightButton2Width.constant = 44;
            break;
        case 3:
            // 右边增加一个margin，但是不缩小点击面积
            self.rightButton1Width.constant = 44+5;
        default:
            break;
    }
}

@end
