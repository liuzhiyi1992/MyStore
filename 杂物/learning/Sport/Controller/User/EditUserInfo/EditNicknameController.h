//
//  EditNicknameController.h
//  Sport
//
//  Created by haodong  on 13-7-16.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"

@protocol EditNicknameControllerDelegate <NSObject>
@optional
- (void)didFinishEditNickName:(NSString *)nickName;

@end

@interface EditNicknameController : SportController<UserServiceDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *writeImageView;

@property (assign, nonatomic) id<EditNicknameControllerDelegate> delegate;

- (id)initWithNickname:(NSString *)nickname;

@end
