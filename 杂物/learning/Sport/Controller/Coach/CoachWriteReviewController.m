//
//  CoachWriteReviewController.m
//  Sport
//
//  Created by 江彦聪 on 15/7/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachWriteReviewController.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "UserService.h"
#import "BusinessPhoto.h"
#import "SportPopupView.h"

@interface CoachWriteReviewController ()<CoachServiceDelegate,UserServiceDelegate>

@end

@implementation CoachWriteReviewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.imageNoticeLabel.hidden = YES;

}

//复用BusinessId为CoachId
-(void)queryDataWithId:(NSString *)businessId
                  text:(NSString *)text
                userId:(NSString *)userId
           commentRank:(int)commentRank
               orderId:(NSString *)orderId
            galleryIds:(NSString *)galleryIds
{
    [CoachService sendCoachComment:self coachId:businessId text:text userId:userId commentRank:commentRank orderId:orderId galleryIds:galleryIds];
}


-(void)didSendCoachComment:(NSString *)status msg:(NSString *)msg
{
    if([status isEqualToString:STATUS_SUCCESS])
    {
        [SportProgressView dismissWithSuccess:@"评价成功"];
        
        [self performSelector:@selector(popController) withObject:nil afterDelay:1];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

-(void)uploadGallery:(UIImage *)image
                 key:(NSString *)key
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    __weak __typeof(self)weakSelf = self;

    [UserService upLoadCommonGallery:self userId:user.userId image:image key:key completion:^(NSString *status,NSString* thumbUrl,NSString *imageUrl,NSString *photoId,NSString *key){
        [weakSelf didUpLoadGallery:status type:2 thumbUrl:thumbUrl imageUrl:imageUrl photoId:photoId key:key];
    }];
    
}

-(void)popController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deletePhoto:(NSString *)photoId
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [UserService deleteCommonGallery:self
                              userId:user.userId
                             photoId:photoId];
}

#define MAX_POST_LENGTH 140
- (void)textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    
    NSString *toBeString = textView.text;
    
    UITextRange *selectedRange = [textView markedTextRange];
    
    //获取高亮部分
    UITextPosition *position = nil;
    if (selectedRange) {
        position = [self.contentTextView positionFromPosition:selectedRange.start offset:0];
    }
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (toBeString.length > MAX_POST_LENGTH) {
            textView.text = [toBeString substringToIndex:MAX_POST_LENGTH];
            [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_POST_LENGTH]];
        }
    }
    // 有高亮选择的字符串，则暂不对文字进行统计和限制
    else{
        
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
