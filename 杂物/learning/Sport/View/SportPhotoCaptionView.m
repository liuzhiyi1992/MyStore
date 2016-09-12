//
//  SportPhotoCaptionView.m
//  Sport
//
//  Created by 江彦聪 on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportPhotoCaptionView.h"
#import "MWPhoto.h"

static const CGFloat labelPadding = 10;
@interface SportPhotoCaptionView()

@property (strong, nonatomic) UILabel *pageLabel;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) MWPhoto *photo;
@property (assign, nonatomic) unsigned long currentIndex;
@property (assign, nonatomic) unsigned long totalPage;
@end
@implementation SportPhotoCaptionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithPhoto:(id<MWPhoto>)photo
       currentIndex:(unsigned long) currentIndex
          totalPage:(unsigned long) totalPage
{
    self.photo = photo;
    self.currentIndex = currentIndex;
    self.totalPage = totalPage;

    return [super initWithPhoto:photo];
}

- (void)setupCaption
{
    [super setupCaption];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [super sizeThatFits:size];

}

-(void)setupTextCaption {
    _label = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                                      self.bounds.size.width-labelPadding*2,
                                                                      self.bounds.size.height/2))];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    _label.numberOfLines = 0;
    _label.textColor = [UIColor whiteColor];
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_0) {
        // Shadow on 6 and below
        _label.shadowColor = [UIColor blackColor];
        _label.shadowOffset = CGSizeMake(1, 1);
    }
    _label.font = [UIFont systemFontOfSize:14];
    
    if ([_photo respondsToSelector:@selector(caption)]) {
        _label.text = [_photo caption] ? [_photo caption] : @" ";
    }
    [self addSubview:_label];

}

- (void)setupPageCaption {
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, self.label.frame.size.height,
                                                                          self.bounds.size.width-labelPadding*2,
                                                                          self.bounds.size.height/2))];
    _pageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pageLabel.opaque = NO;
    _pageLabel.backgroundColor = [UIColor clearColor];

    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _pageLabel.numberOfLines = 0;
    _pageLabel.textColor = [UIColor whiteColor];
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_0) {
        // Shadow on 6 and below
        _pageLabel.shadowColor = [UIColor blackColor];
        _pageLabel.shadowOffset = CGSizeMake(1, 1);
    }
    
    _pageLabel.font = [UIFont systemFontOfSize:14];
    if ([_photo respondsToSelector:@selector(caption)]) {
        _pageLabel.text = [NSString stringWithFormat:@"   %lu %@ %lu", (unsigned long)(_currentIndex + 1), NSLocalizedString(@"/", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)_totalPage];
    }
    
    [self addSubview:_pageLabel];
}

@end
