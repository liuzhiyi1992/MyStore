//
//  CharacteristicView.m
//  Sport
//
//  Created by haodong  on 13-8-25.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "CharacteristicView.h"
#import "UIView+Utils.h"
#import "NSString+Utils.h"

@implementation CharacteristicView

+ (CharacteristicView *)createCharacteristicView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CharacteristicView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

+ (CGFloat)getHeight
{
    return 18;
}

#define FONT_NAME [UIFont systemFontOfSize:12]
+ (CGFloat)getWidth:(NSString *)value
{
    CGSize size = [value sizeWithMyFont:FONT_NAME];
    return size.width + 12;
}

- (void)updateView:(NSString *)value index:(NSUInteger)index
{
    self.valueLabel.text = value;
    self.backgroundImageView.image = [SportImage characteristicBackgroundImage]; //[SportImage characteristicBackgroundImage:index];
    CGSize size = [value sizeWithMyFont:FONT_NAME];
    CGFloat width = size.width + 12;
    [self.valueLabel updateWidth:width];
    [self.backgroundImageView updateWidth:width];
    [self updateWidth:width];
}


@end
