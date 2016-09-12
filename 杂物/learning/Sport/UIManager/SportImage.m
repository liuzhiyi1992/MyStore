//
//  SportImage.m
//  Sport
//
//  Created by haodong  on 13-6-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportImage.h"

static NSInteger _globalInterfaceStyle = InterfaceStyleNone;
#define KEY_INTERFACE_STYLE @"KEY_INTERFACE_STYLE"

static SportImage *_globalSportImage = nil;

@implementation SportImage

+ (id)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalSportImage == nil) {
            _globalSportImage = [[SportImage alloc] init];
        }
    });
    return _globalSportImage;
}

+ (BOOL)saveInterfaceStyle:(InterfaceStyle)style
{
    _globalInterfaceStyle = style;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:style forKey:KEY_INTERFACE_STYLE];
    return [defaults synchronize];
}

+ (NSInteger)readInterfaceStyle
{
    if (_globalInterfaceStyle == InterfaceStyleNone) {
        _globalInterfaceStyle = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_INTERFACE_STYLE];
    }
    return _globalInterfaceStyle;
}

//若有不同风格，调此命名方法
+ (NSString *)handleShortName:(NSString *)shortName
{
    switch ([self readInterfaceStyle]) {
        case InterfaceStyleOrange:
            return [NSString stringWithFormat:@"orange__%@", shortName];
        case InterfaceStyleRed:
            return [NSString stringWithFormat:@"red__%@", shortName];
        case InterfaceStyleDefault:
            return shortName;
        default:
            return shortName;
    }
}

/*(1)用imageNamed:@"xxx.png"创建图片,会自动加载xxx@2x.png(高清图),则图片的size是xxx@2x.png的一半,跟xxx.png的大小一样
 (2)用imageWithContentsOfFile:@"xxx.png",不会自动加载xxx@2x.png(高清图)，则return为空,要用imageWithContentsOfFile:@"xxx@2x.png",则图片的size是xxx@2x.png的一半
 (3)为了统一，所有图片命名必须带有@2x
*/
+ (UIImage *)createImage:(NSString *)shortName
{
    if ([shortName length] == 0) {
        return nil;
    }
    NSString *imageName = [[self handleShortName:shortName] stringByAppendingString:@"@2x.png"];
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    if (path == nil) {
        imageName = [shortName stringByAppendingString:@"@2x.png"];
        path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:path];
//    HDLog(@"path:%@", path);
//    HDLog(@"seze:%f,%f",image.size.width, image.size.height);
    return image;
    
//    NSString *imageName = [[self handleShortName:shortName] stringByAppendingString:@".png"];
//    HDLog(@"imageName:%@", imageName);
//    return [UIImage imageNamed:imageName];
}


/********************** use for outside *****************************/
+ (UIImage *)userImage
{
    return [self createImage:@"user"];
}

+ (UIImage *)searchButtonImage
{
    return [self createImage:@"search_button"];
}

+ (UIImage *)homeTitleImage
{
    return [self createImage:@"home_title"];
}

//+ (UIImage *)categoryBackground1Image
//{
//    return [self createImage:@"category_background_1"];
//}
//
//+ (UIImage *)categoryBackground2Image
//{
//    return [self createImage:@"category_background_2"];
//}

+ (UIImage *)filterButtonImage
{
    return [self createImage:@"filter_button"];
}

+ (UIImage *)backButtonImage
{
    return [self createImage:@"back_button"];
}

//+ (UIImage *)navyBlueButtonBackgroundImage
//{
//    return [[self createImage:@"navy_blue_button_background"];
//}

+ (UIImage *)commentButtonImage
{
    return [self createImage:@"comment_button"];
}

+ (UIImage *)categoryTitleImage
{
    return [self createImage:@"category_title"];
}

+ (UIImage *)categorySimpleImage
{
    return [self createImage:@"category_simple"];
}

+ (UIImage *)categorySimpleSelectedImage
{
    return [self createImage:@"category_simple_selected"];
}

+ (UIImage *)bookingSimpleImage
{
    return [self createImage:@"booking_simple"];
}

+ (UIImage *)cellBackgroundImage
{
    return [[self createImage:@"cell_background"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}

+ (UIImage *)cellTopBackgroundImage
{
    return [[self createImage:@"cell_top_background"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
}

+ (UIImage *)characteristicBackgroundImage:(NSUInteger)index
{
    NSArray *nameList = [NSArray arrayWithObjects:@"characteristic_background_1", @"characteristic_background_2", @"characteristic_background_3", @"characteristic_background_4", @"characteristic_background_5", @"characteristic_background_6", @"characteristic_background_7", nil];
    NSUInteger va = index % 7;
    return [[self createImage:[nameList objectAtIndex:va]] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)characteristicBackgroundImage
{
    return [[self createImage:@"characteristic_background"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
}

+ (UIImage *)addressImage
{
    return [self createImage:@"address"];
}

+ (UIImage *)telephoneImage
{
    return [self createImage:@"telephone"];
}

+ (UIImage *)bookDateSelectedImage
{
    return [self createImage:@"book_date_selected"];
}

+ (UIImage *)userCellBackground1Image
{
    return [[self createImage:@"user_cell_background_1"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
}

+ (UIImage *)userCellBackground2Image
{
    return [[self createImage:@"user_cell_background_2"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
}

+ (UIImage *)cellIconFavoritesImage
{
    return [self createImage:@"cell_icon_favorites"];
}

+ (UIImage *)cellIconHistoryImage
{
    return [self createImage:@"cell_icon_history"];
}

+ (UIImage *)cellIconMyMessageImage
{
    return [self createImage:@"cell_icon_my_message"];
}

+ (UIImage *)cellIconSystemMessageImage
{
    return [self createImage:@"cell_icon_system_message"];
}

+ (UIImage *)cellIconOtherImage
{
    return [self createImage:@"cell_icon_other"];
}

+ (UIImage *)cellIconSettingImage
{
    return [self createImage:@"cell_icon_setting"];
}


+ (UIImage *)cellIconPhoneImage
{
    return [self createImage:@"cell_icon_phone"];
}

+ (UIImage *)cellIconShareImage
{
    return [self createImage:@"cell_icon_share"];
}

+ (UIImage *)cellIconAccountManageImage
{
    return [self createImage:@"cell_icon_account_manage"];
}

+ (UIImage *)cellIconJifenImage
{
    return [self createImage:@"cell_icon_jifen"];
}

+ (UIImage *)cellIconBalanceImage
{
    return [self createImage:@"cell_icon_balance"];
}

+ (UIImage *)cellIconVoucherImage
{
    return [self createImage:@"cell_icon_voucher"];
}

+ (UIImage *)avatarBackgroundImage
{
    return [self createImage:@"avatar_background"];
}

//avatar_default_female
+ (UIImage *)avatarDefaultImage
{
    return [UIImage imageNamed:@"defaultAvatar"];
}

+ (UIImage *)avatarDefaultImageWithGender:(NSString *)gender
{
//    if ([gender isEqualToString:@"m"]) {
//        return [self createImage:@"avatar_default_male"];
//    } else {
//        return [self createImage:@"avatar_default_female"];
//    }
    
    return [UIImage imageNamed:@"defaultAvatar"];
}

+ (UIImage *)categoryImage:(NSString *)categoryName isSelected:(BOOL)isSelected
{
    //默认其他，保证有图
    NSString *name = @"CategoryOther";
    if ([self findString:categoryName subString:@"羽毛球"]) {
        name = @"CategoryBadminton2.0";
    }
    else if ([self findString:categoryName subString:@"游泳"]) {
        name = @"CategorySwim2.0";
    }
    else if ([self findString:categoryName subString:@"足球"]) {
        name = @"CategoryFootball2.0";
    }
    else if ([self findString:categoryName subString:@"网球"]) {
        name = @"CategoryTennis";
    }
    else if ([self findString:categoryName subString:@"篮球"]) {
        name = @"CategoryBasketball2.0";
    }
    else if ([self findString:categoryName subString:@"健身"]) {
        name = @"CategoryHealthClub";
    }
    else if ([self findString:categoryName subString:@"保龄球"]) {
        name = @"CategoryBowling2.0";
    }
    else if ([self findString:categoryName subString:@"桌球"]) {
        name = @"CategoryBilliards";
    }
    else if ([self findString:categoryName subString:@"瑜伽"]) {
        name = @"CategoryYoga";
    }
    else if ([self findString:categoryName subString:@"舞蹈"]) {
        name = @"CategoryDance";
    }
    else if ([self findString:categoryName subString:@"高尔夫"]) {
        name = @"CategoryGolf";
    }
    else if ([self findString:categoryName subString:@"武术"]) {
        name = @"CategoryWushu";
    }
    else if ([self findString:categoryName subString:@"其他"]) {
        name = @"CategoryOther";
    }
    else if ([self findString:categoryName subString:@"壁球"]) {
        name = @"CategorySquash";
    }else if ([self findString:categoryName subString:@"射箭"]) {
        name = @"CategoryArchery";
    }
    
    if (isSelected) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@Selected", name]];
    } else {
        return [UIImage imageNamed:name];
    }
}

+ (UIImage *)smallCategoryImage:(NSString *)categoryName
{
    if ([self findString:categoryName subString:@"羽毛球"]) {
        return [self createImage:@"small_category_badminton"];
    }
    else if ([self findString:categoryName subString:@"乒乓球"]) {
        return [self createImage:@"small_category_table_tennis"];
    }
    else if ([self findString:categoryName subString:@"游泳"]) {
        return [self createImage:@"small_category_swim"];
    }
    else if ([self findString:categoryName subString:@"足球"]) {
        return [self createImage:@"small_category_football"];
    }
    else if ([self findString:categoryName subString:@"网球"]) {
        return [self createImage:@"small_category_tennis"];
    }
    else if ([self findString:categoryName subString:@"篮球"]) {
        return [self createImage:@"small_category_basketball"];
    }
    else if ([self findString:categoryName subString:@"健身"]) {
        return [self createImage:@"small_category_health_club"];
    }
    else if ([self findString:categoryName subString:@"保龄球"]) {
        return [self createImage:@"small_category_bowling"];
    }
    else if ([self findString:categoryName subString:@"桌球"]) {
        return [self createImage:@"small_category_billiards"];
    }
    else if ([self findString:categoryName subString:@"瑜伽"]) {
        return [self createImage:@"small_category_yoga"];
    }
    else if ([self findString:categoryName subString:@"舞蹈"]) {
        return [self createImage:@"small_category_table_dance"];
    }
    else if ([self findString:categoryName subString:@"体育"]) {
        return [self createImage:@"small_category_stadiums"];
    }
    else if ([self findString:categoryName subString:@"高尔夫"]) {
        return [self createImage:@"small_category_golf"];
    }
    else if ([self findString:categoryName subString:@"武术"]) {
        return [self createImage:@"small_category_wushu"];
    }
    return nil;
}

+ (UIImage *)mapCategoryImage:(NSString *)categoryName canOrder:(BOOL)canOrder
{
    NSString *name = nil;
    if ([self findString:categoryName subString:@"羽毛球"]) {
        name = @"map_category_badminton";
    }
    else if ([self findString:categoryName subString:@"乒乓球"]) {
        name = @"map_category_table_tennis";
    }
    else if ([self findString:categoryName subString:@"游泳"]) {
        name = @"map_category_swim";
    }
    else if ([self findString:categoryName subString:@"足球"]) {
        name = @"map_category_football";
    }
    else if ([self findString:categoryName subString:@"网球"]) {
        name = @"map_category_tennis";
    }
    else if ([self findString:categoryName subString:@"篮球"]) {
        name = @"map_category_basketball";
    }
    else if ([self findString:categoryName subString:@"健身"]) {
        name = @"map_category_health_club";
    }
    else if ([self findString:categoryName subString:@"保龄球"]) {
        name = @"map_category_bowling";
    }
    else if ([self findString:categoryName subString:@"桌球"]) {
        name = @"map_category_billiards";
    }
    else if ([self findString:categoryName subString:@"瑜伽"]) {
        name = @"map_category_yoga";
    }
    else if ([self findString:categoryName subString:@"舞蹈"]) {
        name = @"map_category_dance";
    }
    else if ([self findString:categoryName subString:@"体育"]) {
        name = @"map_category_stadiums";
    }
    else if ([self findString:categoryName subString:@"高尔夫"]) {
        name = @"map_category_golf";
    }
    else if ([self findString:categoryName subString:@"武术"]) {
        name = @"map_category_wushu";
    }
    else if ([self findString:categoryName subString:@"其他"]) {
        name = @"map_category_other";
    } else {
        name = @"map_category_other";
    }
//   原本是区分灰色和亮色的，2.0.1不区分，所以将原来区分的代码注释了，统一返回亮色
//    if (canOrder) {
//        return [self createImage:[NSString stringWithFormat:@"%@_colorful", name]];
//    } else {
//        return [self createImage:name];
//    }
    return [self createImage:[NSString stringWithFormat:@"%@_colorful", name]];

}

+ (UIImage *)markButtonImage
{
    return [self createImage:@"mark_button"];
}

+ (UIImage *)penImage
{
    return [self createImage:@"pen"];
}

+ (UIImage *)writeButtonImage
{
    //return [self createImage:@"write_button"];
    return [UIImage imageNamed:@"writeButton"];
}

+ (UIImage *)webviewGoBackButtonOnImage
{
    return [self createImage:@"webview_go_back_button_on"];
}

+ (UIImage *)webviewGoBackButtonOffImage
{
    return [self createImage:@"webview_go_back_button_off"];
}

+ (UIImage *)webviewGoForwardButtonOnImage
{
    return [self createImage:@"webview_go_forward_button_on"];
}

+ (UIImage *)webviewGoForwardButtonOffImage
{
    return [self createImage:@"webview_go_forward_button_off"];
}

+ (UIImage *)webviewRefreshButtonOnImage
{
    return [self createImage:@"webview_refresh_button_on"];
}

+ (UIImage *)webviewRefreshButtonOffImage
{
    return [self createImage:@"webview_refresh_button_off"];
}

+ (UIImage *)registerButtonImage
{
    return [self createImage:@"register_button"]; 
}

+ (UIImage *)moreImage
{
    return [self createImage:@"more"]; 
}

+ (UIImage *)businessDefaultImage
{
    //return [self createImage:@"business_default"];
    return [self defaultImage_92x65];
}

+ (UIImage *)appIconImage
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sport_114.png" ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+ (UIImage *)shareRedIcon{
    return [self createImage:@"shareRedIcon"];
}

+ (UIImage *)sinaWeiboImage
{
    return [self createImage:@"sina_weibo"];
}

+ (UIImage *)qqImage
{
    return [self createImage:@"qq"];
}

+ (UIImage *)wechatImage
{
    return [self createImage:@"wechat"];
}

+ (UIImage *)countBackgroundRedImage
{
    //return [[self createImage:@"count_background_red"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    return [self createImage:@"count_background_red"];
}

+ (UIImage *)tipsCountBackgroundWhiteImage
{
    return [[self createImage:@"tips_count_background_white"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)clearButtonImage
{
    return [self createImage:@"clear_button"];
}

+ (UIImage *)manageButtonImage
{
    return [self createImage:@"manage_button"];
}

+ (UIImage *)favoriteSportButtonImage
{
    return [[self createImage:@"favorite_sport_button"] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
}

+ (UIImage *)favoriteSportButtonSelectedImage
{
    return [[self createImage:@"favorite_sport_button_selected"] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
}

+ (UIImage *)alipayLogoImage
{
//    return [self createImage:@"alipay"];
    return [UIImage imageNamed:@"aliPayIcon"];
}

+ (UIImage *)alipayWebLogoImage
{
    return [self createImage:@"alipay_web"];
}

+ (UIImage *)wechatpayLogoImage
{
    return [self createImage:@"wechatpay"];
}

//+ (UIImage *)input1RowBackgroundImage
//{
//    return [[self createImage:@"input_1_row"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
//}

//+ (UIImage *)input2RowBackgroundImage
//{
//    return [[self createImage:@"input_2_row"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
//}

//+ (UIImage *)roundButtonImage
//{
//    return [[self createImage:@"round_button"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
//}



//+ (UIImage *)redButtonImage
//{
//    return [[self createImage:@"red_button"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
//}

//+ (UIImage *)manImage
//{
//    return [self createImage:@"man"];
//}
//
//+ (UIImage *)femaleImage
//{
//    return [self createImage:@"female"];
//}

+ (UIImage *)settingImage
{
    return [self createImage:@"setting"];
}

+ (BOOL)findString:(NSString *)sourceString subString:(NSString *)subString
{
    NSRange range = [sourceString rangeOfString:subString];
    if (range.location == NSNotFound) {
        return NO;
    }
    return YES;
}

+ (UIImage *)orderImage
{
    return [self createImage:@"order"];
}

+ (UIImage *)collectButtonImage
{
//    return [self createImage:@"collect_button"];
    return [UIImage imageNamed:@"CollectIcon"];
}

+ (UIImage *)collectButtonSelectedImage
{
    //return [self createImage:@"collect_button_selected"];
    return [UIImage imageNamed:@"CollectSelectedIcon"];
}

+ (UIImage *)shareButtonImage
{
    return [self createImage:@"share_button"];
}

//+ (UIImage *)otherServiceItemImage:(NSString *)itemId
//{
//    if ([itemId isEqualToString:@"1"]) {
//        return [self createImage:@"other_service_park"];
//    } else if ([itemId isEqualToString:@"2"]) {
//        return [self createImage:@"other_service_park"];
//    } else if ([itemId isEqualToString:@"3"]) {
//        return [self createImage:@"other_service_park"];
//    } else if ([itemId isEqualToString:@"4"]) {
//        return [self createImage:@"other_service_park"];
//    } else if ([itemId isEqualToString:@"5"]) {
//        return [self createImage:@"other_service_park"];
//    } else if ([itemId isEqualToString:@"6"]) {
//        return [self createImage:@"other_service_park"];
//    }
//    
//    return nil;
//}

+ (UIImage *)arrowRightImage
{
    return [self createImage:@"arrow_right"];
}

+ (UIImage *)markImage
{
    return [self createImage:@"mark"];
}

+ (UIImage *)banner1Image
{
    return [self createImage:@"banner1"];
}

+ (UIImage *)banner2Image
{
    return [self createImage:@"banner2"];
}

+ (UIImage *)banner3Image
{
    return [self createImage:@"banner3"];
}

+ (UIImage *)bannerPlaceholderImage
{
    return [UIImage imageNamed:@"BannerPlaceholder"];
}

+ (UIImage *)discountImage
{
    return [self createImage:@"discount"];
}

+ (UIImage *)tabBarBackgroundImage
{
    return [self createImage:@"tab_bar_background"];
}

+ (UIImage *)tabBar1Image
{
    return [self createImage:@"tab_1"];
}

+ (UIImage *)tabBar1SelectedImage
{
//    return [self createImage:@"tab_1_selected"];
      return [self createImage:@"tabbarMain"];

}

+ (UIImage *)tabBar2Image
{
    return [self createImage:@"tab_2"];
}

+ (UIImage *)tabBar2SelectedImage
{
    return [self createImage:@"tab_2_selected"];
}

+ (UIImage *)tabBar3Image
{
    return [self createImage:@"tab_3"];
}

+ (UIImage *)tabBar3SelectedImage
{
    return [self createImage:@"tab_3_selected"];
}

+ (UIImage *)tabBar4Image
{
    return [self createImage:@"tab_4"];
}

+ (UIImage *)tabBar4SelectedImage
{
    return [self createImage:@"tab_4_selected"];
}

+ (UIImage *)tabBar5Image
{
    return [self createImage:@"tab_5"];
}

+ (UIImage *)tabBar5SelectedImage
{
    return [self createImage:@"tab_5_selected"];
}

+ (UIImage *)navigationBarImage
{
    return [[self createImage:@"navigation_bar_128"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
}

+ (UIImage *)arrowDownImage
{
    return [self createImage:@"arrow_down"];
}

+ (UIImage *)pagecontrolDotBlueImage
{
    return [self createImage:@"pagecontrol_dot_blue"];
}

+ (UIImage *)pagecontrolDotWhiteImage
{
    return [self createImage:@"pagecontrol_dot_white"];
}

+ (UIImage *)locationImage
{
    return [self createImage:@"location"];
}

+ (UIImage *)businessCellBackgroundImage
{
    return [[self createImage:@"business_cell_background"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
}

//+ (UIImage *)businessCellBackgroundSelectedImage
//{
//    return [[self createImage:@"business_cell_background_selected"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//}

//+ (UIImage *)pageBackgroundImageWithHeight:(CGFloat)height
//{
//    if (height == 480 - 64) {
//        return [self createImage:@"page_background_416"];
//    }
//    
//    if (height == 480 - 64 - 49) {
//        return [self createImage:@"page_background_367"];
//    }
//    
//    if (height == 568 - 64 - 49) {
//        return [self createImage:@"page_background_455"];
//    }
//    
//    return [self createImage:@"page_background_455"];
//}

+ (UIImage *)businessDefultSmallImage
{
    return [self createImage:@"business_defult_small_image"];
}

+ (UIImage *)orderBackgroundBottomImage
{
    return [[self createImage:@"order_background_bottom"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
}

+ (UIImage *)orderBackgroundBottom2Image
{
    return [[self createImage:@"order_background_bottom_2"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
}

+ (UIImage *)orderBackgroundTopImage
{
    return [[self createImage:@"order_background_top"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

//+ (UIImage *)activityButtonImage
//{
//    return [self createImage:@"activity_button"];
//}
//
//+ (UIImage *)activityButtonSelectedImage
//{
//    return [self createImage:@"activity_button_selected"];
//}
//
//+ (UIImage *)peopleButtonImage
//{s
//    return [self createImage:@"people_button"];
//}
//
//+ (UIImage *)peopleButtonSelectedImage
//{
//    return [self createImage:@"people_button_selected"];
//}

+ (UIImage *)inputBackgroundImage
{
    return [[self createImage:@"input_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)inputBackground2Image
{
    return [[self createImage:@"input_background_2"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)inputBackground3Image
{
    return [[self createImage:@"input_background_3"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)inputBackground4Image
{
    return [[self createImage:@"input_background_4"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
}

+ (UIImage *)pullDownImage
{
    return [self createImage:@"pull_down"];
}

+ (UIImage *)pullDown2Image
{
    return [self createImage:@"pull_down_2"];
}

+ (UIImage *)createActivityButtonImage
{
    return [self createImage:@"create_activity_button"];
}

+ (UIImage *)createActivityButtonSelectedImage
{
    return [self createImage:@"create_activity_button_selected"];
}

+ (UIImage *)manageActivityButtonImage
{
    return [self createImage:@"manage_activity_button"];
}

+ (UIImage *)manageActivityButtonSelectedImage
{
    return [self createImage:@"manage_activity_button_selected"];
}

+ (UIImage *)activityFilterImage
{
    return [self createImage:@"activity_filter"];
}

+ (UIImage *)maleBackgroundImage
{
    return [self createImage:@"male_background"];
}

+ (UIImage *)femaleBackgroundImage
{
    return [self createImage:@"female_background"];
}

+ (UIImage *)greenMarkImage
{
    return [self createImage:@"green_mark"];
}

+ (UIImage *)orangeButtonImage
{
    return [[self createImage:@"orange_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)blueButtonImage
{
    return [[self createImage:@"blue_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)greenButtonImage
{
    return [[self createImage:@"green_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}

+ (UIImage *)otherCellBackground1Image
{
    return [[self createImage:@"other_cell_background_1"] stretchableImageWithLeftCapWidth:160 topCapHeight:2];
}

+ (UIImage *)otherCellBackground2Image
{
    return [[self createImage:@"other_cell_background_2"] stretchableImageWithLeftCapWidth:160 topCapHeight:2];
}

+ (UIImage *)otherCellBackground3Image
{
    return [[self createImage:@"other_cell_background_3"] stretchableImageWithLeftCapWidth:160 topCapHeight:2];
}

+ (UIImage *)otherCellBackground4Image
{
    return [[self createImage:@"other_cell_background_4"] stretchableImageWithLeftCapWidth:160 topCapHeight:2];
}

+ (UIImage *)activityStatusDot1Image
{
    return [self createImage:@"activity_status_dot_1"];
}

+ (UIImage *)activityStatusDot2Image
{
    return [self createImage:@"activity_status_dot_2"];
}

+ (UIImage *)loginInputBackgroundImage
{
    return [[self createImage:@"login_input_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)loginInputBackgroundSelectedImage
{
    return [[self createImage:@"login_input_background_selected"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)logoutButtonImage
{
    return [[self createImage:@"logout_button"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)sportLevelImage:(int)sportLevel
{
    if (sportLevel == 1) {
        return [self createImage:@"level_1"];
    }else if (sportLevel == 2) {
        return [self createImage:@"level_2"];
    }else if (sportLevel == 3) {
        return [self createImage:@"level_3"];
    }else if (sportLevel == 4) {
        return [self createImage:@"level_4"];
    }
    return nil;
}

+ (UIImage *)homeDefaultBusiness1Image
{
    return [self createImage:@"home_default_business_1"];
}

+ (UIImage *)homeDefaultBusiness2Image
{
    return [self createImage:@"home_default_business_2"];
}

+ (UIImage *)addImageButtonImage
{
    return [self createImage:@"add_image_button"];
}

+ (UIImage *)bootPageImage:(int)index
{
    //index从0开始的
    if (index > 3) {
        return nil;
    }
    
    return [self createImage:[NSString stringWithFormat:@"boot_page_%d", index + 1]];
}

+ (UIImage *)mainBootPageImage:(int)index
{
    //index从0开始的
    if (index > 3) {
        return nil;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"MainBootPage_%d.jpg", index + 1]];
    //return [self createImage:[NSString stringWithFormat:@"main_boot_page_%d", index + 1]];
}

+ (UIImage *)subTitleBootPageImage:(int)index
{
    //index从0开始的
    if (index > 3) {
        return nil;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"SubtitleBootPage_%d", index + 1]];
    //return [self createImage:[NSString stringWithFormat:@"subTitle_boot_page_%d", index + 1]];
}

+ (UIImage *)titleBootPageImage:(int)index
{
    //index从0开始的
    if (index > 3) {
        return nil;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"TitleBootPage_%d", index + 1]];
    //return [self createImage:[NSString stringWithFormat:@"title_boot_page_%d", index + 1]];
}

+ (UIImage *)bootPageEnterButtonImage
{
    return [[self createImage:@"boot_page_enter_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)bootPageEnterButtonSelectedImage
{
    return [[self createImage:@"boot_page_enter_button_selected"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)chatInputBackgroundImage
{
    return [[self createImage:@"chat_input_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)leftBubbleImage
{
    return [[self createImage:@"left_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:14];
}

+ (UIImage *)rightBubbleImage
{
    return [[self createImage:@"right_bubble"] stretchableImageWithLeftCapWidth:16 topCapHeight:14];
}

+ (UIImage *)leftBubble2Image
{
    return [[self createImage:@"left_bubble_2"] stretchableImageWithLeftCapWidth:16 topCapHeight:14];
}

+ (UIImage *)rightBubble2Image
{
    return [[self createImage:@"right_bubble_2"] stretchableImageWithLeftCapWidth:16 topCapHeight:14];
}

+ (UIImage *)commentMessageLeftImage
{
    return [[self createImage:@"comment_message_left"] stretchableImageWithLeftCapWidth:16 topCapHeight:14];
}

+ (UIImage *)commentMessageUpImage
{
    return [[self createImage:@"comment_message_up"] stretchableImageWithLeftCapWidth:12 topCapHeight:11];
}

+ (UIImage *)groupChatAvatarImage
{
    return [self createImage:@"group_chat_avatar"];
}

+ (UIImage *)refreshImage
{
    return [self createImage:@"refresh"];
}

+ (UIImage *)networkErrorPageImage
{
    return [self createImage:@"network_error_page"];
}

+ (UIImage *)noDataPageImage
{
    return [self createImage:@"no_data_page"];
}

+ (UIImage *)noDataPageSmallImage
{
    return [self createImage:@"no_data_page_small"];
}

+ (UIImage *)defaultRefreshButtonImage
{
    return [UIImage imageNamed:@"default_refresh_button"];
}

+ (UIImage *)systemAvatarImage
{
    return [UIImage imageNamed:@"system_avatar"];
}

+ (UIImage *)voucherBackgroundImage
{
    return [UIImage imageNamed:@"voucher_background"];
}

+ (UIImage *)voucherBackgroundInvalidImage
{
    return [UIImage imageNamed:@"voucher_background_invalid"];
}

+ (UIImage *)mapBackButtonImage
{
    return [self createImage:@"map_back_button"];
}

+ (UIImage *)mapCategoryButtonImage
{
    return [self createImage:@"map_category_button"];
}

+ (UIImage *)mapLocationButtonImage
{
    return [self createImage:@"map_location_button"];
}

+ (UIImage *)mapRefreshButtonImage
{
    return [self createImage:@"map_refresh_button"];
}

+ (UIImage *)listFilterButtonImage
{
    return [[self createImage:@"list_filter_button"] stretchableImageWithLeftCapWidth:21 topCapHeight:0];
}


+ (UIImage *)listFilterButtonSelectedImage
{
    return [[self createImage:@"list_filter_button_selected"] stretchableImageWithLeftCapWidth:21 topCapHeight:0];
}

+ (UIImage *)switchButtonOffImage
{
    return [self createImage:@"switch_button_off"];
}

+ (UIImage *)switchButtonOnImage
{
    return [self createImage:@"switch_button_on"];
}

//+ (UIImage *)buleImage
//{
//    return [[self createImage:@"bule"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
//}

+ (UIImage *)changImage
{
    return [self createImage:@"chang"];
}

+ (UIImage *)dingImage
{
    return [self createImage:@"ding"];
}

+ (UIImage *)mapButtonImage
{
    //return [self createImage:@"map_button"];
    return [UIImage imageNamed:@"mapIcon"];
}

+ (UIImage *)searchBarImage
{
    return [[self createImage:@"search_bar"] stretchableImageWithLeftCapWidth:40 topCapHeight:10];
}

+ (UIImage *)myOrderCellBackgroundImage
{
    return [[self createImage:@"my_order_cell_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)myOrderCellDottedLineImage
{
    return [self createImage:@"my_order_cell_dotted_line"];
}

+ (UIImage *)myOrderCellArrowImage
{
    return [self createImage:@"my_order_cell_arrow"];
}

+ (UIImage *)lineImage
{
    return [[self createImage:@"line"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
}

+ (UIImage *)lineVerticalImage
{
    return [[self createImage:@"line_vertical"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
}

+ (UIImage *)lineVertical2Image
{
    return [[self createImage:@"line_vertical_2"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
}

+ (UIImage *)whiteBackgroundImage
{
    return [[self createImage:@"white_background"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)whiteBackgroundRoundImage
{
    return [[self createImage:@"white_background_round"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}

+ (UIImage *)whiteFrameBackgroundImage
{
    return [[self createImage:@"white_frame_background"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}

+ (UIImage *)grayBackgroundRoundImage
{
    return [[self createImage:@"gray_background_round"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}

+ (UIImage *)businessListChooseButtonImage
{
    return [[self createImage:@"BussinessListbutton"] stretchableImageWithLeftCapWidth:17 topCapHeight:15];
}

+ (UIImage *)ellipseBlueImage
{
    return [[self createImage:@"ellipse_blue"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
}

+ (UIImage *)blueDownButtonImage
{
    return [[self createImage:@"blue_down_button"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)arrowDownWhiteImage
{
    return [self createImage:@"arrow_down_white"];
}

+ (UIImage *)noInfoImage
{
    return [self createImage:@"no_info"];
}

+ (UIImage *)inputBackgroundWhiteImage
{
    return [[self createImage:@"input_background_white"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)minusButtonImage
{
    return [self createImage:@"minus_button"];
}

+ (UIImage *)minusButtonOffImage
{
    return [self createImage:@"minus_button_off"];
}

+ (UIImage *)plusButtonOffImage
{
    return [self createImage:@"plus_button_off"];
}

+ (UIImage *)plusButtonImage
{
    return [self createImage:@"plus_button"];
}

+ (UIImage *)blueFrameButtonImage
{
    return [[self createImage:@"blue_frame_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)blueButtonLeftImage
{
    return [[self createImage:@"blue_button_left"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)blueButtonMiddleImage
{
    return [[self createImage:@"blue_button_middle"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)blueButtonRightImage
{
    return [[self createImage:@"blue_button_right"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)blueFrameButtonLeftImage
{
    return [[self createImage:@"blue_frame_button_left"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)blueFrameButtonMiddleImage
{
    return [[self createImage:@"blue_frame_button_middle"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)blueFrameButtonRightImage
{
    return [[self createImage:@"blue_frame_button_right"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)grayFrameButtonImage
{
    return [[self createImage:@"gray_frame_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)grayButtonImage
{
    return [[self createImage:@"gray_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)orangeFrameButtonImage
{
    return [[self createImage:@"orange_frame_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)whiteFrameLeftButtonImage
{
    return [[self createImage:@"white_frame_left_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)whiteFrameLeftButtonSelectedImage
{
    return [[self createImage:@"white_frame_left_button_selected"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)whiteFrameRightButtonImage
{
    return [[self createImage:@"white_frame_right_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)whiteFrameRightButtonSelectedImage
{
    return [[self createImage:@"white_frame_right_button_selected"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)shareImage
{
    return [self createImage:@"share"];
}

+ (UIImage *)grayBackgroundImage
{
    return [[self createImage:@"gray_background"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
}

+ (UIImage *)whiteImage
{
    return [[self createImage:@"white"] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
}

+ (UIImage *)shadowImage
{
    return [[self createImage:@"shadow"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
}

+ (UIImage *)shareBackgroundImage
{
    return [[self createImage:@"share_background"] stretchableImageWithLeftCapWidth:160 topCapHeight:63];
}

+ (UIImage *)star1Image
{
    return [self createImage:@"star_1"];
}

+ (UIImage *)star2Image
{
    return [self createImage:@"star_2"];
}

+ (UIImage *)star3Image
{
    return [self createImage:@"star_3"];
}

+ (UIImage *)voucherLeftBackground1Image
{
    return [self createImage:@"voucher_left_background_1"];
}

+ (UIImage *)voucherLeftBackground2Image
{
    return [self createImage:@"voucher_left_background_2"];
}

+ (UIImage *)radioButtonUnselectedImage
{
    //return [self createImage:@"radio_button_unselected"];
    return [UIImage imageNamed:@"radioButtonUnselected"];
}

+ (UIImage *)radioButtonSelectedImage
{
    return [UIImage imageNamed:@"radio_button_selected_blue"];
    //return [self createImage:@"radio_button_selected"];
}

+ (UIImage *)drawItem1Image
{
    return [self createImage:@"draw_item_1"];
}

+ (UIImage *)drawItem1HighlightedImage
{
    return [self createImage:@"draw_item_1_highlighted"];
}

+ (UIImage *)drawItem2Image
{
    return [self createImage:@"draw_item_2"];
}

+ (UIImage *)drawItem2HighlightedImage
{
    return [self createImage:@"draw_item_2_highlighted"];
}

+ (UIImage *)drawOrangeButtonImage
{
    return [self createImage:@"draw_orange_button"];
}

+ (UIImage *)soldOutImage
{
    return [self createImage:@"sold_out"];
}

+ (UIImage *)packageDefaultImage
{
    return [self createImage:@"package_default"];
}

+ (UIImage *)packageNameBackgroundImage
{
    return [[self createImage:@"package_name_background"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
}

+ (UIImage *)numberGrayBackgroundImage
{
    return [self createImage:@"number_gray_background"];
}

+ (UIImage *)arrowUpGrayImage
{
    return [self createImage:@"arrow_up_gray"];
}

+ (UIImage *)triangleDownImage
{
    return [self createImage:@"triangle_down"];
}

+ (UIImage *)triangleUpImage
{
    return [self createImage:@"triangle_up"];
}

+ (UIImage *)defaultImage_92x65
{
    return [self createImage:@"default_92x65"];
}

+ (UIImage *)defaultImage_122x90
{
    return [self createImage:@"default_122x90"];
}

+ (UIImage *)defaultImage_143x115
{
    return [self createImage:@"default_143x115"];
}

+ (UIImage *)defaultImage_300x155
{
    return [self createImage:@"default_300x155"];
}

+ (UIImage *)selectedProductBackgroundImage
{
    return [[self createImage:@"selected_product_background"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
}

+ (UIImage *)searchBackgroundImage
{
    return [[UIImage imageNamed:@"SearchBackgroundForMain"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
//    return [[self createImage:@"SearchBackgroundForMain"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
}

+ (UIImage *)timeBackgroundImage
{
    return [[self createImage:@"time_background"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)orderBackgroundImage
{
    return [[self createImage:@"order_background"] stretchableImageWithLeftCapWidth:6 topCapHeight:49];
}

+ (UIImage *)selectBoxUnselectImage
{
    return [self createImage:@"select_box_unselect"];
}

+ (UIImage *)selectBoxOrangeImage
{
    return [self createImage:@"select_box_orange"];
}

+ (UIImage *)selectBoxBlueImage
{
    return [self createImage:@"select_box_blue"];
}

+ (UIImage *)markGreenImage
{
    return [self createImage:@"mark_green"];
}

+ (UIImage *)canNotImage
{
    return [self createImage:@"can_not"];
}

+ (UIImage *)cardSelectedImage
{
    return [self createImage:@"card_selected"];
}

+ (UIImage *)cardUnselectedImage
{
    return [self createImage:@"card_unselected"];
}

+ (UIImage *)refundProcessingImage
{
    return [self createImage:@"refund_processing"];
}

+ (UIImage *)refundFinishImage
{
    return [self createImage:@"refund_finish"];
}

+ (UIImage *)topRightFrameGrayImage
{
    return [[self createImage:@"top_right_frame_gray"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
}

+ (UIImage *)redRoundButtonImage
{
    return [[self createImage:@"order_detail_refund"] stretchableImageWithLeftCapWidth:24 topCapHeight:0];
}

+ (UIImage *)blueRoundButtonImage
{
    return [[self createImage:@"order_detail_comment"] stretchableImageWithLeftCapWidth:24 topCapHeight:0];
}

+ (UIImage *)courtPoolPayButtonDefaultImage {
    return [[self createImage:@"courtPoolPayButtonDefault"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
}

+ (UIImage *)courtPoolPayButtonHighLightImage {
    return [[self createImage:@"courtPoolPayButtonHighlight"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
}

+ (UIImage *)moneyImage
{
    return [self createImage:@"money"];
}

+ (UIImage *)pointImage
{
    return [self createImage:@"point"];
}

+ (UIImage *)alipayImage
{
    //return [self createImage:@"alipay"];
    return [UIImage imageNamed:@"aliPayIcon"];
}

+ (UIImage *)wechatpayImage
{
    //return [self createImage:@"wechatpay"];
    return [UIImage imageNamed:@"weChatPayIcon"];
}

+ (UIImage *)unionpayImage
{
//    return [self createImage:@"unionpay"];
    return [UIImage imageNamed:@"unionPayIcon"];
}

+ (UIImage *)applePayImage {
    return [UIImage imageNamed:@"applePayIcon"];
}

+ (UIImage *)sport80Image{
    return [self createImage:@"sport_80"];
}

+ (UIImage *)placeHolderImage
{
    return [UIImage imageNamed:@"CommentImage"];
}

+ (UIImage *)onlinePayImage
{
    return [self createImage:@"online_paytype"];
}

+ (UIImage *)vipImage
{
    return [self createImage:@"vip"];
}

+ (UIImage *)cardPayImage
{
    return [self createImage:@"card_paytype"];
}

+ (UIImage *)clubPayImage
{
    return [self createImage:@"club_paytype"];
}

+ (UIImage *)scanBarButtonImage
{
    return [self createImage:@"scan_bar_button"];
}

+ (UIImage *)businessDetailRefundMarkImage
{
    return [self createImage:@"business_detail_refund_mark"];
}

+ (UIImage *)forumHomeActivityImage
{
    return [self createImage:@"forum_home_activity"];
}

+ (UIImage *)writePostButtonImage
{
//    return [self createImage:@"write_post_icon"];
    return [UIImage imageNamed:@"writeButton"];
}

+ (UIImage *)forumHomeLocationImage
{
    return [self createImage:@"forum_home_location"];
}

+ (UIImage *)forumOftenImage
{
    return [self createImage:@"forum_often"];
}

+ (UIImage *)forumMessageImage
{
    return [self createImage:@"forum_message"];
}

+ (UIImage *)searchGrayBackgroundImage
{
    return [[self createImage:@"search_gray_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
}

+ (UIImage *)addPhotoIconImage
{
    return [self createImage:@"add_photo_icon"];
}

+ (UIImage *)genderImageWithGender:(NSString *)gender
{
    if ([gender isEqualToString:@"m"]) {
        return [self genderMaleImage];
    } else if ([gender isEqualToString:@"f"]){
        return [self genderFemaleImage];
    } else {
        return nil;
    }
}

+ (UIImage *)genderMaleImage
{
    return [UIImage imageNamed:@"GenderMale"];
}

+ (UIImage *)genderFemaleImage
{
    return [UIImage imageNamed:@"GenderFemale"];
}

+ (UIImage *)shareWechatFriendsImage
{
    return [self createImage:@"share_wechat_friends"];
}

+ (UIImage *)shareWechatImage
{
    return [self createImage:@"share_wechat"];
}

+ (UIImage *)shareSinaImage
{
    return [self createImage:@"share_sina"];
}



+ (UIImage *)shareSmsImage
{
    return [self createImage:@"share_sms"];
}

+ (UIImage *)shareCopyImage
{
    return [self createImage:@"share_copy"];
}

+ (UIImage *)monthCardDefaultAvatar
{
    return [self createImage:@"monthCard_default_avatar"];
}

+ (UIImage *)monthCardButtonBackground
{
    return [[self createImage:@"monthCard_button"] stretchableImageWithLeftCapWidth:16 topCapHeight:15];
}

+ (UIImage *)tabRightButtonFrame
{
    return [[self createImage:@"tab_right_button_frame"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)tabLeftButtonFrame
{
    return [[self createImage:@"tab_left_button_frame"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)balanceRechargeInputImage
{
    return [[self createImage:@"balance_recharge_input"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)balanceRechargeButtonImage
{
    return [[self createImage:@"balance_recharge_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)addVoucherInputImage
{
    return [[self createImage:@"add_voucher_input"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

+ (UIImage *)addVoucherButtonImage
{
    return [[self createImage:@"add_voucher_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

//+ (UIImage *)coachFemaleImage
//{
//    return [self createImage:@"coach_female"];
//}

//+ (UIImage *)coachMaleImage
//{
//    return [self createImage:@"coach_male"];
//}

+(UIImage *)coachCancelButtonImage
{
    return [[self createImage:@"cancel_button"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];

}

+(UIImage *)coachLeftBlueButtonImage
{
    return [[self createImage:@"coach_left_blue_button"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

+ (UIImage *)popDownBlueImage
{
    return [[self createImage:@"pop_down_blue"] stretchableImageWithLeftCapWidth:23 topCapHeight:14];
}

+ (UIImage *)activeDotImage
{
    return [UIImage imageNamed:@"activeDot"];
//    return [self createImage:@"active_dot"];
}

+ (UIImage *)inactiveDotImage
{
    return [UIImage imageNamed:@"InactiveDot"];
//    return [self createImage:@"inactive_dot"];
}

+(UIImage *)headImageView{
    return [UIImage imageNamed:@"defaultAvatar"];
}

+ (UIImage *)recommendClubImage {
    return [self createImage:@"recommend_club"];
}

+ (UIImage *)noRefundImage {
    return [self createImage:@"no_refund_icon"];
}

+ (UIImage *)coachCategaryItemImage {
    return [self createImage:@"categary_background"];
}

+ (UIImage *)whiteBackgroundWithGrayLineImage {
    return [self createImage:@"whiteBackground_withGrayLine"];
}

+ (UIImage *)coachTopRightButtonImage {
    return [self createImage:@"coach_rightTopButton"];
}

+ (UIImage *)dongClubRedBackgroundImage {
    return [[self createImage:@"club_background_red"] stretchableImageWithLeftCapWidth:13 topCapHeight:9];
}

+ (UIImage *)dongClubGrayBackroundImage {
    return [[self createImage:@"club_background_gray"] stretchableImageWithLeftCapWidth:13 topCapHeight:9];
}

+ (UIImage *)systemMessageBackground {
    return [[UIImage imageNamed:@"messageBackground"] stretchableImageWithLeftCapWidth:6 topCapHeight:20];

    //return [[UIImage imageNamed:@"SystemMessageBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 5) resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)systemMessageTimeBackground {
    return [[UIImage imageNamed:@"MessageTimeBackground"] stretchableImageWithLeftCapWidth:8 topCapHeight:7];

}

+ (UIImage *)grayBorderButtonImage {
    return [[self createImage:@"gray_border_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:3];
}

+ (UIImage *)blueBorderButtonImage {
    return [[self createImage:@"blue_border_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:3];
}

@end
