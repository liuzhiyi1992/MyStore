//
//  ProgressBar.h
//  Flo
//
//  Created by lzy on 15/12/12.
//  Copyright © 2015年 liuzhiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_FLAGIMAGE       @"KEY_FLAGIMAGE"            //UIImage
#define KEY_TITLE           @"KEY_TITLE"                //NSString
#define KEY_INDEX           @"KEY_INDEX"                //NSString
#define KEY_OFFSET_X        @"KEY_OFFSET_X"             //NSString
#define KEY_OFFSET_Y        @"KEY_OFFSET_Y"             //NSString
#define KEY_TITLE_COLOR     @"KEY_TITLE_COLOR"          //UIColor

#define KEY_ATTRIBUTED_STRING   @"KEY_ATTRIBUTED_STRING"//NSAttributedString

typedef NS_ENUM(NSInteger,ProgressBarStyle) {
    ProgressBarStyleLight = 0,
    ProgressBarStyleDark,
};

@interface ProgressBar : UIView

- (void)updateBarWithCurrentIndex:(int)currentIndex
                        maxNumber:(int)maxNumber
                        minNumber:(int)minNumber
                            style:(ProgressBarStyle)style;

- (void)updateBarWithIndex:(int)index
                     volum:(int)volum
            holderBarColor:(UIColor *)holderBarColor
           contentBarColor:(UIColor *)contentBarColor
           imageTitleColor:(UIColor *)imageTitleColor
   flagImageDictionaryList:(NSArray *)flagImageDictionaryList
 bottomFlagTitleDictionary:(NSDictionary *)bottomFlagTitleDictionary;


@end
