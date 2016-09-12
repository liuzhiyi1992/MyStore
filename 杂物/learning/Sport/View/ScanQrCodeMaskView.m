//
//  ScanQrCodeMaskView.m
//  SportBusiness
//
//  Created by 江彦聪 on 15/4/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ScanQrCodeMaskView.h"

@interface ScanQrCodeMaskView()

@property (assign,nonatomic) CGRect maskRect;

@end

@implementation ScanQrCodeMaskView

- (id)initWithFrame:(CGRect)frame
          maskFrame:(CGRect)maskRect
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.maskRect = maskRect;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect rBounds = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Fill background with 60% white
    CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor]);
    CGContextFillRect(context, rBounds);
    
    // Draw the window 'frame'
//    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
//    CGContextSetLineWidth(context, 2);
//    CGContextStrokeRect(context, self.maskRect);
    
    // make the window transparent
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillRect(context, self.maskRect);
}


@end
