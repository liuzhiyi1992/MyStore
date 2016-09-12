//
//  HomeFooterView.m
//  Sport
//
//  Created by 冯俊霖 on 15/8/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "HomeFooterView.h"
#import "UIView+Utils.h"

@interface HomeFooterView()
@property (retain, nonatomic) IBOutlet UIButton *lookMoreButton;
@property (retain, nonatomic) IBOutlet UIImageView *logoImageview;
@property (retain, nonatomic) IBOutlet UIView *blankView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *blankViewConstraintY;

@end

@implementation HomeFooterView
+ (HomeFooterView *)createHomeFooterViewWithDelegate:(id<HomeFooterViewDelegate>)delegate{
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HomeFooterView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    HomeFooterView *view = (HomeFooterView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return view;
}

- (void)updateFooterViewWithIsHidebutton:(BOOL)isHidebutton hasMoreCourse:(NSString *)hasMoreCourse courseList:(NSArray *)courseList{
    
    if (isHidebutton == YES || [hasMoreCourse isEqualToString:@"0"] || courseList.count == 0) {
        self.lookMoreButton.hidden = YES;
        self.blankViewConstraintY.constant = 0;
        [self updateHeight:25];
    }else{
        self.lookMoreButton.hidden = NO;
        self.blankViewConstraintY.constant = self.lookMoreButton.frame.size.height;
        [self updateHeight:self.lookMoreButton.frame.size.height + 25];
    }
}

- (IBAction)clickLookMoreButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didClickLookMoreButton)]) {
        [_delegate didClickLookMoreButton];
    }
}

@end
