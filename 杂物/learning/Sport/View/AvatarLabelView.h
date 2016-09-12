//
//  AvatarLabelView.h
//  Sport
//
//  Created by 江彦聪 on 15/12/15.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
@class CourtJoinUser;
@protocol AvatarLabelViewDelegate <NSObject>

-(void)didClickAvatarButton:(NSString *)userId;

@end

@interface AvatarLabelView : UIView
@property (assign, nonatomic) id<AvatarLabelViewDelegate> delegate;

+ (AvatarLabelView *)createAvatarLabelViewWithFrame:(CGRect)frame;
+ (CGSize)defaultSize;
- (void)updateAvatarWithUser:(CourtJoinUser *)user;
@end
