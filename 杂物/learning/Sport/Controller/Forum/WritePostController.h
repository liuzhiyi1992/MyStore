//
//  WritePostController.h
//  Sport
//
//  Created by 江彦聪 on 15/5/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "ForumService.h"
@class PostPhotoManager;
@protocol WritePostControllerDelegate <NSObject>

-(void)didFinishWritePost;

@end

@interface WritePostController : SportController<UITextViewDelegate,ForumServiceDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
-(id)initWithForumId:(NSString *)forumId;
-(BOOL)checkIsInputTextOrPhoto;
-(void) cleanAndPop;
-(void)updatePhotoUI;
-(void) didClickShareToForumButton;

@property (assign, nonatomic) id<WritePostControllerDelegate> delegate;
@property (copy, nonatomic) NSString *inputText;
@property (strong, nonatomic) PostPhotoManager *manager;
@property (weak, nonatomic) IBOutlet UIView *shareHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *shareButtonImage;

@property (weak, nonatomic) IBOutlet UILabel *ForumShareTitle;
@property (weak, nonatomic) IBOutlet UIButton *shareToForumButton;
@end
