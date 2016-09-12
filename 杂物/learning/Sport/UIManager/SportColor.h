//
//  SportColor.h
//  Sport
//
//  Created by haodong  on 13-7-13.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+HexColor.h"

@interface SportColor : NSObject

+ (UIImage *)defaultImage;
+ (void)updateDefaultButton:(UIButton *)button;

//-------------------------这是华丽的分割线--------------------------------
+ (UIImage *)createImageWithColor:(UIColor *)color;
+ (UIImage *)clearButtonHighlightedBackgroundImage;

+ (UIColor *)defaultColor;      //导航栏背景色

+ (UIColor *)titleColor;        //导航栏标题颜色

+ (UIColor *)loginPageColor;    //登录页面背景色

+ (UIColor *)defaultPageBackgroundColor;    //默认页面背景颜色

+ (UIColor *)defaultOrangeColor;            //默认的橙色(用在价格、购买按钮的橙色)

+ (UIColor *)content1Color;

+ (UIColor *)content2Color;

+ (UIColor *)sportLevelColor:(int)sportLevel;
+ (UIColor *)activityStatusColor:(int)status;

+ (UIColor *)inputTextFieldColor;  // 登录页面待用户输入时显示的文字颜色
+ (UIColor *)bootpageColor:(int)index;

+ (UIColor *)defaultGreenColor;

+ (UIColor *)defaultButtonInactiveColor;

+ (UIColor *)defaultButtonBackgroundColor2;

+ (UIColor *)defaultRedColor;

+ (UIColor *)otherRedColor;

+ (UIColor *)tabbarWordTextColor;

+ (UIColor *)defaultOrangeHightLightColor;

+ (UIColor *)highlightTextColor;

+ (UIColor *)hex6TextColor;

+ (UIColor *)hexF5F5F5Color;

+ (UIColor *)hexAColor;

+ (UIColor *)hexf6f6f9Color;

+ (UIColor *)hex000000Color;

+ (UIColor *)defaultPinkColor;
+ (UIColor *)defaultBlueColor;

@end
