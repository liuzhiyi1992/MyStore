//
//  ImprovePersonalInfoController.m
//  Sport
//
//  Created by lzy on 16/6/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "ImprovePersonalInfoController.h"
#import "UserService.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "UserManager.h"
#import "UIButton+WebCache.h"
#import "ZYKeyboardUtil.h"

NSString * const GENDER_SIGN_MALE = @"m";
NSString * const GENDER_SIGN_FEMALE = @"f";
NSString * const MSG_NICK_NAME_EMPTY = @"请输入您的昵称";
NSString * const NOTIFICATION_NAME_UPDATE_COURT_JOIN_SHARE_CONTENT = @"NOTIFICATION_NAME_UPDATE_COURT_JOIN_SHARE_CONTENT";

#define MAX_POST_LENGTH 30
#define TAG_BUTTON_MALE 100
#define TAG_BUTTON_FEMALE 101

@interface ImprovePersonalInfoController () <UserServiceDelegate, UserServiceDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *signatureTextView;
@property (strong, nonatomic) UIButton *lastGenderButton;
@property (strong, nonatomic) NSString *gender;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UILabel *textCountLabel;
@property (strong, nonatomic) ZYKeyboardUtil *zyKeyboardUtil;
@end

@implementation ImprovePersonalInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"完善个人信息";
    [self configureView];
}

- (void)configureView {
    //textField
    _nameTextField.layer.borderColor = [UIColor hexColor:@"e6e6e6"].CGColor;
    _nameTextField.layer.borderWidth = 0.5f;
    _signatureTextView.layer.borderWidth = 0.5f;
    _signatureTextView.layer.borderColor = [UIColor hexColor:@"e6e6e6"].CGColor;
    _nameTextField.delegate = self;
    _signatureTextView.delegate = self;
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    //avatar
    if (user.avatarUrl.length > 0) {
        [_avatarButton sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl] forState:UIControlStateNormal];
    }
    
    //nickName
    _nameTextField.text = user.nickname;
    _signatureTextView.text = user.signture;
    _textCountLabel.text = [NSString stringWithFormat:@"%d", (MAX_POST_LENGTH - (int)_signatureTextView.text.length)];
    
    //gender 默认男性
    if ([user.gender isEqualToString:GENDER_FEMALE]) {
        [self clickGenderButton:_femaleButton];
    } else {
        [self clickGenderButton:_maleButton];
    }
    
    self.zyKeyboardUtil = [[ZYKeyboardUtil alloc] init];
    __weak typeof(self) weakSelf = self;
    [_zyKeyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.nameTextField, weakSelf.signatureTextView, nil];
    }];
}

- (IBAction)clickUpdateAvatarButton:(id)sender {
    [self updateAvatar];
}

- (void)didUpLoadAvatar:(NSString *)status avatar:(NSString *)avatar point:(int)point
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [MobClickUtils event:umeng_event_court_join_modify_avatar];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_UPDATE_COURT_JOIN_SHARE_CONTENT object:nil userInfo:@{PARA_AVATAR:avatar}];
        [SportProgressView dismissWithSuccess:DDTF(@"kSubmitSuccess")];
        [_avatarButton sd_setImageWithURL:[NSURL URLWithString:avatar] forState:UIControlStateNormal];
        User *user = [[UserManager defaultManager] readCurrentUser];
        [user setAvatarUrl:avatar];
        [[UserManager defaultManager] saveCurrentUser:user];
    } else {
        [SportProgressView dismissWithError:DDTF(@"kSubmitFail")];
    }
}

- (IBAction)clickGenderButton:(UIButton *)sender {
    [_lastGenderButton setImage:[UIImage imageNamed:@"radioButtonUnselected"] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"radio_button_selected_blue"] forState:UIControlStateNormal];
    
    if (sender.tag == TAG_BUTTON_MALE) {
        self.gender = GENDER_SIGN_MALE;
    } else if (sender.tag == TAG_BUTTON_FEMALE) {
        self.gender = GENDER_SIGN_FEMALE;
    }
    self.lastGenderButton = sender;
}


- (IBAction)clickSubmitButton:(id)sender {
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (![_nameTextField.text isEqualToString:user.nickname]) {
        [MobClickUtils event:umeng_event_court_join_modify_nickname];
    } else if (![_signatureTextView.text isEqualToString:user.signture]) {
        [MobClickUtils event:umeng_event_court_join_modify_sign];
    }
    
    if (_nameTextField.text.length == 0) {
        [SportPopupView popupWithMessage:MSG_NICK_NAME_EMPTY];
        return;
    }
    
    if ([_nameTextField.text length] > 10) {
        [SportPopupView popupWithMessage:DDTF(@"kNickNameCannotLongerThan10")];
        return;
    }
    
    
    [self validTextViewInput:_signatureTextView];
    [SportProgressView showWithStatus:@"更新中" hasMask:YES];
    [UserService updateUserInfo:self userId:user.userId nickName:_nameTextField.text birthday:nil gender:_gender age:0 signature:_signatureTextView.text interestedSport:nil interestedSportLevel:0 cityId:nil sportPlan:nil latitude:0 longitude:0];
}

- (void)updateAvatar {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:DDTF(@"kCancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:DDTF(@"kSelectFromAlbum"), DDTF(@"kTakePhoto"), nil];
    
    [sheet showInView:self.view];
}

- (void)selectPhoto
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
}

- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        
        //picker.modalPresentationStyle = UIModalPresentationFullScreen;
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        float cameraAspectRatio = 4.0 / 3.0;
        float imageHeight = screenSize.width * cameraAspectRatio;
        float verticalAdjustment;
        if (screenSize.height - imageHeight <= 54.0f) {
            verticalAdjustment = 0;
        } else {
            verticalAdjustment = (screenSize.height - imageHeight) / 2.0f;
            verticalAdjustment /= 2.0f; // A little bit upper than centered
        }
        CGAffineTransform transform = picker.cameraViewTransform;
        transform.ty += verticalAdjustment;
        picker.cameraViewTransform = transform;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
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

#define MAX_LEN_CUSTOM 640.0
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *infoKey = UIImagePickerControllerEditedImage;
    UIImage *image = [info objectForKey:infoKey];
    //[picker dismissModalViewControllerAnimated:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (image != nil){
        [NSThread detachNewThreadSelector:@selector(handleImage:) toTarget:self withObject:image];
    }
}

- (void)handleImage:(UIImage *)image {
    CGFloat maxLen = (image.size.width > image.size.height ? image.size.width : image.size.height);
    CGSize newSize;
    if (maxLen > MAX_LEN_CUSTOM) {
        CGFloat mul = MAX_LEN_CUSTOM / maxLen;
        if (maxLen == image.size.width) {
            newSize = CGSizeMake(MAX_LEN_CUSTOM, image.size.height * mul);
        }else {
            newSize = CGSizeMake(image.size.width * mul, MAX_LEN_CUSTOM);
        }
    } else {
        newSize = image.size;
    }
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self useSelectedBgImage:newImage];
    });
}

- (void)useSelectedBgImage:(UIImage *)image {
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:DDTF(@"kSubmitting") hasMask:YES];
    [UserService upLoadAvatar:self
                       userId:user.userId
                  avatarImage:image];
}

- (void)validTextViewInput:(UITextView *)textView {
    NSString *toBeString = textView.text;
    if (toBeString.length > MAX_POST_LENGTH) {
        textView.text = [toBeString substringToIndex:MAX_POST_LENGTH];
        [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_POST_LENGTH]];
    }
    int restNumber = MAX_POST_LENGTH - (int)[textView.text length];
    _textCountLabel.text = [@(restNumber) stringValue];
}

- (void)didUpdateUserInfo:(NSString *)status point:(int)point {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"更新成功"];
        User *user = [[UserManager defaultManager] readCurrentUser];
        user.nickname = _nameTextField.text;
        user.gender = _gender;
        user.signture = _signatureTextView.text;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    if (nil == selectedRange) {
        [self validTextViewInput:textView];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_signatureTextView resignFirstResponder];
    [_nameTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
