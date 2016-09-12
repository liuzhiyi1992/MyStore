//
//  UILabel+Utils.m
//  Sport
//
//  Created by 江彦聪 on 15/8/3.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UILabel+Utils.h"

@implementation UILabel (Utils)

static const CGFloat labelPadding = 3;
- (CGSize)sizeThatMyFits:(CGSize)size {
    CGFloat maxHeight = 9999;
    if (self.numberOfLines > 0) maxHeight = self.font.leading*self.numberOfLines;
    CGSize textSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textSize = [self.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:self.font}
                                                        context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [self.text sizeWithFont:self.font
                                      constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                          lineBreakMode:self.lineBreakMode];
#pragma clang diagnostic pop
    }
    
    return CGSizeMake(size.width, (textSize.height + labelPadding * 2));
}
@end
