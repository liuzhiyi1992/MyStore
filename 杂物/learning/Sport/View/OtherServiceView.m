//
//  OtherServiceView.m
//  Sport
//
//  Created by haodong  on 13-6-27.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "OtherServiceView.h"
#import "OtherServiceItem.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"

@implementation OtherServiceView

+ (OtherServiceView *)createOtherServiceView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OtherServiceView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

+ (CGSize)defaultSize
{
    return CGSizeMake(39, 41);
}

+ (CGFloat)getHeight
{
    //return 18;
    return [self defaultSize].height;
}

#define FONT_NAME [UIFont systemFontOfSize:12]
+ (CGFloat)getWidth:(OtherServiceItem *)item
{
//    CGSize size = [item.name sizeWithFont:FONT_NAME];
//    return 25 + size.width + 12;
    return [self defaultSize].width;
}

- (void)updateView:(OtherServiceItem *)item
{
    self.nameLabel.text = [item name];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrl]];
    
    //CGSize size = [item.name sizeWithFont:FONT_NAME];
    //[self.nameLabel updateWidth:size.width + 12];
    //[self updateWidth:25 + size.width + 12];
}


@end
