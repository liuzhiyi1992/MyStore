//
//  SportColor.m
//  Sport
//
//  Created by haodong  on 13-7-13.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation SportColor

+ (UIColor *)defalutHighlightedColor
{
    return [UIColor colorWithRed:6.0/255.0 green:139.0/255.0 blue:224.0/255.0 alpha:1];
}

+ (UIImage *)defaultImage
{
    return [[self createImageWithColor:[self defaultColor]] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
}

+ (UIImage *)buttonBackgroundImage
{
    return [[self createImageWithColor:[self defaultColor]] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
}

+ (UIImage *)buttonBackgroundHighlightedImage
{
    return [[self createImageWithColor:[self defalutHighlightedColor]] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
}

+ (void)updateView:(UIView *)view cornerRadius:(CGFloat)cornerRadius
{
    view.layer.cornerRadius = cornerRadius;
}

+ (void)updateDefaultButton:(UIButton *)button
{
    [button setBackgroundImage:[self buttonBackgroundImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[self buttonBackgroundHighlightedImage]  forState:UIControlStateHighlighted];
}

//-------------------------这是华丽的分割线--------------------------------
+ (UIImage *)createImageWithColor:(UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+ (UIColor *)defaultColor
{
    return [self defaultBlueColor];
}

+ (UIColor *)defaultBlueColor
{
      return [UIColor hexColor:@"5b73f2"];
}

+ (UIImage *)clearButtonHighlightedBackgroundImage
{
    return [self createImageWithColor:[UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:0.1]];
}

+ (UIColor *)titleColor
{
    return [UIColor hexColor:@"222222"];
}

+ (UIColor *)loginPageColor
{
    return [self defaultPageBackgroundColor];
    //return [UIColor colorWithRed:229.0/255.0 green:236.0/255.0 blue:240.0/255.0 alpha:1];
    ;
}

+ (UIColor *)sportLevelColor:(int)sportLevel
{
    if (sportLevel == 0) {
        return [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1];
    }
    else if (sportLevel == 1) {
        return [UIColor colorWithRed:90.0/255.0 green:178.0/255.0 blue:208.0/255.0 alpha:1];
    }else if (sportLevel == 2) {
        return [UIColor colorWithRed:241.0/255.0 green:127.0/255.0 blue:34.0/255.0 alpha:1];
    }else if (sportLevel == 3) {
        return [UIColor colorWithRed:154.0/255.0 green:195.0/255.0 blue:44.0/255.0 alpha:1];
    }else if (sportLevel == 4) {
        return [UIColor colorWithRed:248.0/255.0 green:126.0/255.0 blue:126.0/255.0 alpha:1];
    }
    return [UIColor colorWithRed:90.0/255.0 green:178.0/255.0 blue:208.0/255.0 alpha:1];
}

+ (UIColor *)activityStatusColor:(int)status
{
    if (status == 0) {
        return [UIColor colorWithRed:95.0/255.0 green:191.0/255.0 blue:233.0/255.0 alpha:1];
    }
    
//    else if (status == 1) {
//        return [UIColor colorWithRed:248.0/255.0 green:126.0/255.0 blue:126.0/255.0 alpha:1];
//    } else if (status == 2) {
//        return [UIColor colorWithRed:248.0/255.0 green:126.0/255.0 blue:126.0/255.0 alpha:1];
//    }else if (status == 3) {
//        return [UIColor colorWithRed:154.0/255.0 green:195.0/255.0 blue:44.0/255.0 alpha:1];
//    }
    
    return [UIColor colorWithRed:154.0/255.0 green:195.0/255.0 blue:44.0/255.0 alpha:1];
}

//#f5f5f9
+ (UIColor *)defaultPageBackgroundColor
{
    return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:249.0/255.0 alpha:1];
}

//#ff850d
+ (UIColor *)defaultOrangeColor
{
    //return [UIColor colorWithRed:255.0/255.0 green:133.0/255.0 blue:13.0/255.0 alpha:1];
    return [UIColor hexColor:@"ff850d"];
}

+ (UIColor *)defaultOrangeHightLightColor
{
    return [UIColor hexColor:@"ffa955"];
}
//#666666
+ (UIColor *)content1Color
{
    return [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
}

//#aaaaaa
+ (UIColor *)content2Color
{
    return [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
}

+ (UIColor *)inputTextFieldColor
{
    return [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1];
}

+ (UIColor *)bootpageColor:(int)index
{
    return [UIColor whiteColor];
//    switch (index) {
//        case 0:
//            return [self bootpage1Color];
//        case 1:
//            return [self bootpage2Color];
//        case 2:
//            return [self bootpage3Color];
//        default:
//            break;
//    }
//    return nil;
}

+ (UIColor *)bootpage1Color
{
    return [UIColor colorWithRed:246.0/255.0 green:182.0/255.0 blue:151.0/255.0 alpha:1];
}

+ (UIColor *)bootpage2Color
{
    return [UIColor colorWithRed:130.0/255.0 green:195.0/255.0 blue:231.0/255.0 alpha:1];
}

+ (UIColor *)bootpage3Color
{
    return [UIColor colorWithRed:68.0/255.0 green:214.0/255.0 blue:157.0/255.0 alpha:1];
}

+ (UIColor *)defaultGreenColor
{
    //return [UIColor colorWithRed:91.0/255.0 green:190.0/255.0 blue:12.0/255.0 alpha:1];
    return [UIColor hexColor:@"06c1ae"];
}

//#e6e6e6
+ (UIColor *)defaultButtonInactiveColor
{
    return [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
}

+ (UIColor *)defaultButtonBackgroundColor2
{
    return [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
}

//#f1857e
+ (UIColor *)defaultRedColor
{
    return [UIColor hexColor:@"f1857e"];
}

+ (UIColor *)otherRedColor{
    return [UIColor hexColor:@"ff565b"];
}

+ (UIColor *)tabbarWordTextColor{
    return [UIColor hexColor:@"777777"];
}

+ (UIColor *)highlightTextColor{
    return [UIColor hexColor:@"222222"];
}

+ (UIColor *)hex6TextColor{
    return [UIColor hexColor:@"666666"];
}

+ (UIColor *)hexF5F5F5Color{
    return [UIColor hexColor:@"F5F5F5"];
}

+ (UIColor *)hexAColor{
    return [UIColor hexColor:@"aaaaaa"];
}

+ (UIColor *)hexf6f6f9Color{
    return [UIColor hexColor:@"f6f6f9"];
}

+ (UIColor *)hex000000Color{
    return [UIColor hexColor:@"000000"];
}

+ (UIColor *)defaultPinkColor {
    return [UIColor hexColor:@"ff5277"];
}

@end
