//
//  CoachConversationViewController.m
//  Sport
//
//  Created by 江彦聪 on 15/7/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ConversationViewController.h"
#import "UIViewController+SportNavigationItem.h"
#import "SportColor.h"
#import "UserInfoController.h"
#import "CoachIntroductionController.h"
#import "SportImagePickerController.h"
#import "DateUtil.h"
#import "TipNumberManager.h"
#import "RongService.h"
#import "UIViewController+SportNavigationItem.h"
#import "EditUserInfoController.h"
#import "UserManager.h"

@interface ConversationViewController ()<SportImagePickerControllerDelegate>

@property (strong, nonatomic) SportImagePickerController *imagePickerController;

@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation ConversationViewController

-(id)init
{
    self = [super init];
    if (self) {
        //self.hidesBottomBarWhenPushed = YES;
        
        [self setMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
        if (iPhone6Plus) {
            [self setMessagePortraitSize:CGSizeMake(56, 56)];
        } else {
            HDLog(@"iPhone6 %d", iPhone6);
            [self setMessagePortraitSize:CGSizeMake(46, 46)];
        }
    }
    
    return self;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    if (_titleLabel == nil) {
        [self createTitleView];
    }
    self.titleLabel.text = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.enableSaveNewPhotoToLocalSystem = YES;
    self.enableNewComingMessageIcon = YES;
    
    //如果是单聊，不显示发送方昵称
    if (self.conversationType == ConversationType_PRIVATE) {
        self.displayUserNameInCell = NO;
    }
    
    [self createBackButton];
    [self cleanRightTopButton];
    
    //去掉VOIP
    [self.pluginBoardView removeItemWithTag:1004];
    [self.conversationMessageCollectionView setBackgroundColor:[SportColor defaultPageBackgroundColor]];
    //[self.pluginBoardView removeItemAtIndex:3];
    /***********如何自定义面板功能***********************
     自定义面板功能首先要继承RCConversationViewController，如现在所在的这个文件。
     然后在viewDidLoad函数的super函数之后去编辑按钮：
     插入到指定位置的方法如下：
     [self.pluginBoardView insertItemWithImage:imagePic
     title:title
     atIndex:0
     tag:101];
     或添加到最后的：
     [self.pluginBoardView insertItemWithImage:imagePic
     title:title
     tag:101];
     删除指定位置的方法：
     [self.pluginBoardView removeItemAtIndex:0];
     删除指定标签的方法：
     [self.pluginBoardView removeItemWithTag:101];
     删除所有：
     [self.pluginBoardView removeAllItems];
     更换现有扩展项的图标和标题:
     [self.pluginBoardView updateItemAtIndex:0 image:newImage title:newTitle];
     或者根据tag来更换
     [self.pluginBoardView updateItemWithTag:101 image:newImage title:newTitle];
     以上所有的接口都在RCPluginBoardView.h可以查到。
     
     当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
     pluginBoardView:clickedItemWithTag:
     在super之后加上自己的处理。
     
     */
//    NSInteger count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
//    
//    if ([[RongService defaultService] checkRongReady]) {
//        [[TipNumberManager defaultManager] setImReceiveMessageCount:count];
//    } else {
//        [[TipNumberManager defaultManager] setImReceiveMessageCount:0];
//    }
    //默认输入类型为语音
    //self.defaultInputType = RCChatSessionInputBarInputVoice;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage
{
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message
{
    return message;
}

- (void)didTapCellPortrait:(NSString *)userId
{
    if ([userId length] > 2 && [[userId substringToIndex:2] isEqualToString:@"c_"]) {
        NSString *coachId = [userId substringFromIndex:2];
        CoachIntroductionController *controller = [[CoachIntroductionController alloc] initWithCoachId:coachId];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        User *me = [[UserManager defaultManager] readCurrentUser];
        if ([userId isEqualToString:me.userId]) {
            EditUserInfoController *controller = [[EditUserInfoController alloc] initWithUser:me levelTitle:me.rulesTitle];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            UserInfoController *controller = [[UserInfoController alloc] initWithUserId:userId];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}


- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
   
    switch (tag) {
        case PLUGIN_BOARD_ITEM_ALBUM_TAG:
            //封装的选择图片方法
            [self selectPhoto];
        break;
        default:
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
    }
}

-(void)selectPhoto
{
    
    self.imagePickerController = [[SportImagePickerController alloc]initWithDelegate:self
                                                             numberOfPhotoCanBeAdded:9];
    self.imagePickerController.isMultipleMode = YES;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    
}

#pragma mark - SportImagePickerControllerDelegate methods
- (void)sportImagePickerController:(SportImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
//    [SportProgressView showWithStatus:@"请稍候"];
     __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
        //放在这里避免提前pop导致页面闪一下，如果不popToRoot,会有Unbalanced calls warning
        [weakSelf.imagePickerController popToRootViewControllerAnimated:NO];
        //[SportProgressView dismiss];
    });
    
    //上传压缩较耗时，放到其他线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        for (ALAsset *asset in info) {
            RCImageMessage *imagemsg = [RCImageMessage messageWithImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
            
            [weakSelf sendImageMessage:imagemsg pushContent:nil];
            [NSThread sleepForTimeInterval:0.5];
        }
        
    });
}

/**
 *  将要显示会话消息，可以修改RCMessageBaseCell的头像形状，添加自定定义的UI修饰，建议不要修改里面label 文字的大小，cell 大小是根据文字来计算的，如果修改大小可能造成cell 显示出现问题
 *
 *  @param cell      cell
 *  @param indexPath indexPath
 */
-(void)willDisplayConversationTableCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.messageTimeLabel.text = [DateUtil messageDetailTimeString:[NSDate dateWithTimeIntervalSince1970:cell.model.sentTime / 1000] formatter:nil];
    
    if ([cell isKindOfClass:[RCMessageCell class]]) {
        RCMessageCell *msgCell = (RCMessageCell *)cell;
        [(UIImageView *)msgCell.portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    
    if ([cell isMemberOfClass:[RCTextMessageCell class]]) {
        RCTextMessageCell *textCell=(RCTextMessageCell *)cell;
        
        // 更改字体的颜色
        if (textCell.model.messageDirection == MessageDirection_SEND) {
            textCell.textLabel.textColor=[UIColor whiteColor];
            [textCell.bubbleBackgroundView setImage:[UIImage imageNamed:@"chatToBg"]];
        } else {
            textCell.textLabel.textColor=[UIColor blackColor];
            
            [textCell.bubbleBackgroundView setImage:[UIImage imageNamed:@"chatFromBg"]];
        }
        
        //自定义气泡图片的适配
        UIImage *image=textCell.bubbleBackgroundView.image;
        textCell.bubbleBackgroundView.image=[textCell.bubbleBackgroundView.image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,image.size.height * 0.2, image.size.width * 0.8)];
    }
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
