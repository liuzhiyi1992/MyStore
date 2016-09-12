//
//  ProgressBar.m
//  Flo
//
//  Created by lzy on 15/12/12.
//  Copyright © 2015年 liuzhiyi. All rights reserved.
//

#import "ProgressBar.h"
#import <CoreText/CTLine.h>

#define MARGIN_CELL 3.0f
#define HEIGHT_CELL 3.0f
#define SPACE_BORDER 15.0f
#define FONT_SIZE_FLAGIMAGE_TITLE 10.0f
@interface ProgressBar()

@property (assign, nonatomic) CGRect contentRect;
@property (assign, nonatomic) CGFloat cellWidth;
@property (assign, nonatomic) CGContextRef context;
@property (assign, nonatomic) CGFloat progressBarOriginY;
@property (assign, nonatomic) ProgressBarStyle style;
@property (assign, nonatomic) int maxNumber;
@property (assign, nonatomic) int currentIndex;
@property (assign, nonatomic) int minNumber;
@property (strong, nonatomic) UIColor *holderBarColor;
@property (strong, nonatomic) UIColor *contentBarColor;
@property (assign, nonatomic) CGPoint imageTitleOffSet;
@property (strong, nonatomic) UIColor *imageTitleColor;
@property (strong, nonatomic) NSArray *flagImageDictionaryList;
@property (strong, nonatomic) NSDictionary *bottomFlagTitleDictionary;
@property (strong, nonatomic) UIImage *beginFlagImage;
@property (strong, nonatomic) UIImage *fullFlagImage;
@property (assign, nonatomic) BOOL isDisplayBottom;
@end

@implementation ProgressBar

//如需在非xib使用，补上init方法
- (void)awakeFromNib {
    [super awakeFromNib];
    [self configure];
}

- (void)configure {
    [self setBackgroundColor:[UIColor clearColor]];
    //default值
    self.maxNumber = 6;
    self.currentIndex = 4;
    self.minNumber = 4;
    self.imageTitleOffSet = CGPointMake(0, -2);
    
    self.progressBarOriginY = self.bounds.size.height - HEIGHT_CELL;
    [self updateStyleAppearence];

    
}

- (void)updateStyleAppearence {
    BOOL isBeginActive = self.currentIndex >= self.minNumber;
    BOOL isFullActive = self.currentIndex == self.maxNumber;
    
    if (self.style == ProgressBarStyleLight) {
        self.holderBarColor =  [UIColor hexColor:@"33b1f1"];
        self.contentBarColor = [UIColor whiteColor];
        self.imageTitleColor = [SportColor defaultColor];
        self.beginFlagImage = isBeginActive?[UIImage imageNamed:@"StartWhite"]:[UIImage imageNamed:@"StartTrans"];
        self.fullFlagImage = isFullActive?[UIImage imageNamed:@"FullPersonWhite"]:[UIImage imageNamed:@"FullPersonTrans"];
        self.isDisplayBottom = NO;

    } else {
        self.holderBarColor = [UIColor hexColor:@"e9e9e9"];
        self.contentBarColor = [SportColor defaultColor];
        self.imageTitleColor = [UIColor whiteColor];
        
        self.beginFlagImage = isBeginActive?[UIImage imageNamed:@"StartBlue"]:[UIImage imageNamed:@"StartGray"];
        self.fullFlagImage = isFullActive?[UIImage imageNamed:@"FullPersonBlue"]:[UIImage imageNamed:@"FullPersonGray"];
        
        self.isDisplayBottom = YES;
    }
}

- (void)updateBarWithCurrentIndex:(int)currentIndex
                     maxNumber:(int)maxNumber
                        minNumber:(int)minNumber
                            style:(ProgressBarStyle)style{
    self.currentIndex = currentIndex;
    self.maxNumber = maxNumber;
    self.minNumber = minNumber;
    self.style = style;
    
    [self updateStyleAppearence];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)updateBarWithIndex:(int)currentIndex
                     volum:(int)volum
            holderBarColor:(UIColor *)holderBarColor
           contentBarColor:(UIColor *)contentBarColor
           imageTitleColor:(UIColor *)imageTitleColor
   flagImageDictionaryList:(NSArray *)flagImageDictionaryList
 bottomFlagTitleDictionary:(NSDictionary *)bottomFlagTitleDictionary
{
    self.currentIndex = currentIndex;
    self.maxNumber = volum;
    self.holderBarColor = holderBarColor;
    self.contentBarColor = contentBarColor;
    self.imageTitleColor = imageTitleColor;
    self.flagImageDictionaryList = flagImageDictionaryList;
    self.bottomFlagTitleDictionary = bottomFlagTitleDictionary;
    [self setNeedsDisplay];
    [self layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.context = UIGraphicsGetCurrentContext();
    
    //drawBottomFlagTitle
    if (self.isDisplayBottom) {
        //NSAttributedString *attributedStr = [self.bottomFlagTitleDictionary objectForKey:KEY_ATTRIBUTED_STRING];
        CGFloat offsetX = 0;
        CGFloat offsetY = 5;
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d/%d",self.currentIndex,self.maxNumber]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:(id)[SportColor defaultColor].CGColor range:NSMakeRange(0, 1)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(0, 1)];
        
        [attributeStr addAttribute:NSForegroundColorAttributeName value:(id)[UIColor hexColor:@"666666"].CGColor range:NSMakeRange(1, 2)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(1, 2)];
        [self drawBottomFlagTitleWithAttributeString:attributeStr offSet:CGPointMake(offsetX, offsetY)];
    }
    
    //drawProgressBar
    [self drawCellWithIndex:_maxNumber maxNumber:_maxNumber color:self.holderBarColor];
    [self drawCellWithIndex:_currentIndex maxNumber:_maxNumber color:self.contentBarColor];
    
    //drawFlagImage
//    for (NSDictionary *dict in _flagImageDictionaryList) {
//        UIImage *image = [dict objectForKey:KEY_FLAGIMAGE];
//        NSString *title = [dict objectForKey:KEY_TITLE];
//        int currentIndex = [[dict objectForKey:KEY_INDEX] intValue];
//        [self drawFlagImage:image title:title titleColor:_imageTitleColor currentIndex:currentIndex];
//    }
    
    [self drawFlagImage:self.beginFlagImage title:@"开场" titleColor:_imageTitleColor currentIndex:self.minNumber];
    [self drawFlagImage:self.fullFlagImage title:@"满员" titleColor:_imageTitleColor currentIndex:self.maxNumber];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentRect = self.bounds;
    self.cellWidth = (self.contentRect.size.width - MARGIN_CELL * (_maxNumber - 1) - 2 * SPACE_BORDER) / _maxNumber;
    self.context = UIGraphicsGetCurrentContext();
}

- (CGFloat)cellOriginXWithCellWidth:(CGFloat)cellWidth Index:(int)currentIndex maxNumber:(int)maxNumber {
    return SPACE_BORDER + currentIndex * (MARGIN_CELL + cellWidth);
}

- (void)drawCellWithIndex:(int)currentIndex maxNumber:(int)maxNumber color:(UIColor *)color {
    //裁剪圆角画布
    CGContextSaveGState(self.context);
    CGRect rounderRect = CGRectMake(SPACE_BORDER, self.progressBarOriginY, self.contentRect.size.width - 2 * SPACE_BORDER, HEIGHT_CELL);
    UIBezierPath *cutPath = [UIBezierPath bezierPathWithRoundedRect:rounderRect cornerRadius:HEIGHT_CELL/2];
    [cutPath addClip];
    
    //作画
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat pointY = _progressBarOriginY + 0.5 * HEIGHT_CELL;
    
    for (int i = 0; i < currentIndex; i ++) {
        [path moveToPoint:CGPointMake([self cellOriginXWithCellWidth:_cellWidth Index:i maxNumber:maxNumber], pointY)];
        [path addLineToPoint:CGPointMake((path.currentPoint.x + _cellWidth), pointY)];
    }
    
    [color setStroke];
    [path setLineWidth:HEIGHT_CELL];
    [path stroke];
    CGContextRestoreGState(self.context);
}

//default flagImage above the progressBar
- (void)drawFlagImage:(UIImage *)flagImage title:(NSString *)title titleColor:(UIColor *)titleColor currentIndex:(int)currentIndex {
    CGSize imageSize = flagImage.size;
    CGFloat flagCenterX = [self cellOriginXWithCellWidth:_cellWidth Index:currentIndex maxNumber:_maxNumber];
    CGPoint offset = CGPointMake(0, -3);
    //最后一个图标对齐
    if(currentIndex == _maxNumber) {
        offset = CGPointMake(-0.34 * imageSize.width, offset.y);
    }
    
    CGRect imageRect = CGRectMake(flagCenterX - imageSize.width/2 - MARGIN_CELL/2 + offset.x, self.progressBarOriginY - imageSize.height + offset.y, imageSize.width, imageSize.height);
    
    CGContextSaveGState(self.context);
    [flagImage drawInRect:imageRect];
    CGContextRestoreGState(self.context);
    
    [self drawFlagImageTitle:title color:titleColor imageRect:imageRect offSet:_imageTitleOffSet];
}

- (void)drawFlagImageTitle:(NSString *)title color:(UIColor *)color imageRect:(CGRect)imageRect offSet:(CGPoint)offSet {
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FONT_SIZE_FLAGIMAGE_TITLE], NSFontAttributeName, paragraph, NSParagraphStyleAttributeName, color, NSForegroundColorAttributeName, nil];
    
    CGSize titleSize = [title sizeWithAttributes:attribute];
    
    CGFloat fontOriginX = imageRect.origin.x + (imageRect.size.width - titleSize.width)/2 + offSet.x;
    CGFloat fontOriginY = imageRect.origin.y + (imageRect.size.height - titleSize.height)/2 + offSet.y;
    CGRect fontRect = CGRectMake(fontOriginX, fontOriginY, titleSize.width, titleSize.height);
    
    [title drawInRect:fontRect withAttributes:attribute];
}

- (void)drawBottomFlagTitleWithAttributeString:(NSAttributedString *)attributeString offSet:(CGPoint)offSet {
    
    CGSize titleSize = attributeString.size;
    CGFloat titleOriginX = [self cellOriginXWithCellWidth:_cellWidth Index:_currentIndex maxNumber:_maxNumber] - 0.5 * titleSize.width + offSet.x;
    CGFloat titleOriginY = self.bounds.size.height - titleSize.height;
    CGRect titleRect = CGRectMake(titleOriginX, titleOriginY, titleSize.width, titleSize.height);
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGContextSaveGState(_context);
    CGContextSetTextPosition(_context, titleOriginX, titleOriginY);
    CGContextTranslateCTM(_context, 0, self.bounds.size.height);//3
    CGContextScaleCTM(_context, 1.0, -1.0);//2
    CGContextTranslateCTM(_context, 0, (self.bounds.size.height - CGRectGetMaxY(titleRect) - CGRectGetMinY(titleRect)));
    CTLineDraw(line, _context);
    CGContextRestoreGState(_context);
    
    self.progressBarOriginY = self.bounds.size.height - titleSize.height - offSet.y - HEIGHT_CELL;
    //重画
    [self setNeedsDisplay];
}


@end
