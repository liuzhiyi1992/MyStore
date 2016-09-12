//
//  PostPhotoManager.m
//  Sport
//
//  Created by 江彦聪 on 16/5/6.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "PostPhotoManager.h"
#import "SportImagePickerController.h"
#import "UploadPostPhoto.h"
#import "SportProgressView.h"
#import "UIImage+normalized.h"
#import "SportPopupView.h"
#import "SportNetworkContent.h"
#import "GSNetwork.h"

static PostPhotoManager *_postPhotoManager = nil;
@interface PostPhotoManager()<UIActionSheetDelegate,UIImagePickerControllerDelegate,SportImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) UIViewController<PostPhotoManagerDelegate> *sponser;

@property (strong, nonatomic) SportImagePickerController *imagePickerController;

@property (assign, nonatomic) int retryCount;
@property (assign, nonatomic) int selectedIndex;
@property (assign, nonatomic) int maxPhotoCount;
@end

#define TAG_IMAGE_BASE 10
#define TAG_BUTTON_BASE 20
#define MAX_PHOTO_COUNT 9

#define TAG_ALERT_DELETE 0x1000
#define TAG_ALERT_MASK 0xF000
#define TAG_ALERT_BACK 0x2000
#define TAG_ALERT_UPLOAD_FAIL 0x3000

typedef enum
{
    TotalUploadStatusNone = 0,  //没有一张照片
    TotalUploadStatusPending = 1,  //还有未上传的照片
    TotalUploadStatusFailed = 2,
    TotalUploadStatusComplete, //上传完成
}TotalUploadStatus;

@implementation PostPhotoManager

-(instancetype) initWithController:(UIViewController<PostPhotoManagerDelegate> *) controller maxPhotoCount:(int)count {
    self = [super init];
    if (self) {
        self.selectedPhotoList = [NSMutableArray array];
        self.sponser = controller;
        self.maxPhotoCount = count;
    }
    
    return self;
}

-(TotalUploadStatus) getUploadPhotoStatus
{
    TotalUploadStatus status = TotalUploadStatusNone;
    int validUploadPhotoCount = 0;
    if ([self.selectedPhotoList count] == 0) {
        return TotalUploadStatusNone;
    }
    
    int retryAddPostCount = 0;
    for (UploadPostPhoto *photo in self.selectedPhotoList) {
        if (photo.uploadState == UploadStateUploadFailed)  {
            status = TotalUploadStatusFailed;
            break;
        } else if (photo.uploadState == UploadStateUploadSuccess){
            validUploadPhotoCount++;
        } else if (photo.uploadState == UploadStateUploading){
            retryAddPostCount++;
        }
    }
    
    if (validUploadPhotoCount == [self.selectedPhotoList count]) {
        status = TotalUploadStatusComplete;
    } else if (status != TotalUploadStatusFailed && retryAddPostCount > 0){
        status = TotalUploadStatusPending;
    }
    
    return status;
}

-(UploadPostPhoto *)getUploadPhotoWithTimeStamp:(NSString *)stamp
{
    for (UploadPostPhoto *selectedPhoto in self.selectedPhotoList) {
        if (stamp && ([selectedPhoto.timestamp isEqualToString:stamp])) {
            return selectedPhoto;
        }
    }
    
    return nil;
}

//添加或者删除图片
-(void)showOrDeleteImageWithIndex:(int)index {
    if (index >= [self.selectedPhotoList count]) {
        
        [MobClickUtils event:umeng_event_forum_create_post_click_add_image];
        
        [self showEditImageActionSheet];
        
    } else {
        self.selectedIndex = index;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确定删除该照片?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alert.tag = TAG_ALERT_DELETE;
        [alert show];
    }
}

- (void)showEditImageActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:DDTF(@"kCancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:DDTF(@"kSelectFromAlbum"), DDTF(@"kTakePhoto"), nil];
    
    [sheet showInView:self.sponser.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self selectPhoto];
            break;
        case 1:
            [self takePhoto];
            break;
        default:
            break;
    }
}

-(void)selectPhoto
{
    
    self.imagePickerController = [[SportImagePickerController alloc]initWithDelegate:self
                                                             numberOfPhotoCanBeAdded:[self numberOfPhotoCanBeAdded]];
    self.imagePickerController.isMultipleMode = YES;
    [self.sponser presentViewController:self.imagePickerController animated:YES completion:nil];
    
}

- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        picker.delegate = self;
        [self.sponser presentViewController:picker animated:YES completion:nil];
    }
}

- (int)numberOfPhotoCanBeAdded{
    int restNumber = self.maxPhotoCount - (int)[self.selectedPhotoList count];
    if (restNumber > 0) {
        return restNumber;
    }
    
    return 0;
}


#pragma mark -- UIImagePickerControllerDelegate
#define MAX_LEN_CUSTOM 640.0  //原来是100
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //NSString *infoKey = UIImagePickerControllerEditedImage;
    NSString *infoKey = UIImagePickerControllerOriginalImage;
    
    UIImage *image = [info objectForKey:infoKey];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (image != nil){
        
        //保存图片
        UIImageWriteToSavedPhotosAlbum(image, self,
                                       nil, nil);
        // [NSThread detachNewThreadSelector:@selector(handleImage:) toTarget:self withObject:image];
        [self uploadOneImage:image
                  thumbImage:image];
    }
    
    [self updateSelectedPhotoUI];
}

- (void)image:(UIImage *)image didFinishSavingWithError:
(NSError *)error contextInfo:(void *)contextInfo;
{
    // Handle the end of the image write process
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SportImagePickerControllerDelegate methods
- (void)sportImagePickerController:(SportImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [SportProgressView showWithStatus:@"请稍候" hasMask:YES];
    
    //上传压缩较耗时，放到其他线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (ALAsset *asset in info) {
            [self uploadOneImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage] thumbImage:[UIImage imageWithCGImage:asset.thumbnail]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSelectedPhotoUI];
            [self.sponser dismissViewControllerAnimated:YES completion:nil];
            
            //放在这里避免提前pop导致页面闪一下，如果不popToRoot,会有Unbalanced calls warning
            [self.imagePickerController popToRootViewControllerAnimated:NO];
            [SportProgressView dismiss];
        });
        
    });
}

-(void)uploadOneImage:(UIImage *)photoImage
           thumbImage:(UIImage *)thumbImage
{
    UploadPostPhoto *uploadPhoto = [[UploadPostPhoto alloc]init];
    NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    
    UIImage *newPhotoImage = [photoImage compressWithMaxLenth:640];
    UIImage *newThumbImage = [thumbImage compressWithMaxLenth:320];
    
    uploadPhoto.timestamp = timestamp;
    uploadPhoto.uploadState = UploadStateNewlyAdd;
    uploadPhoto.photoImage = newPhotoImage;
    uploadPhoto.thumbImage = newThumbImage;
    uploadPhoto.isDelete = NO;
    [self.selectedPhotoList addObject:uploadPhoto];
    
    //[NSThread detachNewThreadSelector:@selector(uploadSelectedImage:) toTarget:self withObject:uploadPhoto];
    
    [self uploadSelectedImage:uploadPhoto];
    
}

- (void)uploadSelectedImage:(UploadPostPhoto *)uploadPhoto
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([_sponser respondsToSelector:@selector(postSelectedImage:)]){
            [_sponser postSelectedImage:uploadPhoto];
        }
        uploadPhoto.uploadState = UploadStateUploading;
    });
}

-(void) didPostSelectedImageWithStatus:(NSString *)status
                                   key:(NSString *)key
                              attachId:(NSString *)photoId
                              imageUrl:(NSString *)imageUrl
                              thumbUrl:(NSString *)thumbUrl {
    UploadPostPhoto *uploadPhoto = [self getUploadPhotoWithTimeStamp:key];
    if (uploadPhoto == nil) {
        HDLog(@"Parse UploadPostPhoto Error!");
        
        return;
    }
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        HDLog(@"Upload success!");
        uploadPhoto.uploadState = UploadStateUploadSuccess;
        uploadPhoto.photoId = photoId;
        uploadPhoto.photoImageUrl = imageUrl;
        uploadPhoto.photoThumbUrl = thumbUrl;
    }else {
        HDLog(@"Upload failed!");
        uploadPhoto.uploadState = UploadStateUploadFailed;
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_ALERT_DELETE:
            if (buttonIndex != alertView.cancelButtonIndex) {
                if (self.selectedIndex < [self.selectedPhotoList count]) {
                    UploadPostPhoto *photo = [self.selectedPhotoList objectAtIndex:self.selectedIndex];
                    
                    //如果上传成功，则调用接口删除，但是不管是否删除成功
                    if (photo.uploadState == UploadStateUploadSuccess){
                        [self deleteSelectedImage:photo];
                    }
                    
                    //无论如何，都直接从数组中删除
                    [self.selectedPhotoList removeObject:photo];
                }
                
                //保证显示与实际一致，不显示被删除的图片
                [self updateSelectedPhotoUI];
                
            }
            break;
        default:
            break;
    }
}

-(void) uploadFailedAndRetry {
    for (UploadPostPhoto *uploadPhoto in self.selectedPhotoList) {
        if (uploadPhoto.uploadState == UploadStateUploadFailed) {
            [self uploadSelectedImage:uploadPhoto];
        }
    }
}

-(void) updateSelectedPhotoUI
{
    if([_sponser respondsToSelector:@selector(updatePhotoUI)]){
        [_sponser updatePhotoUI];
    }
}

- (void)deleteSelectedImage:(UploadPostPhoto *)uploadPhoto
{
    if (uploadPhoto.photoId == nil) {
        HDLog(@"attach id is nil");
        return;
    }
    
    if([_sponser respondsToSelector:@selector(deleteImageWithAttachId:)]){
        [_sponser deleteImageWithAttachId:uploadPhoto.photoId];
    }
}

-(void)cleanPhotoManager
{
    for (UploadPostPhoto *photo in self.selectedPhotoList) {
        [self deleteSelectedImage:photo];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addPost) object:nil];
}

// 2s重试一次，在30s内重试15次
#define DELAY_RETRY_TIME 2.0f
#define MAX_RETRY_COUNT 30/DELAY_RETRY_TIME
-(void) addPost
{
    if ([self canAddPost] == NO) {
        HDLog(@"Can not AddPost!");
        if (self.retryCount > MAX_RETRY_COUNT) {
            [SportProgressView dismissWithError:@"发布失败，请重新发布"];
            [self stopRetry];
            self.retryCount = 0;
            return;
        }
        
        [SportProgressView showWithStatus:@"正在上传" hasMask:YES];
        self.retryCount++;
        
        if([self respondsToSelector:@selector(addPost)]){
            [self performSelector:@selector(addPost) withObject:nil afterDelay:DELAY_RETRY_TIME];
        }
        return;
    }
    
    self.retryCount = 0;
    
    NSMutableString *attachIds = nil;
    if ([self.selectedPhotoList count] > 0) {
        attachIds = [NSMutableString stringWithString:@""];
        int index = 0;
        for (UploadPostPhoto *photo in _selectedPhotoList) {
            if (index > 0) {
                [attachIds appendFormat:@",%@", photo.photoId];
            } else {
                [attachIds appendFormat:@"%@", photo.photoId];
            }
            
            index ++;
        }
    }
    
    if([_sponser respondsToSelector:@selector(addPostWithAttachIds:)]){
        [_sponser addPostWithAttachIds:attachIds];
    }
}

-(void) stopRetry {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addPost) object:nil];
}

-(BOOL) canAddPost
{
    //检查是否有发送失败的照片，如果有，重试后再发
    TotalUploadStatus status =[self getUploadPhotoStatus];
    if (status == TotalUploadStatusFailed) {
        
        [self uploadFailedAndRetry];
        
        return NO;
        // 如果有正在上传，继续等待上传完成
    } else if (status == TotalUploadStatusPending){
        return NO;
    }
    
    return YES;
}


@end