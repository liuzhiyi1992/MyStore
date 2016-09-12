//
//  UserService.h
//  Sport
//
//  Created by haodong  on 13-6-6.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
#import "SportUUID.h"


typedef enum
{
    VerifyPhoneTypeQuickLogin = 1, //快速登录
    VerifyPhoneTypeForgotPassword = 2,     //用于忘记密码，一定要有人使用了此号码，否则提示此号码没注册
    VerifyPhoneTypeBind = 3,     //用于绑定手机号码，如果服务器已经有人使用此号码，则返回失败提示此号码已被注册。和第1种不同的是，绑定手机时是连同user_id一起发送给服务器
    VerifyPhoneTypeRegiser = 4,  //用于注册，如果服务器已经有人使用此号码，则返回失败提示此号码已被注册
    VerifyPhoneTypeMembershipCard = 5, //用于绑定会员卡
    VerifyPhoneTypeForgotPayPassword = 6, // 忘记支付密码
    VerifyPhoneTypeBindUnionLogin = 7,
} VerifyPhoneType;


@class User;
@class Voucher;

@protocol UserServiceDelegate <NSObject>

@optional

- (void)didRegisterUser:(NSString *)userId
                 status:(NSString *)status
                    msg:(NSString *)msg;

- (void)didUnionLogin:(NSString *)status
                  msg:(NSString *)msg
                 data:(NSDictionary *)data
               openId:(NSString *)openId
              unionId:(NSString *)unionId
          accessToken:(NSString *)accessToken
             openType:(NSString *)openType
               avatar:(NSString *)avatar
             nickName:(NSString *)nickName
               gender:(NSString *)gender;

- (void)didUnionPhone:(NSString *)status
                  msg:(NSString *)msg;

- (void)didLogin:(NSString *)userId
          status:(NSString *)status
             msg:(NSString *)msg
           phone:(NSString *)phone;

- (void)didLogout:(NSString *)status;

- (void)didUpdateUserInfo:(NSString *)status point:(int)point;

- (void)didUpdateMyLocation:(NSString *)status;

- (void)didUpLoadAvatar:(NSString *)status
                 avatar:(NSString *)avatar
                  point:(int)point;

- (void)didBindPhone:(NSString *)status;

- (void)didUnionBindWithStatus:(NSString *)status msg:(NSString *)msg;

- (void)didResetPassword:(NSString *)status;

- (void)didChangePassword:(NSString *)status;

//- (void)didQueryMyComments:(NSArray *)commentList
//                    status:(NSString *)status;

- (void)didQueryUserProfileInfo:(User *)user
                         status:(NSString *)status
                            msg:(NSString *)msg;

- (void)didQureyCommentCount:(NSUInteger)count
                      status:(NSString *)status;

- (void)didUpLoadGallery:(NSString *)status
                    type:(int)type
                thumbUrl:(NSString *)thumbUrl
                imageUrl:(NSString *)imageUrl
                 photoId:(NSString *)photoId
                     key:(NSString *)key;

- (void)didDeleteGallery:(NSString *)status
                   type:(int)type
                photoId:(NSString *)photoId;

- (void)didUpLoadCommonGallery:(NSString *)status
                      thumbUrl:(NSString *)thumbUrl
                      imageUrl:(NSString *)imageUrl
                       photoId:(NSString *)photoId
                           key:(NSString *)key;

- (void)didDeleteCommonGallery:(NSString *)status
                      photoId:(NSString *)photoId;


- (void)didReportUser:(NSString *)status msg:(NSString *)msg;

- (void)didGetSystemMessage:(NSString *)status
                        msg:(NSString *)msg
                      count:(int)count;

- (void)didGetSystemMessageList:(NSString *)status
                            msg:(NSString *)msg
                    messageList:(NSArray *)messageList;

//- (void)didUpdatePushToken:(NSString *)status;

- (void)didAddVoucher:(NSString *)status
                  msg:(NSString *)msg
              voucher:(Voucher *)voucher;

- (void)didUploadIapReceiptData:(NSString *)status
                            msg:(NSString *)msg
                       integral:(int)integral;

- (void)didBindVoucherAndOrder:(NSString *)status
                           msg:(NSString *)msg
                        amount:(double)amount;

- (void)didAddSharePhone:(NSString *)status
                     msg:(NSString *)msg
                    type:(NSString *)type;

- (void)didGetMessageCountList:(NSString *)status
                           msg:(NSString *)msg;

- (void)didUpdateMessageCount:(NSString *)status
                          msg:(NSString *)msg;

- (void)didGetSMSCode:(NSString *)status
                  msg:(NSString *)msg;

- (void)didGetSMSCode:(NSString *)status
                  msg:(NSString *)msg
               length:(int) length;

- (void)didVerifySMSCode:(NSString *)status
                    msg:(NSString *)msg;

- (void)didQuickLogin:(NSString *)status
                  msg:(NSString *)msg;

- (void)didSetPassword:(NSString *)status
                   msg:(NSString *)msg;

- (void)didGetUserMoneyLog:(NSString *)status
                       msg:(NSString *)msg
                recordList:(NSArray *)recordList;

- (void)didResetPayPassword:(NSString *)status msg:(NSString *)msg;

- (void)didChangePayPassword:(NSString *)status msg:(NSString *)msg;

- (void)didSetPayPassword:(NSString *)status
                   msg:(NSString *)msg;

- (void)didVerifyPayPassword:(NSString *)status
                         msg:(NSString *)msg
                 payPassword:(NSString *)payPassword;

- (void)didGetUserInfo:(User *)user
                status:(NSString *)status
                   msg:(NSString *)msg;

- (void)didUserBalance:(double)balance
                status:(NSString *)status
                   msg:(NSString *)msg;

- (void)didUserIntegral:(int)integral
                 status:(NSString *)status
                    msg:(NSString *)msg;

- (void)didGetSystemMessageCategory:(NSString *)status
                                msg:(NSString *)msg
                               list:(NSArray *)list;

- (void)didGetSystemMessageCategoryMessage:(NSString *)status
                                msg:(NSString *)msg
                               list:(NSArray *)list
                                      page:(int)page;

- (void)didSubmitSurveyShareField:(NSString *)status
                              msg:(NSString *)msg
                           resMsg:(NSString *)resMsg;


@end


@interface UserService : NSObject
//@property (assign, nonatomic) id<UserServiceDelegate> delegate;

//2015-01-29弃用此接口
//- (void)queryVerification:(id<UserServiceDelegate>)delegate
//              phoneNumber:(NSString *)phoneNumber
//                     type:(VerifyPhoneType)type;

+ (User *)userByDictionary:(NSDictionary *)resultDictionary;

+ (void)registerUser:(id<UserServiceDelegate>)delegate
         phoneNumber:(NSString *)phoneNumber
            password:(NSString *)password
             smsCode:(NSString *)smsCode;

+ (void)unionLogin:(id<UserServiceDelegate>)delegate
            openId:(NSString *)openId
           unionId:(NSString *)unionId
       accessToken:(NSString *)accessToken
          openType:(NSString *)openType
          nickName:(NSString *)nickName
            gender:(NSString *)gender
            avatar:(NSString *)avatar;

+ (void)unionPhone:(id<UserServiceDelegate>)delegate
          phoneNum:(NSString *)phoneNum
           smsCode:(NSString *)smsCode
            openId:(NSString *)openId
           unionId:(NSString *)unionId
       accessToken:(NSString *)accessToken
          openType:(NSString *)openType
            avatar:(NSString *)avatar
          nickName:(NSString *)nickName
            gender:(NSString *)gender;

+ (void)bindPhone:(id<UserServiceDelegate>)delegate
           userId:(NSString *)userId
      phoneNumber:(NSString *)phoneNumber
         password:(NSString *)password
          smsCode:(NSString *)smsCode;

+ (void)unionBind:(id<UserServiceDelegate>)delegate
           userId:(NSString *)userId
           openId:(NSString *)openId
          unionId:(NSString *)unionId
      accessToken:(NSString *)accessToken
         openType:(NSString *)openType
         nickName:(NSString *)nickName;

+ (void)login:(id<UserServiceDelegate>)delegate
  phoneNumber:(NSString *)phoneNumber
     password:(NSString *)password;

+ (void)logout:(id<UserServiceDelegate>)delegate
        userId:(NSString *)userId;

+ (void)resetPassword:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
          phoneNumber:(NSString *)phoneNumber
             password:(NSString *)password
              smsCode:(NSString *)smsCode;

+ (void)changePassword:(id<UserServiceDelegate>)delegate
                userId:(NSString *)userId
           oldPassword:(NSString *)oldPassword
           newPassword:(NSString *)newPassword;

+ (void)updateUserInfo:(id<UserServiceDelegate>)delegate
                userId:(NSString *)userId
              nickName:(NSString *)nickName
              birthday:(NSString *)birthday
                gender:(NSString *)gender
                   age:(NSInteger)age
             signature:(NSString *)signature
       interestedSport:(NSString *)interestedSport
  interestedSportLevel:(NSInteger)interestedSportLevel
                cityId:(NSString *)cityId
             sportPlan:(NSString *)sportPlan
              latitude:(double)latitude
             longitude:(double)longitude;

+ (void)updateMyLocation:(id<UserServiceDelegate>)delegate
                  userId:(NSString *)userId
                latitude:(double)latitude
               longitude:(double)longitude;

+ (void)upLoadAvatar:(id<UserServiceDelegate>)delegate
              userId:(NSString *)userId
         avatarImage:(UIImage *)avatarImage;

+ (void)upLoadGallery:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
                image:(UIImage *)image
                 type:(int)type
                  key:(NSString *)key;

+ (void)deleteGallery:(id<UserServiceDelegate>)delegate
               userId:(NSString *)userId
              photoId:(NSString *)photoId
                 type:(int)type;

+ (NSURLSessionTask *)upLoadCommonGallery:(id<UserServiceDelegate>)delegate
                     userId:(NSString *)userId
                      image:(UIImage *)image
                        key:(NSString *)key
                        completion:(void(^)(NSString *status,NSString* thumbUrl,NSString *imageUrl,NSString *photoId,NSString *key))completion;

+ (void)deleteCommonGallery:(id<UserServiceDelegate>)delegate
                     userId:(NSString *)userId
                    photoId:(NSString *)photoId;

+ (void)queryUserProfileInfo:(id<UserServiceDelegate>)delegate
                      userId:(NSString *)userId;

//+ (void)getSystemMessage:(id<UserServiceDelegate>)delegate
//                  userId:(NSString *)userId;

//+ (void)getSystemMessageList:(id<UserServiceDelegate>)delegate
//                      userId:(NSString *)userId
//                        page:(int)page
//                       count:(int)count;

//上传push token
//+ (void)updatePushToken:(id<UserServiceDelegate>)delegate
//                 userId:(NSString *)userId
//              pushToken:(NSString *)pushToken
//               deviceId:(NSString *)deviceId;

//内购验证
//+ (void)uploadIapReceiptData:(id<UserServiceDelegate>)delegate
//                 receiptData:(NSString *)receiptData
//                      userId:(NSString *)userId
//                 integralKey:(NSString *)integralKey;

+ (void)addSharePhone:(id<UserServiceDelegate>)delegate
                phone:(NSString *)phone
               userId:(NSString *)userId
                 type:(NSString *)type;

+ (void)getMessageCountList:(id<UserServiceDelegate>)delegate
                     userId:(NSString *)userId
                   deviceId:(NSString *)deviceId;

+ (void)updateMessageCount:(id<UserServiceDelegate>)delegate
                    userId:(NSString *)userId
                  deviceId:(NSString *)deviceId
                      type:(NSString *)type
                     count:(NSUInteger)count;

+ (void)getSMSCode:(id<UserServiceDelegate>)delegate
             phone:(NSString *)phone
       phoneEncode:(NSString *)phoneEncode
              type:(VerifyPhoneType)type
          openType:(NSString *)openType;

+ (void)quickLogin:(id<UserServiceDelegate>)delegate
             phone:(NSString *)phone
           SMSCode:(NSString *)SMSCode;

+ (void)setPassword:(id<UserServiceDelegate>)delegate
             userId:(NSString *)userId
           password:(NSString *)password;

+ (void)getUserMoneyLog:(id<UserServiceDelegate>)delegate
                 userId:(NSString *)userId
                   page:(int)page
                  count:(int)count;

+ (void)resetPayPassword:(id<UserServiceDelegate>)delegate
                  userId:(NSString *)userId
             phoneNumber:(NSString *)phoneNumber
                password:(NSString *)payPassword
                 smsCode:(NSString *)smsCode;

+ (void)changePayPassword:(id<UserServiceDelegate>)delegate
                   userId:(NSString *)userId
              oldPassword:(NSString *)oldPayPassword
              newPassword:(NSString *)newPayPassword;

+ (void)setPayPassword:(id<UserServiceDelegate>)delegate
                userId:(NSString *)userId
              password:(NSString *)payPassword;

+ (void)verifyPayPassword:(id<UserServiceDelegate>)delegate
                   userId:(NSString *)userId
                 password:(NSString *)payPassword;

+ (void)verifySMSCode:(id<UserServiceDelegate>)delegate
                phone:(NSString *)phone
          phoneEncode:(NSString *)phoneEncode
              SMSCode:(NSString *)SMSCode
                 type:(VerifyPhoneType)type;

+ (void)getUserInfo:(id<UserServiceDelegate>)delegate
             userId:(NSString *)userId;

+ (void)userBalance:(id<UserServiceDelegate>)delegate
             userId:(NSString *)userId;

+ (void)userIntegral:(id<UserServiceDelegate>)delegate
              userId:(NSString *)userId;

+ (void)getSystemMessageCategory:(id<UserServiceDelegate>)delegate
                      userId:(NSString *)userId;

+ (void)getSystemMessageCategoryMessage:(id<UserServiceDelegate>)delegate
                                 userId:(NSString *)userId
                                   type:(int)type
                                   page:(int)page
                                  count:(int)count;

//+ (void)submitSurveyShareField:(id<UserServiceDelegate>)delegate
//                       orderId:(NSString *)orderId
//                selectedNumber:(NSString *)selectedNumber;

//+ (void)clearMessageCountByType:(id<UserServiceDelegate>)delegate
//                         userId:(NSString *)userId
//                       deviceId:(NSString *)deviceId
//                           type:(NSString *)type;
@end
