//
//  FiltrateButtonView.m
//  Sport
//
//  Created by 冯俊霖 on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "FiltrateButtonView.h"
#import <CoreLocation/CoreLocation.h>
#import "UserManager.h"
#import "UIView+Utils.h"

@interface FiltrateButtonView()
@property (strong, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *venueButton;
@property (strong, nonatomic) IBOutlet UIButton *courseButton;
@property (strong, nonatomic) IBOutlet UIView *moveLineView;
@property (strong, nonatomic) IBOutlet UIImageView *clubImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *clubImageViewConstraintX;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *moveLineViewConstraintX;

@end

@implementation FiltrateButtonView

+ (FiltrateButtonView *)createFiltrateButtonViewWithDelegate:(id<FiltrateButtonViewDelegate>)delegate{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FiltrateButtonView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    FiltrateButtonView *view = (FiltrateButtonView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    
    CGSize labelSize = [view.courseButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    CGFloat x = [UIScreen mainScreen].bounds.size.width * 3/ 4 + labelSize.width/2;
    view.clubImageViewConstraintX.constant = x;
    
    view.venueButton.selected = YES;
    view.courseButton.selected = NO;
    
    [view.backGroundImageView setImage:[SportImage whiteBackgroundImage]];
    return view;
}

- (void)updateViewWithCourseList:(NSArray *)courseList{
    if (courseList.count == 0) {
        [self.courseButton setTitle:@"最近浏览" forState:UIControlStateNormal];
        [self.clubImageView setHidden:YES];
    }else{
        [self.courseButton setTitle:@"推荐课程" forState:UIControlStateNormal];
        [self.clubImageView setHidden:NO];
    }
    
    CLLocation  *location = [[UserManager defaultManager] readUserLocation];
    if (location == nil) {
        [self.venueButton setTitle:@"热门球馆" forState:UIControlStateNormal];
    }else{
        [self.venueButton setTitle:@"推荐场馆" forState:UIControlStateNormal];
    }

}

- (IBAction)clickVenueButton:(UIButton *)sender {
    
    self.venueButton.selected = YES;
    self.courseButton.selected = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.moveLineViewConstraintX.constant = (self.venueButton.frame.size.width - self.moveLineView.frame.size.width) / 2;
        [self.moveLineView updateCenterX:self.venueButton.center.x];
    }];
    
    if ([_delegate respondsToSelector:@selector(didClickVenueButton)]) {
        [_delegate didClickVenueButton];
    }
}

- (IBAction)clickCourseButton:(id)sender {
    [MobClickUtils event:umeng_event_home_click_history];
    
    self.venueButton.selected = NO;
    self.courseButton.selected = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.moveLineViewConstraintX.constant = self.venueButton.frame.size.width + (self.venueButton.frame.size.width - self.moveLineView.frame.size.width) / 2;
        [self.moveLineView updateCenterX:self.courseButton.center.x];
    }];

    if ([_delegate respondsToSelector:@selector(didClickCourseButton)]) {
        [_delegate didClickCourseButton];
    }
}

@end
