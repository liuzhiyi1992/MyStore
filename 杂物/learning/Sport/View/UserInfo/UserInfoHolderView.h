//
//  UserInfoHolderView.h
//  Sport
//
//  Created by liuzhiyi on 15/11/5.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ViewStatusMyself = 0,
    ViewStatusOther = 1,
} ViewStatus;

@protocol UserInfoHolderViewDelegate <NSObject>

-(void)didSendMessage;

@end

@interface UserInfoHolderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *arrowRightImageView;
@property (assign, nonatomic) id<UserInfoHolderViewDelegate> delegate;
+ (UserInfoHolderView *)creatViewWithAvatarUrl:(NSURL *)url
                                      userName:(NSString *)userName
                                          city:(NSString *)city
                                      signture:(NSString *)signture
                                        gender:(NSString *)gender
                                         level:(NSString *)level
                                       iconUrl:(NSString *)iconUrl
                                isRulesDisplay:(BOOL)isRulesDisplay
                                    viewStatus:(ViewStatus)viewStatus;



@end
