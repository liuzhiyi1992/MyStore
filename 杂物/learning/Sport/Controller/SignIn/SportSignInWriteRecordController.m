//
//  SportSignInWriteRecordController.m
//  Sport
//
//  Created by 江彦聪 on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportSignInWriteRecordController.h"

#import "SportProgressView.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "NSString+Utils.h"
#import "UploadPostPhoto.h"
#import "LoginController.h"
#import "UIImage+normalized.h"
#import "SportImagePickerController.h"
#import "PostPhotoManager.h"
#import "SignInService.h"
#import "UserService.h"

@interface SportSignInWriteRecordController ()<SportImagePickerControllerDelegate,PostPhotoManagerDelegate,UITextViewDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UserServiceDelegate>

@property (copy, nonatomic) NSString *signInId;
@property (strong, nonatomic) NSMutableDictionary *taskDic;
@property (copy, nonatomic) NSString *forumId;
@property (copy, nonatomic) NSString *forumName;

typedef enum
{
    TotalUploadStatusNone = 0,  //没有一张照片
    TotalUploadStatusPending = 1,  //还有未上传的照片
    TotalUploadStatusFailed = 2,
    TotalUploadStatusComplete, //上传完成
}TotalUploadStatus;

@end

@implementation SportSignInWriteRecordController
#define TAG_IMAGE_BASE 10
#define TAG_BUTTON_BASE 20
#define MAX_PHOTO_COUNT 9

#define TAG_ALERT_DELETE 0x1000
#define TAG_ALERT_MASK 0xF000
#define TAG_ALERT_BACK 0x2000
#define TAG_ALERT_UPLOAD_FAIL 0x3000

-(id)initWithSignInId:(NSString *)signInId
              forumId:(NSString *)forumId
            forumName:(NSString *)forumName
{
    self = [super initWithNibName:@"WritePostController" bundle:nil];
    if (self) {
        self.signInId = signInId;
        self.forumId = forumId;
        self.forumName = forumName;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *buttonItem = self.navigationItem.rightBarButtonItem;
    UIButton *rightButton = (UIButton *)buttonItem.customView;
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
//    [self createRightTopButton:@"保存"];
    self.taskDic = [NSMutableDictionary dictionary];
    if ([self.forumId length] > 0 && [self.forumName length] > 0) {
        self.shareHolderView.hidden = NO;
        self.shareToForumButton.selected = YES;
        self.ForumShareTitle.text = [NSString stringWithFormat:@"分享到%@",self.forumName];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)dealloc {
    
}

#pragma mark --PostPhotoManagerDelegate
- (void)postSelectedImage:(UploadPostPhoto *)uploadPhoto{
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    //性能问题，暂时使用ForumService的接口
    [ForumService postImage:self coterieId:@"1" userId:user.userId image:uploadPhoto.photoImage uploadTimestamp:uploadPhoto.timestamp];
    
//    __weak __typeof(self)weakSelf = self;
//    NSURLSessionTask *task = [UserService upLoadCommonGallery:self userId:user.userId image:uploadPhoto.photoImage key:uploadPhoto.timestamp completion:^(NSString *status,NSString* thumbUrl,NSString *imageUrl,NSString *photoId,NSString *key){
//        
//        if ([self.taskDic objectForKey:key]) {
//            [self.taskDic removeObjectForKey:key];
//        }
        
//        [weakSelf.manager didPostSelectedImageWithStatus:status key:key attachId:photoId imageUrl:imageUrl thumbUrl:thumbUrl];
//    }];
    
//    if (task) {
//        
//        NSURLSessionTask *taskCopy = [task copy];
//        [self.taskDic setObject:taskCopy forKey:uploadPhoto.timestamp];
//    }
}

////上传成功的回调，通过manager执行具体操作
- (void)didPostImage:(PostPhoto *)photo
              status:(NSString *)status
                 msg:(NSString *)msg
     uploadTimestamp:(NSString *)timestamp
{
    [self.manager didPostSelectedImageWithStatus:status key:timestamp attachId:photo.photoId imageUrl:photo.photoImageUrl thumbUrl:photo.photoImageUrl];
}


-(void)deleteImageWithAttachId:(NSString *)attachId {
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    [UserService deleteCommonGallery:self userId:user.userId photoId:attachId];
    
}

- (void)updatePhotoUI
{
    [super updatePhotoUI];
}

- (void)addPostWithAttachIds:(NSString *)attachIds {
    [SportProgressView showWithStatus:@"发布中"];
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    __weak __typeof(self) weakSelf = self;
    
    NSString *coterieId = nil;
    if(self.shareToForumButton.selected) {
        coterieId = self.forumId;
    }
    
    [SignInService writeSignInDiaryWithUserId:user.userId signInId:self.signInId content:self.inputText attachIds:attachIds coterieId:coterieId completion:^(NSString *status, NSString *msg) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [MobClickUtils event:umeng_event_sign_in_record_addition label:@"运动记录成功添加"];
            [SportProgressView dismiss];
            
            if ([self.delegate respondsToSelector:@selector(didFinishWritePost)]) {
                [self.delegate didFinishWritePost];
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        }else {
            
            [SportProgressView dismissWithError:msg];
        }
        
        
    }];
}

-(void) cleanAndPop {
    //取消所有pending的网络请求
    for (NSString *key in self.taskDic) {
        NSURLSessionTask *task = [self.taskDic objectForKey:key];
        if (task && [task isKindOfClass:[NSURLSessionTask class]]) {
            [task cancel];
        }
    }
    
    [super cleanAndPop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


-(void) didClickShareToForumButton {
    if (self.shareToForumButton.selected) {
        self.shareToForumButton.selected = NO;
        [self.shareButtonImage setImage:[UIImage imageNamed:@"roundButtonUnselected"]];
    } else {
        self.shareToForumButton.selected = YES;
        [self.shareButtonImage setImage:[UIImage imageNamed:@"roundButtonSelected"]];
    }
}


@end
