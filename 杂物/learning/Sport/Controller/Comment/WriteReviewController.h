//
//  WriteReviewController.h
//  Sport
//
//  Created by haodong  on 14/10/30.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BusinessService.h"
#import "UserService.h"
#import "ForumService.h"
#import "UploadPostPhoto.h"

@protocol WriteReviewControllerDelegate <NSObject>

-(void)didFinishWritePost;

@end
@interface WriteReviewController : SportController<BusinessServiceDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UserServiceDelegate, UIAlertViewDelegate, UITextViewDelegate, UIScrollViewDelegate,ForumServiceDelegate>

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *contentPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageNoticeLabel;
@property (assign, nonatomic) int loadingImageCount;
@property (copy, nonatomic) NSString *orderId;
@property (assign, nonatomic) id<WriteReviewControllerDelegate> delegate;

- (instancetype)initWithBusinessId:(NSString *)businessId
                      businessName:(NSString *)businessName
                           orderId:(NSString *)orderId;

-(void)queryDataWithId:(NSString *)businessId
                  text:(NSString *)text
                userId:(NSString *)userId
           commentRank:(int)commentRank
               orderId:(NSString *)orderId
            galleryIds:(NSString *)galleryIds;
@end
