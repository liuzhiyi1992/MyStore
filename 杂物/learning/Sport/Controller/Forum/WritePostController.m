//
//  WritePostController.m
//  Sport
//
//  Created by 江彦聪 on 15/5/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "WritePostController.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "NSString+Utils.h"
#import "UploadPostPhoto.h"
#import "LoginController.h"
#import "UIImage+normalized.h"
#import "SportImagePickerController.h"
#import "PostPhotoManager.h"

@interface WritePostController ()<SportImagePickerControllerDelegate,PostPhotoManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *writePostTextView;
@property (copy, nonatomic) NSString *forumId;
@property (weak, nonatomic) IBOutlet UIView *imageHolderView;

@property (weak, nonatomic) IBOutlet UILabel *inputTextNumberLabel;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;


typedef enum
{
    TotalUploadStatusNone = 0,  //没有一张照片
    TotalUploadStatusPending = 1,  //还有未上传的照片
    TotalUploadStatusFailed = 2,
    TotalUploadStatusComplete, //上传完成
}TotalUploadStatus;

@end

@implementation WritePostController
#define TAG_IMAGE_BASE 10
#define TAG_BUTTON_BASE 20
#define MAX_PHOTO_COUNT 9

#define TAG_ALERT_DELETE 0x1000
#define TAG_ALERT_MASK 0xF000
#define TAG_ALERT_BACK 0x2000
#define TAG_ALERT_UPLOAD_FAIL 0x3000

-(id)initWithForumId:(NSString *)forumId
{
    self = [super init];
    if (self) {
        self.forumId = forumId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.writePostTextView.text = @"";
    self.writePostTextView.delegate = self;

    [self createRightTopButton:@"发布"];
    [self createLeftTopButton:@"取消"];
    
    for(UIView *view in self.imageHolderView.subviews) {
        
        if ([view isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)view setClipsToBounds:YES];
            [(UIImageView *)view setContentMode:UIViewContentModeScaleAspectFill];
            if (view.tag == TAG_IMAGE_BASE) {
                [(UIImageView *)view setImage:[SportImage addPhotoIconImage]];
            }
        }

        if (view.tag == TAG_BUTTON_BASE || view.tag == TAG_IMAGE_BASE) {
            view.hidden = NO;
        } else {
            view.hidden = YES;
        }
    }
    
    self.manager = [[PostPhotoManager alloc]initWithController:self maxPhotoCount:9];
    
    self.user = [[UserManager defaultManager] readCurrentUser];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    // Do any additional setup after loading the view from its nib.
}

-(void)dealloc {
    
}

//选择图片
- (IBAction)clickImageButton:(id)sender {
    
    [self.writePostTextView resignFirstResponder];
    UIButton *button = (UIButton *)sender;
    int selectedIndex = (int)button.tag - TAG_BUTTON_BASE;
    
    [self.manager showOrDeleteImageWithIndex:selectedIndex];
}

#pragma mark --PostPhotoManagerDelegate
- (void)postSelectedImage:(UploadPostPhoto *)uploadPhoto{
    [ForumService postImage:self coterieId:self.forumId userId:self.user.userId image:uploadPhoto.photoImage uploadTimestamp:uploadPhoto.timestamp];
}

//上传成功的回调，通过manager执行具体操作
- (void)didPostImage:(PostPhoto *)photo
              status:(NSString *)status
                 msg:(NSString *)msg
     uploadTimestamp:(NSString *)timestamp
{
    [self.manager didPostSelectedImageWithStatus:status key:timestamp attachId:photo.photoId imageUrl:photo.photoImageUrl thumbUrl:photo.photoImageUrl];
}

-(void)deleteImageWithAttachId:(NSString *)attachId {
    
    [ForumService delImage:self coterieId:self.forumId userId:self.user.userId attachId:attachId];
}

- (void)updatePhotoUI
{
    NSArray* selectedPhotoList = self.manager.selectedPhotoList;
    
    NSUInteger photoCount = [selectedPhotoList count];
    if (photoCount > MAX_PHOTO_COUNT) {
        
        HDLog(@"ERROR! Should not exceed MAX_PHOTO_COUNT");
        return;
    }
    
    for(int i = 0;i < MAX_PHOTO_COUNT;i++) {
        UIView *imageView = [self.imageHolderView viewWithTag:TAG_IMAGE_BASE+i];
        UIView *buttonView = [self.imageHolderView viewWithTag:TAG_BUTTON_BASE+i];
        
        if (i < photoCount) {
            if ([imageView isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)imageView setImage:[(UploadPostPhoto *)selectedPhotoList[i] thumbImage]];
                imageView.hidden = NO;
                buttonView.hidden = NO;
            }
            
        } else {
            //最后一个，且还可以再加
            if (i == photoCount) {
                if ([imageView isKindOfClass:[UIImageView class]]) {
                    [(UIImageView *)imageView setImage:[SportImage addPhotoIconImage]];
                    imageView.hidden = NO;
                    buttonView.hidden = NO;
                }
            } else {
                imageView.hidden = YES;
                buttonView.hidden = YES;
            }
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = [self checkIsInputTextOrPhoto];
}

- (void)addPostWithAttachIds:(NSString *)attachIds {
    [SportProgressView showWithStatus:@"发布中"];
    [ForumService addPost:self coterieId:self.forumId content:self.inputText userId:self.user.userId attachIds:attachIds];
    
}

//发布帖子
-(void) addPost
{
    if ([self checkIsInputTextOrPhoto] == NO) {
        [SportPopupView popupWithMessage:@"请输入文字或图片！"];
        return;
    }
    
    [self.manager addPost];
}

#pragma mark -- ForumServiceDelegate
-(void)didAddPost:(NSString *)postId status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        if ([_delegate respondsToSelector:@selector(didFinishWritePost)]) {
            [_delegate didFinishWritePost];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else {
        //发布失败，恢复发布按钮
        //self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [SportProgressView dismissWithError:msg];
    }
}

-(NSString *)preProcessInputText:(NSString *)text
{
    return [[text stringByTrimmingLeadingWhitespaceAndNewline] stringByTrimmingTrailingWhitespaceAndNewline];

}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_forum_create_post_click_send];
    [self.writePostTextView resignFirstResponder];
    [self addPost];
}

- (void)clickLeftTopButton:(id)sender
{
    [self.writePostTextView resignFirstResponder];
    
    if ([self checkIsInputTextOrPhoto] == NO) {
        [self cleanAndPop];
        return;
    }
    
    [MobClickUtils event:umeng_event_forum_create_post_click_cancel];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确定放弃当前内容?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = TAG_ALERT_BACK;
    [alert show];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [MobClickUtils event:umeng_event_forum_create_post_click_input];
    
    self.placeHolderLabel.hidden = YES;

    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        self.placeHolderLabel.hidden = NO;
    }
    
    [textView resignFirstResponder];
}
- (IBAction)touchDownBackground:(id)sender {
     [self.writePostTextView resignFirstResponder];
}


#define MAX_POST_LENGTH 140
- (void)textViewDidChange:(UITextView *)textView
{
    
    self.navigationItem.rightBarButtonItem.enabled = [self checkIsInputTextOrPhoto];
    
    NSString *toBeString = textView.text;
    
    UITextRange *selectedRange = [textView markedTextRange];
    
    //获取高亮部分
    UITextPosition *position = nil;
    if (selectedRange) {
        position = [self.writePostTextView positionFromPosition:selectedRange.start offset:0];
    }
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (toBeString.length > MAX_POST_LENGTH) {
            textView.text = [toBeString substringToIndex:MAX_POST_LENGTH];
            [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_POST_LENGTH]];
        }
        
        int restNumber = MAX_POST_LENGTH - (int)[textView.text length];
        if (restNumber > 0) {
            self.inputTextNumberLabel.text = [@(restNumber) stringValue];
        } else {
            self.inputTextNumberLabel.text = @"0";
        }
    }
    // 有高亮选择的字符串，则暂不对文字进行统计和限制
    else{
        
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_ALERT_BACK:
            
            if (buttonIndex != alertView.cancelButtonIndex) {
                [self cleanAndPop];
            }
            break;
        default:
            break;
    }
}

-(void) cleanAndPop {
    [SportProgressView dismiss];
    
    [self.manager cleanPhotoManager];
    
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES) afterDelay:0.5];
}

-(BOOL)checkIsInputTextOrPhoto
{
    BOOL isEnable;
    UITextRange *selectedRange = [self.writePostTextView markedTextRange];
    //获取高亮部分
    
    UITextPosition *position = nil;
    if (selectedRange) {
        position = [self.writePostTextView positionFromPosition:selectedRange.start offset:0];
    }
    
    self.inputText = [self preProcessInputText:self.writePostTextView.text];
    
    if ([self.manager.selectedPhotoList count] == 0 && (position == nil && [self.inputText length] == 0)) {
        isEnable = NO;
    } else {
        isEnable = YES;
    }
    
    return isEnable;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)clickShareButton:(id)sender {
    [self didClickShareToForumButton];
}

-(void) didClickShareToForumButton {
    
}


@end
