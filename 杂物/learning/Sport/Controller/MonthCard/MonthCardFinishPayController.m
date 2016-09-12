//
//  MonthCardFinishPayController.m
//  Sport
//
//  Created by 江彦聪 on 15/6/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardFinishPayController.h"
#import "UIViewController+SportNavigationItem.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+normalized.h"
#import "BusinessPhoto.h"
#import "MonthCardFinishPayController.h"
#import "MonthCardRechargeController.h"
#import "SportImagePickerController.h"

@interface MonthCardFinishPayController ()<SportImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *uploadFinishButton;
@property (weak, nonatomic) IBOutlet UIView *secondBuyView;
@property (weak, nonatomic) IBOutlet UIView *firstBuyView;
@property (weak, nonatomic) IBOutlet UIView *cardPlaceHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewHeightConstraint;
@property (strong, nonatomic) SportImagePickerController *imagePickerController;
@property (strong, nonatomic) MonthCardHomeHeaderView *headerView;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalConstrainit;

@property (strong, nonatomic) MonthCard *card;
@end

@implementation MonthCardFinishPayController

-(MonthCard *)card
{
    if (_card == nil) {
        [MonthCardService getMonthCardInfo:self userId:self.user.userId];
    }
    
    return _card;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createRightTopButton:@"完成"];
    // Do any additional setup after loading the view from its nib.
    
    self.firstBuyView.hidden = YES;
    self.secondBuyView.hidden = YES;
    self.uploadFinishButton.hidden = YES;
    
    self.user = [[UserManager defaultManager] readCurrentUser];
    if (self.user.userId == nil) {
        //此处程序不应该走入，所以只作简单处理
        [SportPopupView popupWithMessage:@"请先登录"];
        HDLog(@"Error! no user id");
        return;
    }
    
    [self queryData];
}

-(void)queryData
{
    [SportProgressView showWithStatus:@"请稍候"];
    [MonthCardService getMonthCardInfo:self userId:self.user.userId];
}

#pragma mark didGetMonthCardInfo
-(void)didGetMonthCardInfo:(MonthCard *)card status:(NSString *)status msg:(NSString *)msg
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.card = card;
        
        [self.uploadFinishButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
        self.uploadFinishButton.layer.cornerRadius = 5.0f;
        self.uploadFinishButton.layer.masksToBounds = YES;
        
        CGFloat y = 0;
        if ([card.avatarThumbURL isEqualToString:@""]) {
            self.title = @"设置头像";
            [self.uploadFinishButton setTitle:@"上传头像" forState:UIControlStateNormal];
            self.uploadFinishButton.hidden = NO;
            self.firstBuyView.hidden = NO;
            self.secondBuyView.hidden = YES;
        } else {
            self.title = @"购买成功";
            self.uploadFinishButton.hidden = YES;
            self.firstBuyView.hidden = YES;
            self.secondBuyView.hidden = NO;
            y = y - 20;
        }
        
        [self.view layoutIfNeeded];
        
        if (self.headerView == nil) {
            self.headerView = [MonthCardHomeHeaderView createView];
            self.headerView.delegate = self;
        }
        
        CGFloat height = [self.headerView getCardHeightWithBounds:self.cardPlaceHolderView.bounds];
        self.headerView.frame = CGRectMake(0, self.cardPlaceHolderView.frame.origin.y +y, self.cardPlaceHolderView.frame.size.width, height);
        [self.view insertSubview:self.headerView belowSubview:self.uploadFinishButton];
        [self.headerView updateViewWithFinishBuyCard:card];
        self.cardViewHeightConstraint.constant = height;
    }
    
    if (card == nil) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

-(void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_month_set_portrait_click_finish];
    
    //跳到上上一页
    if (self.card && [self.card.avatarImageURL isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请先上传你的头像" delegate:self cancelButtonTitle:@"稍候上传" otherButtonTitles:@"确定", nil];
        alert.tag = TAG_UPLOAD_AVATAR;
        [alert show];
        return;
    }
    
    [self popToPreviousControllerOfMonthCardRechargeController];
}

-(void)clickBackButton:(id)sender
{
    [self clickRightTopButton:nil];
}

#pragma mark Alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_UPLOAD_AVATAR) {
        if (buttonIndex != alertView.cancelButtonIndex){
            [self showEditImageActionSheet];
        } else {
            [self popToPreviousControllerOfMonthCardRechargeController];
        }
    }
}

-(void)popToPreviousControllerOfMonthCardRechargeController
{
    NSUInteger targetIndex = [self previousControllerIndexOfMonthCardRechargeController];
    if (targetIndex < [self.navigationController.viewControllers count]) {
        UIViewController *targetController = [self.navigationController.viewControllers objectAtIndex:targetIndex];
        if (targetController) {
            [self.navigationController popToViewController:targetController animated:YES];
        }
    }
}

- (IBAction)clickUploadFinishButton:(id)sender {
    [self showEditImageActionSheet];
}

#pragma mark HeaderViewDelegate
-(void)didClickAvatarButton
{
    [self showEditImageActionSheet];
}

- (void)showEditImageActionSheet
{
    [MobClickUtils event:umeng_event_month_set_portrait_click_upload];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:DDTF(@"kCancel")
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:DDTF(@"kSelectFromAlbum"), DDTF(@"kTakePhoto"), nil];
    
    [sheet showInView:self.view];
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.allowsEditing = YES;
        picker.delegate = self;
        //[self presentModalViewController:picker animated:YES];
        [self presentViewController:picker animated:YES completion:nil];
     }

//    self.imagePickerController = [[SportImagePickerController alloc]initWithDelegate:self
//                                                             numberOfPhotoCanBeAdded:1];
//    self.imagePickerController.isMultipleMode = NO;
//    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark -- UIImagePickerControllerDelegate
#define MAX_LEN_CUSTOM 640.0  //原来是100
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *infoKey = UIImagePickerControllerEditedImage;
    //NSString *infoKey = UIImagePickerControllerOriginalImage;
    
    UIImage *image = [info objectForKey:infoKey];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (image != nil){
        
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            //保存图片
            UIImageWriteToSavedPhotosAlbum(image, self,
                                           nil, nil);
        }
        
        [SportProgressView showWithStatus:@"请稍候"];
        [self uploadSelectedImage:image];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:
(NSError *)error contextInfo:(void *)contextInfo;
{
    // Handle the end of the image write process
}

-(void)uploadSelectedImage:(UIImage *)photo
{
    UIImage *newThumbImage = [photo compressWithMaxLenth:320];

    [MonthCardService uploadAvatar:self userId:self.user.userId image:newThumbImage];
}

-(void)didUploadAvatar:(BusinessPhoto *)photo
                status:(NSString *)status
                   msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self queryData];
        self.card.avatarThumbURL = photo.photoThumbUrl;
        self.card.avatarImageURL = photo.photoImageUrl;
        self.card.cardStatus = CARD_STATUS_VALID;
        
        self.uploadFinishButton.hidden = YES;
        
        [self.headerView updateViewWithFinishBuyCard:self.card];
        
    } else {
        [SportProgressView dismissWithError:msg];
    }

}
#pragma mark - SportImagePickerControllerDelegate methods
- (void)sportImagePickerController:(SportImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    if ([info count] == 0) {
        return;
    }
    
    [SportProgressView showWithStatus:@"请稍候"];

    ALAsset *asset = [info firstObject];
    
    //上传压缩较耗时，放到其他线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            [self uploadSelectedImage:[UIImage imageWithCGImage:asset.thumbnail]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
            
            //放在这里避免提前pop导致页面闪一下，如果不popToRoot,会有Unbalanced calls warning
            [self.imagePickerController popToRootViewControllerAnimated:NO];

        });
    });
}

- (NSUInteger)previousControllerIndexOfMonthCardRechargeController
{
    NSUInteger count = [self.navigationController.viewControllers count];
    
    //默认是上一个页面
    NSUInteger index = count - 2;
    SportController *controller = nil;
    for (controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[MonthCardRechargeController class]]) {
            
            NSUInteger rechargeIndex = [self.navigationController.viewControllers indexOfObject:controller];
            
            //指定RechargeController的上一个页面
            index = rechargeIndex - 1;
            break;
        }
    }
    
    return index;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
