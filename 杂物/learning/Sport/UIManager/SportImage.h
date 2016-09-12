//
//  SportImage.h
//  Sport
//
//  Created by haodong  on 13-6-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    InterfaceStyleNone = -1,
    InterfaceStyleDefault = 0,
    InterfaceStyleOrange = 1,
    InterfaceStyleRed = 2
}InterfaceStyle;

@interface SportImage : NSObject

@property (strong, nonatomic) UIImage *networkErrorImage;
@property (strong, nonatomic) UIImage *noDataImage;

+ (id)defaultManager;

+ (BOOL)saveInterfaceStyle:(InterfaceStyle)style;

+ (UIImage *)createImage:(NSString *)shortName;

+ (UIImage *)userImage;

+ (UIImage *)searchButtonImage;

+ (UIImage *)homeTitleImage;

//+ (UIImage *)categoryBackground1Image;
//
//+ (UIImage *)categoryBackground2Image;

+ (UIImage *)filterButtonImage;

+ (UIImage *)backButtonImage;

//+ (UIImage *)navyBlueButtonBackgroundImage;

+ (UIImage *)commentButtonImage;

+ (UIImage *)categoryTitleImage;

+ (UIImage *)categorySimpleImage;

+ (UIImage *)categorySimpleSelectedImage;

+ (UIImage *)bookingSimpleImage;

+ (UIImage *)cellBackgroundImage;

+ (UIImage *)cellTopBackgroundImage;

+ (UIImage *)characteristicBackgroundImage:(NSUInteger)index;

+ (UIImage *)characteristicBackgroundImage;

+ (UIImage *)addressImage;

+ (UIImage *)telephoneImage;

+ (UIImage *)bookDateSelectedImage;

+ (UIImage *)userCellBackground1Image;

+ (UIImage *)userCellBackground2Image;

+ (UIImage *)cellIconFavoritesImage;

+ (UIImage *)cellIconHistoryImage;

+ (UIImage *)cellIconMyMessageImage;

+ (UIImage *)cellIconSystemMessageImage;

+ (UIImage *)cellIconOtherImage;

+ (UIImage *)cellIconPhoneImage;

+ (UIImage *)cellIconShareImage;

+ (UIImage *)cellIconAccountManageImage;

+ (UIImage *)cellIconJifenImage;

+ (UIImage *)cellIconBalanceImage;

+ (UIImage *)cellIconVoucherImage;

+ (UIImage *)avatarBackgroundImage;

+ (UIImage *)avatarDefaultImage;

+ (UIImage *)avatarDefaultImageWithGender:(NSString *)gender;

+ (UIImage *)categoryImage:(NSString *)categoryName isSelected:(BOOL)isSelected;

+ (UIImage *)smallCategoryImage:(NSString *)categoryName;

+ (UIImage *)mapCategoryImage:(NSString *)categoryName canOrder:(BOOL)canOrder;

+ (UIImage *)markButtonImage;

+ (UIImage *)penImage;

+ (UIImage *)writeButtonImage;

+ (UIImage *)webviewGoBackButtonOnImage;

+ (UIImage *)webviewGoBackButtonOffImage;

+ (UIImage *)webviewGoForwardButtonOnImage;

+ (UIImage *)webviewGoForwardButtonOffImage;

+ (UIImage *)webviewRefreshButtonOnImage;

+ (UIImage *)webviewRefreshButtonOffImage;

+ (UIImage *)registerButtonImage;

+ (UIImage *)moreImage;

+ (UIImage *)businessDefaultImage;

+ (UIImage *)appIconImage;

+ (UIImage *)shareRedIcon;

+ (UIImage *)sinaWeiboImage;

+ (UIImage *)qqImage;

+ (UIImage *)wechatImage;

+ (UIImage *)countBackgroundRedImage;

+ (UIImage *)tipsCountBackgroundWhiteImage;

+ (UIImage *)clearButtonImage;

+ (UIImage *)manageButtonImage;

+ (UIImage *)favoriteSportButtonImage;

+ (UIImage *)favoriteSportButtonSelectedImage;

+ (UIImage *)alipayLogoImage;

+ (UIImage *)alipayWebLogoImage;

+ (UIImage *)wechatpayLogoImage;

//+ (UIImage *)input1RowBackgroundImage;

//+ (UIImage *)input2RowBackgroundImage;

//+ (UIImage *)roundButtonImage;

//+ (UIImage *)redButtonImage;

//+ (UIImage *)manImage;
//
//+ (UIImage *)femaleImage;

+ (UIImage *)settingImage;

+ (UIImage *)orderImage;

+ (UIImage *)collectButtonImage;

+ (UIImage *)collectButtonSelectedImage;

+ (UIImage *)shareButtonImage;

//+ (UIImage *)otherServiceItemImage:(NSString *)itemId;

+ (UIImage *)arrowRightImage;

+ (UIImage *)markImage;

+ (UIImage *)banner1Image;

+ (UIImage *)banner2Image;

+ (UIImage *)banner3Image;

+ (UIImage *)discountImage;

+ (UIImage *)tabBarBackgroundImage;

+ (UIImage *)tabBar1Image;
+ (UIImage *)tabBar1SelectedImage;

+ (UIImage *)tabBar2Image;
+ (UIImage *)tabBar2SelectedImage;

+ (UIImage *)tabBar3Image;
+ (UIImage *)tabBar3SelectedImage;

+ (UIImage *)tabBar4Image;
+ (UIImage *)tabBar4SelectedImage;

+ (UIImage *)tabBar5Image;
+ (UIImage *)tabBar5SelectedImage;

+ (UIImage *)navigationBarImage;

+ (UIImage *)arrowDownImage;

+ (UIImage *)pagecontrolDotBlueImage;

+ (UIImage *)pagecontrolDotWhiteImage;

+ (UIImage *)locationImage;

+ (UIImage *)businessCellBackgroundImage;

//+ (UIImage *)businessCellBackgroundSelectedImage;

//+ (UIImage *)pageBackgroundImageWithHeight:(CGFloat)height;

+ (UIImage *)businessDefultSmallImage;

+ (UIImage *)orderBackgroundBottomImage;

+ (UIImage *)orderBackgroundBottom2Image;

+ (UIImage *)orderBackgroundTopImage;

//+ (UIImage *)activityButtonImage;
//
//+ (UIImage *)activityButtonSelectedImage;
//
//+ (UIImage *)peopleButtonImage;
//
//+ (UIImage *)peopleButtonSelectedImage;

+ (UIImage *)inputBackgroundImage;

+ (UIImage *)inputBackground2Image;

+ (UIImage *)inputBackground3Image;

+ (UIImage *)inputBackground4Image;

+ (UIImage *)pullDownImage;

+ (UIImage *)pullDown2Image;

+ (UIImage *)createActivityButtonImage;

+ (UIImage *)createActivityButtonSelectedImage;

+ (UIImage *)manageActivityButtonImage;

+ (UIImage *)manageActivityButtonSelectedImage;

+ (UIImage *)activityFilterImage;

+ (UIImage *)maleBackgroundImage;

+ (UIImage *)femaleBackgroundImage;

+ (UIImage *)greenMarkImage;

+ (UIImage *)orangeButtonImage;

+ (UIImage *)blueButtonImage;

+ (UIImage *)greenButtonImage;

+ (UIImage *)otherCellBackground1Image;

+ (UIImage *)otherCellBackground2Image;

+ (UIImage *)otherCellBackground3Image;

+ (UIImage *)otherCellBackground4Image;

+ (UIImage *)activityStatusDot1Image;

+ (UIImage *)activityStatusDot2Image;

+ (UIImage *)loginInputBackgroundImage;

+ (UIImage *)loginInputBackgroundSelectedImage;

+ (UIImage *)logoutButtonImage;

+ (UIImage *)sportLevelImage:(int)sportLevel;

+ (UIImage *)homeDefaultBusiness1Image;

+ (UIImage *)homeDefaultBusiness2Image;

+ (UIImage *)addImageButtonImage;

+ (UIImage *)bootPageImage:(int)index;
+ (UIImage *)mainBootPageImage:(int)index;
+ (UIImage *)titleBootPageImage:(int)index;
+ (UIImage *)subTitleBootPageImage:(int)index;

+ (UIImage *)bootPageEnterButtonImage;

+ (UIImage *)bootPageEnterButtonSelectedImage;

+ (UIImage *)chatInputBackgroundImage;

+ (UIImage *)leftBubbleImage;

+ (UIImage *)rightBubbleImage;

+ (UIImage *)leftBubble2Image;

+ (UIImage *)rightBubble2Image;

+ (UIImage *)groupChatAvatarImage;

+ (UIImage *)refreshImage;

+ (UIImage *)networkErrorPageImage;

+ (UIImage *)noDataPageImage;

+ (UIImage *)noDataPageSmallImage;

+ (UIImage *)defaultRefreshButtonImage;

+ (UIImage *)systemAvatarImage;

+ (UIImage *)voucherBackgroundImage;

+ (UIImage *)voucherBackgroundInvalidImage;

+ (UIImage *)grayButtonImage;

+ (UIImage *)mapBackButtonImage;

+ (UIImage *)mapCategoryButtonImage;

+ (UIImage *)mapLocationButtonImage;

+ (UIImage *)mapRefreshButtonImage;

+ (UIImage *)listFilterButtonImage;

+ (UIImage *)listFilterButtonSelectedImage;

+ (UIImage *)switchButtonOffImage;

+ (UIImage *)switchButtonOnImage;

//+ (UIImage *)buleImage;

+ (UIImage *)changImage;

+ (UIImage *)dingImage;

+ (UIImage *)mapButtonImage;

+ (UIImage *)searchBarImage;

+ (UIImage *)myOrderCellBackgroundImage;

+ (UIImage *)myOrderCellDottedLineImage;

+ (UIImage *)myOrderCellArrowImage;

+ (UIImage *)lineImage;

+ (UIImage *)lineVerticalImage;

+ (UIImage *)lineVertical2Image;

+ (UIImage *)whiteBackgroundImage;

+ (UIImage *)whiteBackgroundRoundImage;

+ (UIImage *)whiteFrameBackgroundImage;

+ (UIImage *)grayBackgroundRoundImage;

+ (UIImage *)businessListChooseButtonImage;

+ (UIImage *)ellipseBlueImage;

+ (UIImage *)blueDownButtonImage;

+ (UIImage *)arrowDownWhiteImage;

+ (UIImage *)noInfoImage;

+ (UIImage *)inputBackgroundWhiteImage;

+ (UIImage *)minusButtonImage;

+ (UIImage *)minusButtonOffImage;

+ (UIImage *)plusButtonOffImage;

+ (UIImage *)plusButtonImage;

+ (UIImage *)blueFrameButtonImage;

+ (UIImage *)blueButtonLeftImage;

+ (UIImage *)blueButtonMiddleImage;

+ (UIImage *)blueButtonRightImage;

+ (UIImage *)blueFrameButtonLeftImage;

+ (UIImage *)blueFrameButtonMiddleImage;

+ (UIImage *)blueFrameButtonRightImage;

+ (UIImage *)grayFrameButtonImage;

+ (UIImage *)orangeFrameButtonImage;

+ (UIImage *)whiteFrameLeftButtonImage;
+ (UIImage *)whiteFrameLeftButtonSelectedImage;
+ (UIImage *)whiteFrameRightButtonImage;
+ (UIImage *)whiteFrameRightButtonSelectedImage;

+ (UIImage *)shareImage;

+ (UIImage *)grayBackgroundImage;

+ (UIImage *)whiteImage;

+ (UIImage *)shadowImage;

+ (UIImage *)shareBackgroundImage;

+ (UIImage *)star1Image;

+ (UIImage *)star2Image;

+ (UIImage *)star3Image;

+ (UIImage *)voucherLeftBackground1Image;

+ (UIImage *)voucherLeftBackground2Image;

+ (UIImage *)radioButtonUnselectedImage;

+ (UIImage *)radioButtonSelectedImage;

+ (UIImage *)drawItem1Image;

+ (UIImage *)drawItem1HighlightedImage;

+ (UIImage *)drawItem2Image;

+ (UIImage *)drawItem2HighlightedImage;

+ (UIImage *)drawOrangeButtonImage;

+ (UIImage *)soldOutImage;

+ (UIImage *)packageDefaultImage;

+ (UIImage *)packageNameBackgroundImage;

+ (UIImage *)numberGrayBackgroundImage;

+ (UIImage *)arrowUpGrayImage;

+ (UIImage *)triangleDownImage;

+ (UIImage *)triangleUpImage;

+ (UIImage *)defaultImage_92x65;

+ (UIImage *)defaultImage_122x90;

+ (UIImage *)defaultImage_143x115;

+ (UIImage *)defaultImage_300x155;

+ (UIImage *)selectedProductBackgroundImage;

+ (UIImage *)searchBackgroundImage;

+ (UIImage *)timeBackgroundImage;

+ (UIImage *)orderBackgroundImage;

+ (UIImage *)selectBoxUnselectImage;

+ (UIImage *)selectBoxOrangeImage;

+ (UIImage *)selectBoxBlueImage;

+ (UIImage *)markGreenImage;

+ (UIImage *)canNotImage;

+ (UIImage *)refundProcessingImage;

+ (UIImage *)refundFinishImage;

+ (UIImage *)topRightFrameGrayImage;

+ (UIImage *)cellIconSettingImage;

+ (UIImage *)moneyImage;

+ (UIImage *)pointImage;

+ (UIImage *)alipayImage;

+ (UIImage *)wechatpayImage;

+ (UIImage *)unionpayImage;

+ (UIImage *)applePayImage;

+ (UIImage *)sport80Image;

+ (UIImage *)placeHolderImage;

+ (UIImage *)redRoundButtonImage;

+ (UIImage *)blueRoundButtonImage;

+ (UIImage *)courtPoolPayButtonDefaultImage;

+ (UIImage *)courtPoolPayButtonHighLightImage;

+ (UIImage *)onlinePayImage;

+ (UIImage *)vipImage;

+ (UIImage *)cardSelectedImage;
+ (UIImage *)cardUnselectedImage;

+ (UIImage *)scanBarButtonImage;

+ (UIImage *)businessDetailRefundMarkImage;

+ (UIImage *)writePostButtonImage;
+ (UIImage *)forumHomeActivityImage;

+ (UIImage *)forumHomeLocationImage;

+ (UIImage *)forumOftenImage;

+ (UIImage *)forumMessageImage;

+ (UIImage *)searchGrayBackgroundImage;

+ (UIImage *)addPhotoIconImage;
+ (UIImage *)genderMaleImage;

+ (UIImage *)genderFemaleImage;

+ (UIImage *)commentMessageLeftImage;

+ (UIImage *)commentMessageUpImage;

+ (UIImage *)shareWechatFriendsImage;

+ (UIImage *)shareWechatImage;

+ (UIImage *)shareSinaImage;

+ (UIImage *)shareSmsImage;

+ (UIImage *)shareCopyImage;

+ (UIImage *)bannerPlaceholderImage;

+ (UIImage *)monthCardDefaultAvatar;

+ (UIImage *)monthCardButtonBackground;

+ (UIImage *)tabLeftButtonFrame;

+ (UIImage *)tabRightButtonFrame;

+ (UIImage *)balanceRechargeInputImage;

+ (UIImage *)balanceRechargeButtonImage;

+ (UIImage *)addVoucherInputImage;

+ (UIImage *)addVoucherButtonImage;

+ (UIImage *)coachCancelButtonImage;
+ (UIImage *)coachLeftBlueButtonImage;

+ (UIImage *)popDownBlueImage;

+ (UIImage *)activeDotImage;
+ (UIImage *)inactiveDotImage;

+ (UIImage *)headImageView;

+ (UIImage *)recommendClubImage;

+ (UIImage *)clubPayImage;

+ (UIImage *)cardPayImage;

+ (UIImage *)coachCategaryItemImage;

+ (UIImage *)whiteBackgroundWithGrayLineImage;

+ (UIImage *)coachTopRightButtonImage;

+ (UIImage *)dongClubRedBackgroundImage;

+ (UIImage *)dongClubGrayBackroundImage;

+ (UIImage *)systemMessageBackground;

+ (UIImage *)systemMessageTimeBackground;

+ (UIImage *)genderImageWithGender:(NSString *)gender;

+ (UIImage *)grayBorderButtonImage;

+ (UIImage *)blueBorderButtonImage;

@end
