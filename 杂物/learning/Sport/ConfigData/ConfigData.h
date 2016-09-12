//
//  ConfigData.h
//  Sport
//
//  Created by haodong  on 13-8-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 上线注意:
 1.更改Sport-Info.plist的版本号(即Bundle versions string, short 和 Bundle version)更改为最新版本号，开发者证书换成正式的证书
 2.更改defaultHost的值为http://api.7yundong.cn
 3.更改forumHost的值为http://forum.api.7yundong.cn
 4.融云的key改为"tdrvipksr86v5"
 5.极光推送设置tag的时候把前缀Test_去掉。
 */

//测试环境
#warning 上正式版时记得切换服务器
#define API_SERVER_ADDRESS @"http://api.qydw.net"
#define GS_API_SERVER_ADDRESS @"http://api.qydtest.com"
#define FORUM_SERVER_ADDRESS @"http://forum.api.qydw.net"
#define RONGCLOUD_IM_APPKEY @"k51hidwq1mahb"
#define JPUSH_SETTAG_PREFIX @"Test_"

//生产环境
//#define API_SERVER_ADDRESS @"http://api.7yundong.cn"
//#define GS_API_SERVER_ADDRESS @"https://api.quyundong.com"
//#define FORUM_SERVER_ADDRESS @"http://forum.api.7yundong.cn"
//#define RONGCLOUD_IM_APPKEY @"tdrvipksr86v5"
//#define JPUSH_SETTAG_PREFIX @""

#define SPORT_DES_KEY   yi1g41gbicb74uci1u()
#define SPORT_DES_IV    feuyug1347hfjfh13j()



//#define SHARESDK_KEY        @"5c5ebe57b3d"

#define UMENG_CHANNEL_ID    nil  //在友盟中用nil表示渠道是App Store
//#define UMENG_CHANNEL_ID  @"91"
//#define UMENG_CHANNEL_ID  @"pp"
//#define UMENG_CHANNEL_ID  @"tongbutui"

//api渠道的值
#define API_CHANNEL @"appstore"

#define APP_ID              @"717619906"

#define SINA_KEY            @"632776414"
#define SINA_SECRET         @"d7e2237d0a8a8c2052ffbcdd4cd156f2"
#define SINA_REDIRECT_URI   @"https://api.weibo.com/oauth2/default.html"

#define QQ_APP_ID  @"100556060"

#define WEIXIN_APP_ID       @"wxf041d5b3c4e45ea2"
#define WEIXIN_APP_SECRET   @"30ccbf0f66986d8a3b11bde403870d86"
#define WEIXIN_PAY_SIGN_KEY @"gojSuJRUsjjZA5hW0obVQR5It1Ktp55qP26pfd8H17hizgFloQqtR9Jfcti0GvFU92pBfrnmHZCHh7qAueeXWXIt2dBPjYp9FGUDhG7c4wg945bEJEvU22prbvj8khyo"
#define WEIXIN_PARTNER_ID   @"1218664801"
#define WEIXIN_PARTNER_KEY  @"b893e5da0305cad7331fd71580e2591b"

#define UMENG_KEY           @"51f9574456240b1bbf02f61d"

#define ALIPAY_CALL_BACK_SCHEME  @"alipaysport.qiuhaodong.gz"

#define AppleMechantId @"merchant.com.sport.ningmi"

#define ALIPAY_PARTNER @"2088411769633778"
#define ALIPAY_SELLER  ALIPAY_PARTNER
#define ALIPAY_RSA_PRIVATE_KEY @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBANyHbGUprUG3SnUzDYz/aBtONvsOVnzo3bAQz+o7+P75Nnxrd9IURkJzwnhmAbKpcVRmPJDmam6xE654CQ6FBne5Fhq/9ARma8TtxCiUrW4UhG/IzKLmfsPMH1JdlhfkbLbEFpLCTn6Ug0TA8rKdj9GTJM9kTs48KuOWxseCnMG7AgMBAAECgYAvhtAJjU3Vl9boIzSMao7ZM6YNvS1OhjEgvL7SUFJ9QOBJOC/+ingJ4kDLCdDb3ECcW9w5ri7J5EfFlgD9rBWUWRRcx7PHNLJgxsA1SWfmgNp7aJnFVGJijBfD6T3UeT2EfShZPC4m+junD7oXnwPpOB4HOWuBsE5PJBPV9c8PoQJBAP9zNXWFyOf2xa3XNDcrYnGmjOaMe/xjtIBGYX3jP2X7Xrd+HQktUfPte+x1muu8yzryvt2hdQkcut+1P7cGLuUCQQDdAPfG+giXAYybCoi+tb13flNZWQ6pAVdjuxIPlwv8fEKc7eUTHTO5sfa79mXnHu3EKaqZn3HH06k3Mh5sA4QfAkBbQ1fYEuICLaHWR8p542AaZnx0acBqHV0BbyOpjCS8VKA0QjQxcSWUVkYt5p5glmStPMh/+g0MIl2JSwHma6kZAkBxdEm/ECTQwK7Z+PJyVQJLEcLgH2PzRwkB3ctLzZMNrwzTWx06Tsd7EO1FWRy/JZWSGoHGE6BpoTNBbq1HbhapAkA5Iu5bub37h45eLYKPVrHw0rviLyRjbHn2hrk7X081MJ1K+OZunhUSj9QR6/JJ0SDXqxjB8CaXW+FBGC/8LTJl"

//支付宝公钥是所有应用都一样的
#define ALIPAY_ALIPAY_PUBLIC_KEY @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

////以下是2013-07-24集成需要的参数值
//#define ALIPAY_PARTNER @"2088011503932882"
//#define ALIPAY_SELLER  ALIPAY_PARTNER
//#define ALIPAY_RSA_PRIVATE_KEY @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAOHCTakjS808Vclow+4GPKvybiP9k12S2DyA60QP5zrPCXrBRan7rlFrzNW99d/K7hIBHg8bp27MtXvwlEiy2NT7R7u8fBhQwKxQ8UzMuF0vJZdH3k0TRJtNSVHw9kmsTFlvRZc2BfvxkzPe2/rw/fHGV1X6c8LNCKefPqaDi6KfAgMBAAECgYEAnOX4KUOBi/qRuG+aM9Ob2PicuWCjSVYj+DC00VGoJ0P6V5j4/IERDj84VZg2yDj1qgeix2c1vxiATMnPlJLPhC9zO+nWT6zpSyNeIJfUyrmh18/JHi820oh/yrFnl28wRJs2l8IZ4NlDoSk30aegC2/mZVIKJsy7vvmkarCWJOkCQQD2/wjQ/uGAGdZclV91J5TO8aXFQOPW3N/48nCVpW7P5iF0+a/eQhndB5Yc/MkfDbUFOpMyQgN5P/0Uza+m41LNAkEA6f0VV1uYOU6NoBajEQUHoJVUF2iYQuntkeTdslT1dt2LYl2l4b2sNNDkmYzNrQkUcxasLHOMWuEq+WUKjP+DGwJARSlOn67vF76kXpJZA2YM7hGOGHi+E5kPghbo3Y5QRBitf6K20yZxNYn9R6qk6nQdHxSyyNzhOh9nz1508+ctdQJAF8VwX5mck2XZmYPzOQ1rwvKowmAL5/BgBExeAXoEHflP6cRdz9s3HX6DWt4lHwknHLIW98UdYzYw6XlMYxqqNQJAaxcXNmOvBmBjvH3qCFWgr7LCkqwG7IuzI2yV13y91dLw2dMT8bKHPbbrXve741qtsFfTFf7Cr7FldlemBEI/jA=="
//#define ALIPAY_ALIPAY_PUBLIC_KEY @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCD9ecHz6t+gPjDZK2IfehBETCqGD2jAKP720UFyFJxAII+AYN0MV6cDmvuVuJ/XoIrowj18WG3HZJo3Qunz4E5uXjngJYLmNZOB750jiawXBso5HzlLYuEsjO01za7uBVQP2f+t4xMYnE6PYoQHXYDIXWcI5m7paA24PZEGvtDGQIDAQAB"


/*****以下是友盟在线参数名称*****/

//#define UMENG_ONLINE_INTERFACE_HOST           @"interface_host"       //弃用
//#define UMENG_ONLINE_APP_VERSION              @"app_version"          //弃用
//#define UMENG_ONLINE_INTERFACE_HOST_1_1       @"interface_host_1_1"   //从1.1版本开始使用, 从1.30开始弃用
//#define UMENG_ONLINE_OPENFIRE_IP              @"openfire_ip"          //弃用

#define UMENG_ONLINE_BUSINESS_COOPERATION       @"business_cooperation"
#define UMENG_ONLINE_SHARE_APP_TEXT             @"share_app_text"
#define UMENG_ONLINE_WEBSITE                    @"website"
#define UMENG_ONLINE_CUSTOMER_SERVICE_PHONE     @"customer_service_phone"
#define UMENG_ONLINE_IS_SHOW_LEMON_MALL         @"is_show_lemon_mall"
#define UMENG_ONLINE_IS_SHOW_THIRD_PARTY_LOGIN  @"is_show_third_party_login"
#define UMENG_ONLINE_IN_REVIEW_APP_VERSION      @"in_review_app_version"
#define UMENG_ONLINE_IS_CHECK_NEW_VERSION       @"is_check_new_version"
#define UMENG_ONLINE_IS_USE_HUPU_ANALYSIS       @"is_use_hupu_analysis"

/*****友盟在线参数名称结束*****/

#define iPhone6                                                                \
([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
? CGSizeEqualToSize(CGSizeMake(750, 1334),                              \
[[UIScreen mainScreen] currentMode].size)           \
: NO)
#define iPhone6Plus                                                            \
([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
? CGSizeEqualToSize(CGSizeMake(1242, 2208),                             \
[[UIScreen mainScreen] currentMode].size)           \
: NO)

//高德地图key
#define GAODE_APP_KEY @"0cf2ca4494b55caaec7d75d8de051428"

//JPush key
#define JPUSH_APP_KEY @"253a2cd0cc05751377b83f14"
#define JPUSH_CHANNEL @"appstore"

@interface ConfigData : NSObject
+ (NSString *)gsDefaultHost;
+ (NSString *)defaultHost;
+ (NSString *)defaultAppKey;
+ (NSString *)forumHost;
+ (NSString *)businessCooperation;
+ (NSString *)shareAppText;
+ (NSString *)website;
+ (NSString *)customerServicePhone;
+ (BOOL)isShowThirdPartyLogin;
//+ (BOOL)currentVersionIsInReView;
+ (BOOL)isCheckNewVersion;

@end

NSString *yi1g41gbicb74uci1u();
NSString *feuyug1347hfjfh13j();
