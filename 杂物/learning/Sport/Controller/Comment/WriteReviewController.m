//
//  WriteReviewController.m
//  Sport
//
//  Created by haodong  on 14/10/30.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "WriteReviewController.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "UIView+Utils.h"
#import "AppGlobalDataManager.h"
#import "UploadPostPhoto.h"
#import "SportImagePickerController.h"
#import "UIImage+normalized.h"
#import "NSString+Utils.h"
#import "LoginController.h"
#import "PostPhotoManager.h"

@interface WriteReviewController ()<PostPhotoManagerDelegate>
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *businessName;
@property (assign, nonatomic) NSInteger rate;
@property (copy, nonatomic) NSString *selectedDeletePhotoId;
@property (weak, nonatomic) IBOutlet UIView *imageHolderView;
@property (strong, nonatomic) User *user;
@property (copy, nonatomic) NSString *forumId;
@property (strong, nonatomic) PostPhotoManager *manager;

typedef enum
{
    TotalUploadStatusNone = 0,  //没有一张照片
    TotalUploadStatusPending = 1,  //还有未上传的照片
    TotalUploadStatusFailed = 2,
    TotalUploadStatusComplete, //上传完成
}TotalUploadStatus;

@end

@implementation WriteReviewController

//本controller总共6大分支，3大回调包括 1网络回调

#define TAG_IMAGE_BASE 5
#define TAG_BUTTON_BASE 20
#define MAX_PHOTO_COUNT 4

#define TAG_ALERT_DELETE 0x1000
#define TAG_ALERT_MASK 0xF000
#define TAG_ALERT_BACK 0x2000
#define TAG_ALERT_UPLOAD_FAIL 0x3000


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) dealloc {

}

- (instancetype)initWithBusinessId:(NSString *)businessId
                      businessName:(NSString *)businessName
                           orderId:(NSString *)orderId
{
    self = [super initWithNibName:@"WriteReviewController" bundle:nil];
    if (self) {
        self.businessId = businessId;
        self.businessName = businessName;
        self.orderId = orderId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _businessName;
    
    [self.view updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 1)];
    
//  self.photoList = [NSMutableArray array];
    
    self.manager = [[PostPhotoManager alloc]initWithController:self maxPhotoCount:4];
    
    [self initBaseViews];
    
    [MobClickUtils event:umeng_event_enter_write_review];
}

#define TAG_RATE_BUTTON_START   10
- (void)initBaseViews
{
    for (UIView *subView in self.view.subviews) {
        if (subView.tag == 100 && [subView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)subView setImage:[SportImage lineImage]];
        }
        
        if (subView.tag == 102 && [subView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)subView setImage:[SportImage whiteBackgroundRoundImage]];
        }
        
        if (subView.tag == 103 && [subView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)subView setImage:[SportImage grayBackgroundRoundImage]];
        }
    }
    
//    [self.submitButton setBackgroundImage:[SportImage blueFrameButtonImage] forState:UIControlStateNormal];
//    [self.submitButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
    
    self.rate = 5;
    for (int i = 0 ; i < 5 ; i ++) {
        UIButton *one = (UIButton *)[self.view viewWithTag:TAG_RATE_BUTTON_START + i];
        one.selected = YES;
    }
    
    [self updateImageButtons];
}

#define TAG_IMAGE_BUTTON_START  20
#define TAG_IMAGE_START  30

#pragma mark - 回调1
- (void)updateImageButtons
{
    NSArray *photoList = self.manager.selectedPhotoList;
    
    for (int i = 0 ; i < 6 ; i ++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:TAG_IMAGE_BUTTON_START + i];
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:TAG_IMAGE_START + i];
        if (i < [photoList count]) {
            UploadPostPhoto *photo= [photoList objectAtIndex:i];
            
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:YES];
            [imageView setImage:photo.thumbImage];
//            [imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoThumbUrl]];
            
            imageView.hidden = NO;
            button.hidden = NO;
        }else if (i == [photoList count]) {
            
            [imageView setImage:[SportImage addImageButtonImage]];
            button.hidden = NO;
            imageView.hidden = NO;
        } else{
            button.hidden = YES;
            imageView.hidden = YES;
        }
    }
}
#pragma mark - /回调1
#pragma mark - 分支1_评星

- (IBAction)clickRateButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag - TAG_RATE_BUTTON_START;
    
    self.rate = index + 1;
    
    for (int i = 0 ; i < 5 ; i ++) {
        UIButton *one = (UIButton *)[self.view viewWithTag:TAG_RATE_BUTTON_START + i];
        if (i <= index) {
            one.selected = YES;
        } else {
            one.selected = NO;
        }
    }
}
#pragma mark - 分支2_点击背景收起键盘

- (IBAction)touchDownBackground:(id)sender {
    [self.contentTextView resignFirstResponder];
}
#pragma mark - 分支3_滑动屏幕收起键盘

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.contentTextView == scrollView) {
        return;
    }
    
    [self.contentTextView resignFirstResponder];
}

#pragma mark - 分支4_textview
- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] > 0) {
        self.contentPlaceholderLabel.hidden = YES;
    } else {
        self.contentPlaceholderLabel.hidden = NO;
    }
}

#pragma mark - 分支5_点击选图
- (IBAction)clickImageButton:(id)sender {
    [self.contentTextView resignFirstResponder];
    UIButton *button = (UIButton *)sender;
    int index = (int)button.tag - TAG_IMAGE_BUTTON_START;
    
    [self.manager showOrDeleteImageWithIndex:index];

}

#pragma mark - 分支5.1_从相册选择
-(void)uploadGallery:(UIImage *)image
                 key:(NSString *)key
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [UserService upLoadGallery:self
                        userId:user.userId
                         image:image
                          type:2
                           key:key];
}


- (void)didUpLoadGallery:(NSString *)status
                    type:(int)type
                thumbUrl:(NSString *)thumbUrl
                imageUrl:(NSString *)imageUrl
                 photoId:(NSString *)photoId
                     key:(NSString *)key
{
    [self.manager didPostSelectedImageWithStatus:status key:key attachId:photoId imageUrl:imageUrl thumbUrl:thumbUrl];
}

#pragma mark - 回调3_网络


#pragma mark - /回调3_网络


#pragma mark - 分支5.3_删除图片


#define TAG_ALERT_VIEW_DELETE_PHOTO 2015020301
#define TAG_ALERT_VIEW_GET_POINT    2015020302


- (void)deletePhoto:(NSString *)photoId
{
    if (photoId == nil) {
        return;
    }
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    [UserService deleteGallery:self
                        userId:user.userId
                       photoId:photoId
                          type:2];
}

#pragma mark - 分支6_提交评论

- (IBAction)clickSubmitButton:(id)sender {
    
    [self.contentTextView resignFirstResponder];
    if ([_contentTextView.text length] < 10) {
        [SportPopupView popupWithMessage:@"需要10字以上能提交"];
        return;
    }
    
    if ([_contentTextView.text length] > 140) {
        [SportPopupView popupWithMessage:@"超过了140字"];
        return;
    }
    
    if ([_contentTextView.text isEqualToString:[[AppGlobalDataManager defaultManager] recentSubmitReview]]) {
        [SportPopupView popupWithMessage:@"不可发送重复的评论"];
        return;
    }
    
    [self sendComment];
}

- (void)sendComment {

    [self.manager addPost];
}

-(void)clickBackButton:(id)sender {
    [SportProgressView dismiss];
    
    [self.manager cleanPhotoManager];

    [super clickBackButton:sender];
}


// 为CoachWriteReviewController复用
-(void)queryDataWithId:(NSString *)businessId
                  text:(NSString *)text
                userId:(NSString *)userId
           commentRank:(int)commentRank
               orderId:(NSString *)orderId
            galleryIds:(NSString *)galleryIds
{
    [BusinessService sendComment:self
                      businessId:businessId
                            text:text
                          userId:userId
                     commentRank:commentRank
                         orderId:orderId
                      galleryIds:galleryIds];
    
}

#pragma mark-PostPhotoManagerDelegate
- (void)updatePhotoUI {
    [self updateImageButtons];
}

- (void)postSelectedImage:(UploadPostPhoto *)uploadPhoto {
    [self uploadGallery:uploadPhoto.photoImage key:uploadPhoto.timestamp];
}

- (void)addPostWithAttachIds:(NSString *)attachIds {
    [SportProgressView showWithStatus:@"正在提交..."];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [self queryDataWithId:_businessId
                     text:_contentTextView.text
                   userId:user.userId
              commentRank:(int)_rate
                  orderId:_orderId
               galleryIds:attachIds];
}

- (void)didSendComment:(NSString *)status msg:(NSString *)msg point:(int)point text:(NSString *)text
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        if ([text length] > 0) {
            [[AppGlobalDataManager defaultManager] setRecentSubmitReview:text];
        }
        
        if (point > 0) {
            [SportProgressView dismiss];
            
            //iOS 8，显示alertView会弹出键盘，延迟显示可以规避这个问题
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *message = [NSString stringWithFormat:@"评论成功!获得%d积分", point];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                alertView.tag = TAG_ALERT_VIEW_GET_POINT;
                [alertView show];
            });

            //[SportProgressView dismissWithSuccess:[NSString stringWithFormat:@"成功!获得%d积分", point] afterDelay:2];
        } else {
            [SportProgressView dismissWithSuccess:@"提交成功"];
        }
        
        NSDictionary *dic = @{@"order_id":_orderId};
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_WRITE_REVIEW object:nil userInfo:dic];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"提交失败"];
        }
    }
}

- (void)deleteImageWithAttachId:(NSString *)attachId {
    [self deletePhoto:attachId];
}

@end

