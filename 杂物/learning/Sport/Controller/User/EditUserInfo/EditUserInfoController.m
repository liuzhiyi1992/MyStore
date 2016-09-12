//
//  EditUserInfoController.m
//  Sport
//
//  Created by haodong  on 13-7-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "EditUserInfoController.h"
#import "SportProgressView.h"
#import "User.h"
#import "UserManager.h"
#import "EditNicknameController.h"
#import "EditGenderController.h"
#import "UIView+Utils.h"
#import "EidtFavoriteSportsController.h"
#import "CircleProjectManager.h"
#import "SportProgressView.h"
#import "UserLevelCell.h"
#import "PostHolderView.h"
#import "UserPostListController.h"
#import "SportWebController.h"

typedef enum
{
    EditImageTypeAlbum = 0,
    EditImageTypeEquipment = 1,
    EditImageTypeAvatar = 2,
} EditImageType;

@interface EditUserInfoController ()
@property (strong, nonatomic) EditUserInfoCell *myEditUserInfoCell;
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) EditImageType addEditImageType;
@property (assign, nonatomic) EditImageType deleteEditImageType;
@property (copy, nonatomic) NSString *selectedDeletePhotoId;
@property (strong, nonatomic) PostHolderView *postHolderCell;
@property (copy, nonatomic) NSString *levelTitle;

@property (copy, nonatomic) NSString *nickName;
@property (assign, nonatomic) NSInteger age;
@property (copy, nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *cityId;
@property (copy, nonatomic) NSString *cityName;
@property (copy, nonatomic) NSString *signture;
@property (copy, nonatomic) NSString *likeSport;
@property (assign, nonatomic) NSInteger likeSportLevel;
@property (copy, nonatomic) NSString *sportPlan;

@end

@implementation EditUserInfoController

#define TITLE_AVATAR            @"头像"
#define TITLE_MY_LEVEL          @"我的等级"
#define TITLE_NICK_NAME         @"昵称"
#define TITLE_AGE               @"年龄"
#define TITLE_GENDER            @"性别"
#define TITLE_CITY              @"城市"
#define TITLE_SIGNTURE          @"签名"
#define TITLE_LIKE_SPORT        @"喜欢运动"
#define TITLE_SPORT_PLAN        @"运动计划"
#define TITLE_ALBUM             @"相册"
#define TITLE_EQUIPMENT         @"运动装备"
#define TITLE_POST              @"帖子"

- (void)viewDidUnload {
    [self setDataTableView:nil];
    [self setPickHolderView:nil];
    [self setDatePickerView:nil];
    [self setCancelButton:nil];
    [self setOkButton:nil];
    [super viewDidUnload];
}



- (instancetype)initWithUser:(User *)user levelTitle:(NSString *)levelTitle
{
    self = [super init];
    if (self) {
        self.user = user;
        self.levelTitle = levelTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的资料";
    
    NSArray *firstList = [NSArray arrayWithObjects:TITLE_AVATAR, nil];
    NSArray *secondList = [NSArray arrayWithObjects:TITLE_MY_LEVEL, nil];
    NSArray *thirdList = [NSArray arrayWithObjects:TITLE_NICK_NAME, TITLE_GENDER, TITLE_CITY, TITLE_SIGNTURE, nil];
    NSArray *fourthList = [NSArray arrayWithObjects:TITLE_POST, nil];
    if([self.user.rulesIsDisplay isEqualToString:@"1"]) {
        self.dataList = [NSArray arrayWithObjects:firstList, secondList, thirdList, fourthList, nil];
    }else {
        self.dataList = [NSArray arrayWithObjects:firstList, thirdList, fourthList, nil];
    }
    
    
//    self.dataList = [NSArray arrayWithObjects:TITLE_AVATAR, TITLE_NICK_NAME, TITLE_AGE, TITLE_GENDER, TITLE_CITY, TITLE_SIGNTURE, TITLE_LIKE_SPORT, TITLE_SPORT_PLAN, TITLE_ALBUM, TITLE_EQUIPMENT,nil];
    
    
    if (_user == nil) {
        self.user = [[UserManager defaultManager] readCurrentUser];
    }
    
    [self.cancelButton setBackgroundImage:[SportImage filterButtonImage] forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:[SportImage filterButtonImage] forState:UIControlStateNormal];
    self.pickHolderView.hidden = YES;
    
    self.nickName = _user.nickname;
    self.age = _user.age;
    self.gender = _user.gender;
    self.cityId = _user.cityId;
    self.cityName = _user.cityName;
    self.signture = _user.signture;
    self.likeSport = _user.likeSport;
    self.likeSportLevel = _user.likeSportLevel;
    self.sportPlan = _user.sportPlan;
    
    [self.dataTableView updateOriginY:-10];
    
    //为了更新帖子
    [self queryData];
    
    [MobClickUtils event:umeng_event_enter_edit_user_info];
}

- (BOOL)handleGestureNavigate
{
    [self clickBackButton:nil];
    return NO;
}

#define TAG_ALERTVIEW_BACK              2014050701
#define TAG_ALERTVIEW_DELETE_PHOTO      2014050702
- (void)clickBackButton:(id)sender
{
    BOOL isChange = NO;
    if (_nickName && [_nickName isEqualToString:_user.nickname] == NO) {
        isChange = YES;
    }
    if (_age != _user.age) {
        isChange = YES;
    }
    if (_gender && [_gender isEqualToString:_user.gender] == NO) {
        isChange = YES;
    }
    if (_cityId && [_cityId isEqualToString:_user.cityId] == NO) {
        isChange = YES;
    }
    if (_signture && [_signture isEqualToString:_user.signture] == NO) {
        isChange = YES;
    }
    if (_likeSport && [_likeSport isEqualToString:_user.likeSport] == NO) {
        isChange = YES;
    }
    if (_likeSportLevel != _user.likeSportLevel) {
        isChange = YES;
    }
    if (_sportPlan && [_sportPlan isEqualToString:_user.sportPlan] == NO) {
        isChange = YES;
    }

    if (isChange){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的资料已修改,点击确定保存"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERTVIEW_BACK;
        [alertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_BACK) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self submitData];
        }
    } else if (alertView.tag == TAG_ALERTVIEW_DELETE_PHOTO) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            [self deletePhoto];
        }
    }
}

- (void)deletePhoto
{
    [SportProgressView showWithStatus:@"正在删除"];
    [UserService deleteGallery:self
                         userId:_user.userId
                        photoId:_selectedDeletePhotoId
                           type:_deleteEditImageType];
}

- (void)didDeleteGallery:(NSString *)status
                    type:(int)type
                 photoId:(NSString *)photoId
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if (type == EditImageTypeAlbum) {
            [_user deleteAlumb:photoId];
        } else if (type == EditImageTypeEquipment) {
            [_user deleteEquipment:photoId];
        }
        [self.dataTableView reloadData];
    }
}

- (void)queryData {
    [UserService queryUserProfileInfo:self userId:_user.userId];
}

- (void)submitData
{
    CLLocation *location = [[UserManager defaultManager] readUserLocation];
    [SportProgressView showWithStatus:@"正在提交"];
    [UserService updateUserInfo:self
                         userId:_user.userId
                       nickName:_nickName
                       birthday:nil
                         gender:_gender
                            age:_age
                      signature:_signture
                interestedSport:_likeSport
           interestedSportLevel:_likeSportLevel
                         cityId:_cityId
                      sportPlan:_sportPlan
                       latitude:location.coordinate.latitude
                      longitude:location.coordinate.longitude];
}

- (void)didUpdateUserInfo:(NSString *)status point:(int)point
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        if (point > 0) {
            [SportProgressView dismissWithSuccess:[NSString stringWithFormat:@"成功完善资料!获得%d积分", point] afterDelay:2];
        } else {
            [SportProgressView dismissWithSuccess:@"更新成功"];
        }
        
        _user.nickname = _nickName;
        _user.gender = _gender;
        _user.age = _age;
        _user.signture = _signture;
        _user.likeSport = _likeSport;
        _user.likeSportLevel = _likeSportLevel;
        _user.cityId = _cityId;
        _user.sportPlan = _sportPlan;
        
        [UserService queryUserProfileInfo:nil userId:_user.userId];
        
    } else{
        [SportProgressView dismissWithError:@"更新失败"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_dataTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = [_dataList objectAtIndex:section];
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    
    NSString *cellTitle = [list objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [list count] - 1 ? YES : NO);
    
    //相册
    if ([cellTitle isEqualToString:TITLE_ALBUM]
        || [cellTitle isEqualToString:TITLE_EQUIPMENT]) {
        NSString *identifier = [EditImageListCell getCellIdentifier];
        EditImageListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [EditImageListCell createCell];
            cell.delegate = self;
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        if ([cellTitle isEqualToString:TITLE_ALBUM]) {
            NSMutableArray *list = [NSMutableArray array];
            for (UserPhoto *photo in _user.albumList) {
                [list addObject:photo.photoThumbUrl];
            }
            [cell updateCellWith:cellTitle
                    imageUrlList:list
                       indexPath:indexPath
                          isLast:isLast];
        } else {
            
            NSMutableArray *list = [NSMutableArray array];
            for (UserPhoto *photo in _user.equipmentList) {
                [list addObject:photo.photoThumbUrl];
            }
            
            [cell updateCellWith:cellTitle
                    imageUrlList:list
                       indexPath:indexPath
                          isLast:isLast];
        }
        return cell;
    }
    
    //头像
    else if ([cellTitle isEqualToString:TITLE_AVATAR]) {
        NSString *identifier = [EditAvatarCell getCellIdentifier];
        EditAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [EditAvatarCell createCell];
            cell.delegate = self;
        }
        [cell updateCellWithAvatarUrl:_user.avatarUrl];
        return cell;
    }
    
    //等级
    else if([cellTitle isEqualToString:TITLE_MY_LEVEL]) {
        NSString *identifier = [UserLevelCell getCellIdentifier];
        UserLevelCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil) {
            cell = [UserLevelCell createCell];
        }
        [cell updateCellWithRulesTitle:self.levelTitle rulesIconUrl:_user.rulesIconUrl];
        return cell;
    }
    
    //帖子
    else if([cellTitle isEqualToString:TITLE_POST]) {
        NSString *identifier = [PostHolderView getCellIdentifier];
        PostHolderView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil) {
            cell = [PostHolderView creatViewWithStatus:YES
                                                 count:[@(self.user.postCount) stringValue]
                                              imageUrl:[NSURL URLWithString:self.user.lastPost.coverImageUrl]
                                               content:self.user.lastPost.content];
        }
        cell.delegate = self;
        self.postHolderCell = cell;
        return cell;
    }
    
    //其他
    else {
        NSString *identifier = [EditUserInfoCell getCellIdentifier];
        EditUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [EditUserInfoCell createCell];
            cell.delegate = self;
        }
        
        NSString *cellValue = [self valueWithCellTitle:cellTitle];;
        
        [cell updateCellWith:cellTitle
                       value:cellValue
                   indexPath:indexPath
                      isLast:isLast];
        return cell;
    }
    
}

- (NSString *)valueWithCellTitle:(NSString *)cellTitle
{
    NSString *cellValue = nil;
    if ([cellTitle isEqualToString:TITLE_NICK_NAME]) {
        cellValue = _nickName;
    }
    else if ([cellTitle isEqualToString:TITLE_AGE]) {
        if (_age > 0) {
            cellValue = [NSString stringWithFormat:@"%d岁", (int)_age];
        } else {
            cellValue = nil;
        }
    }
    else if ([cellTitle isEqualToString:TITLE_GENDER]) {
        if ([_gender isEqualToString:GENDER_MALE]) {
            cellValue = @"男";
        } else if ([_gender isEqualToString:GENDER_FEMALE]) {
            cellValue = @"女";
        } else {
            cellValue = @"";
        }
    }
    else if ([cellTitle isEqualToString:TITLE_CITY]) {
        cellValue = _cityName;
    }
    else if ([cellTitle isEqualToString:TITLE_SIGNTURE]) {
        cellValue = _signture;
    }
    else if ([cellTitle isEqualToString:TITLE_LIKE_SPORT]) {
        if ([_likeSport length] > 0) {
            NSString *levelString  = nil;
            if (_likeSportLevel == 0) {
                levelString = @"未知";
            } else {
                levelString = [Activity sportLevelName:_likeSportLevel];
            }
            cellValue = [NSString stringWithFormat:@"%@:%@", _likeSport, levelString];
        } else {
            cellValue = nil;
        }
    }
    else if ([cellTitle isEqualToString:TITLE_SPORT_PLAN]) {
        cellValue = _sportPlan;
    }
    
    return cellValue;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *cellTitle = [list objectAtIndex:indexPath.row];
    
    if ([cellTitle isEqualToString:TITLE_ALBUM]
        || [cellTitle isEqualToString:TITLE_EQUIPMENT]) {
        return [EditImageListCell getCellHeight];

    } else if ([cellTitle isEqualToString:TITLE_AVATAR]) {
        return [EditAvatarCell getCellHeight];
    
    } else if ([cellTitle isEqualToString:TITLE_POST]) {
        return [PostHolderView getCellHeight];
        
    } else if([cellTitle isEqualToString:TITLE_MY_LEVEL]) {
        return [UserLevelCell getCellHeight];
    } else {
        if (self.myEditUserInfoCell == nil) {
            self.myEditUserInfoCell = [EditUserInfoCell createCell];
        }
        [self.myEditUserInfoCell updateCellWith:cellTitle
                                          value:[self valueWithCellTitle:cellTitle]
                                      indexPath:indexPath
                                         isLast:NO];
        return _myEditUserInfoCell.frame.size.height;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero] ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#define TAG_SPORT_PLAN  10
#define TAG_SIGNTURE    11
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *cellTitle = [list objectAtIndex:indexPath.row];
    
    if ([cellTitle isEqualToString:TITLE_AVATAR]) {
        [MobClickUtils event:umeng_event_user_info_edit_click_avatar];
        [self updateAvatar];
    }
    
    else if([cellTitle isEqualToString:TITLE_MY_LEVEL]) {
        SportWebController *webController = [[SportWebController alloc] initWithUrlString:_user.rulesUrl title:nil];
        [self.navigationController pushViewController:webController animated:YES];
    }
    
    else if ([cellTitle isEqualToString:TITLE_NICK_NAME]) {
        [MobClickUtils event:umeng_event_user_info_edit_click_nickname];
        EditNicknameController *controller = [[EditNicknameController alloc] initWithNickname:_nickName] ;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    else if ([cellTitle isEqualToString:TITLE_AGE]) {
        [self showAgeSelectView];
    }
    
    else if ([cellTitle isEqualToString:TITLE_GENDER]) {
        [MobClickUtils event:umeng_event_user_info_edit_click_gender];
        EditGenderController *controller = [[EditGenderController alloc] initWithGender:_gender] ;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    else if ([cellTitle isEqualToString:TITLE_CITY]) {
        [MobClickUtils event:umeng_event_user_info_edit_click_city];
        [self showCityList];
    }
    
    else if ([cellTitle isEqualToString:TITLE_SIGNTURE]) {
        [MobClickUtils event:umeng_event_user_info_edit_click_signture];
        EditSportPlanController *controller = [[EditSportPlanController alloc] initWithContent:_signture tag:TAG_SIGNTURE] ;
        controller.delegate = self;
        controller.title = @"个性签名";
        controller.maxLength = 30;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    else if ([cellTitle isEqualToString:TITLE_LIKE_SPORT]) {
        [self showLikeSportPicker];
    }
    
    else if ([cellTitle isEqualToString:TITLE_SPORT_PLAN]) {
        EditSportPlanController *controller = [[EditSportPlanController alloc] initWithContent:_sportPlan tag:TAG_SPORT_PLAN] ;
        controller.delegate = self;
        controller.title = @"运动计划";
        controller.maxLength = 30;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)didFinishEditNickName:(NSString *)nickName
{
    self.nickName = nickName;
    [self.dataTableView reloadData];
}

- (void)didClickEditSportPlanControllerBackButton:(NSString *)content tag:(int)tag
{
    if (tag == TAG_SPORT_PLAN) {
        self.sportPlan = content;
    } else if (tag == TAG_SIGNTURE) {
        self.signture = content;
    }
    
    [self.dataTableView reloadData];
}

- (void)didSelectGender:(NSString *)gender
{
    self.gender = gender;
    [self.dataTableView reloadData];
}

#pragma mark - update avatar
- (void)updateAvatar
{
    self.addEditImageType = EditImageTypeAvatar;
    [self showEditImageActionSheet];
}

- (void)showEditImageActionSheet
{
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

#pragma mark -- UIImagePickerControllerDelegate
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
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

- (void)useSelectedBgImage:(UIImage *)image
{
    if (_addEditImageType == EditImageTypeAvatar) {
        [SportProgressView showWithStatus:DDTF(@"kSubmitting")];
        [UserService upLoadAvatar:self
                           userId:_user.userId
                      avatarImage:image];
    }
//    else if (_addEditImageType == EditImageTypeAlbum) {
//        [SportProgressView showWithStatus:DDTF(@"kSubmitting")];
//        [UserService upLoadGallery:self
//                            userId:_user.userId
//                             image:image
//                              type:0
//                               key:nil];
//    } else if (_addEditImageType == EditImageTypeEquipment) {
//        [SportProgressView showWithStatus:DDTF(@"kSubmitting")];
//        [UserService upLoadGallery:self
//                            userId:_user.userId
//                             image:image
//                              type:1
//                               key:nil];
//    }
}

- (void)didUpLoadAvatar:(NSString *)status avatar:(NSString *)avatar point:(int)point
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        if (point > 0) {
            [SportProgressView dismissWithSuccess:[NSString stringWithFormat:@"头像上传成功!获得%d积分", point] afterDelay:2];
        } else {
            [SportProgressView dismissWithSuccess:DDTF(@"kSubmitSuccess")];
        }
        HDLog(@"avatar:%@", avatar);
        [_user setAvatarUrl:avatar];
        [[UserManager defaultManager] saveCurrentUser:_user];
        [self.dataTableView reloadData];
    } else {
        [SportProgressView dismissWithError:DDTF(@"kSubmitFail")];
    }
}

#pragma mark - update age
- (void)showAgeSelectView
{
    NSMutableArray *ageList = [NSMutableArray array];
    for (int i = 0  ; i < 80; i ++) {
        [ageList addObject:[NSString stringWithFormat:@"%d岁", i + 12]];
    }
    SportPickerView *view  = [SportPickerView createSportPickerView];
    view.delegate = self;
    view.dataList = ageList;
    [view show];
}

- (void)didClickSportPickerViewOKButton:(SportPickerView *)sportPickerView row:(NSInteger)row
{
    self.age = row + 12;
    [self.dataTableView reloadData];
}

#pragma mark - update likesport
- (void)showLikeSportPicker {
    [SportStartAndEndTimePickerView popupPickerWithDelegate:self dataArray:[self willShowList]];
}

- (NSArray *)willShowList
{
    NSMutableArray *nameList = [NSMutableArray array];
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        [nameList addObject:pro.proName];
    }
    
    NSMutableArray *levelList = [NSMutableArray array];
    for (int i = 1; i < 5 ; i ++) {
        [levelList addObject:[Activity sportLevelName:i]];
    }
    
    NSArray *list = [NSArray arrayWithObjects:nameList, levelList, nil];
    
    return list;
}

- (void)didClickSportStartAndEndTimePickerViewOKButton:(SportStartAndEndTimePickerView *)sportPickerView
{
    NSInteger nameRow = [sportPickerView.dataPickerView selectedRowInComponent:0];
    NSInteger levelRow = [sportPickerView.dataPickerView selectedRowInComponent:1];
    
    CircleProject *pro = [[[CircleProjectManager defaultManager] circleProjectList] objectAtIndex:nameRow];
    
    self.likeSport = pro.proName;
    self.likeSportLevel = levelRow + 1;
    
    [self.dataTableView reloadData];
}

#pragma mark - 用户城市
- (void)showCityList
{
    UserCityListView *view = [UserCityListView createUserCityListView];
    view.delegate = self;
    [view show];
}

- (void)didSelectUserCity:(City *)city
{
    self.cityId = city.cityId;
    self.cityName = city.cityName;
    [self.dataTableView reloadData];
}

- (void)didClickEditImageListCellImage:(NSIndexPath *)indexPath
                            imageIndex:(NSInteger)imageIndex
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *title = [list objectAtIndex:indexPath.row];
    if ([title isEqualToString:TITLE_ALBUM]) {
        UserPhoto *phonto = [_user.albumList objectAtIndex:imageIndex];
        self.deleteEditImageType = EditImageTypeAlbum;
        self.selectedDeletePhotoId = phonto.photoId;
        [self showDeletePhotoAlertView];
    } else {
        UserPhoto *phonto = [_user.equipmentList objectAtIndex:imageIndex];
        self.deleteEditImageType = EditImageTypeEquipment;
        self.selectedDeletePhotoId = phonto.photoId;
        [self showDeletePhotoAlertView];
    }
}

- (void)showDeletePhotoAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"确定删除该图片?"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    alertView.tag = TAG_ALERTVIEW_DELETE_PHOTO;
    [alertView show];
}

- (void)didClickEditImageListCellAddButton:(NSIndexPath *)indexPath
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *title = [list objectAtIndex:indexPath.row];
    if ([title isEqualToString:TITLE_ALBUM]) {
        self.addEditImageType = EditImageTypeAlbum;
        [self showEditImageActionSheet];
    } else if ([title isEqualToString:TITLE_EQUIPMENT]) {
        self.addEditImageType = EditImageTypeEquipment;
        [self showEditImageActionSheet];
    }
}

- (void)didUpLoadGallery:(NSString *)status
                    type:(int)type
                thumbUrl:(NSString *)thumbUrl
                imageUrl:(NSString *)imageUrl
                 photoId:(NSString *)photoId
                     key:(NSString *)key
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"添加成功"];
        UserPhoto *photo = [[UserPhoto alloc] init];
        photo.photoId = photoId;
        photo.photoImageUrl = thumbUrl;
        photo.photoThumbUrl = thumbUrl;
        if (type== EditImageTypeAlbum) {
            [_user addPhotoToAlumb:photo];
        } else if (type== EditImageTypeEquipment) {
            [_user addPhotoToEquipment:photo];
        }
        [self.dataTableView reloadData];
    } else{
        [SportProgressView dismissWithError:@"添加失败"];
    }
}

#pragma mark PostHolderView Delegate
- (void)postHolderViewDidClickedWithTitle:(NSString *)title {
    [MobClickUtils event:umeng_event_user_detail_click_post];
    
    UserPostListController *controller = [[UserPostListController alloc] initWithUserId:self.user.userId] ;
    controller.title = title;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didQueryUserProfileInfo:(User *)user status:(NSString *)status msg:(NSString *)msg {
    
    if([status isEqualToString:STATUS_SUCCESS]) {
        
        //更新帖子信息
        NSURL *imageUrl = [NSURL URLWithString:user.lastPost.coverImageUrl];
        [self.postHolderCell updateViewWithCount:[@(user.postCount) stringValue] imageUrl:imageUrl content:user.lastPost.content];
    }else {
        
    }
}

@end
