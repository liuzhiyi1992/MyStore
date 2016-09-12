//
//  CoachHeaderView.m
//  Sport
//
//  Created by 江彦聪 on 15/7/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachHeaderView.h"
#import "Order.h"
#import "Coach.h"
#import "UIImageView+WebCache.h"

@interface CoachHeaderView()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coachRightImageView;

@end

@implementation CoachHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (CoachHeaderView *)createViewWithFrame:(CGRect)frame
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachHeaderView" owner:self options:nil];
    
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    
    CoachHeaderView *view = (CoachHeaderView *)[topLevelObjects objectAtIndex:0];
    
    view.bounds = frame;
    view.avatarImageView.layer.borderColor = [[UIColor hexColor:@"e1e1e1"] CGColor];
    view.avatarImageView.layer.borderWidth = 1.0f;
    view.avatarImageView.layer.cornerRadius = view.avatarImageView.frame.size.width/2;
    view.avatarImageView.layer.masksToBounds = YES;
    view.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    view.avatarImageView.clipsToBounds = YES;

    return view;
}

-(void)showWithSuperView:(UIView *)superView
              secondView:(UIView *)secondView
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableDictionary *viewsDictionary = [[ NSMutableDictionary alloc] initWithDictionary:
                                            @{@"headerVier":self,
                                              @"secondView":secondView
                                              }];
    NSMutableArray *constraints = [NSMutableArray array];
    [superView addSubview:self];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[headerVier]-(0)-|" options:0 metrics:nil views:viewsDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[headerVier]-(0)-[secondView]" options:0 metrics:nil views:viewsDictionary]];
    [superView addConstraints:constraints];

}


-(void)updateWithCoach:(Coach *)coach
{
    [self updateWithAvatar:coach.avatarUrl name:coach.name gender:coach.gender age:coach.age height:coach.height weight:coach.weight];
}

-(void)updateWithOrder:(Order *)order
{
    [self updateWithAvatar:order.coachAvatarUrl name:order.coachName gender:order.coachGender age:order.coachAge height:order.coachHeight weight:order.coachWeight];
}

-(void)updateWithAvatar:(NSString *)avatarUrl
                   name:(NSString *)name
                 gender:(NSString *)gender
                    age:(int)age
                 height:(int)height
                 weight:(int)weight
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[SportImage monthCardDefaultAvatar]];
    
    self.nameLabel.text = name;
    
    if ([gender isEqualToString:GENDER_MALE]) {
        [self.genderImageView setImage:[SportImage genderMaleImage]];
    } else {
        [self.genderImageView setImage:[SportImage genderFemaleImage]];
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%d岁/%dcm/%dkg",age,height, weight];

}

-(void)hideArrow
{
    self.coachRightImageView.hidden = YES;
}

- (IBAction)clickBackgroundButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickButton)]) {
        [_delegate didClickButton];
    }
}

@end
