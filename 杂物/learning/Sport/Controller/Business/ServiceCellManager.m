//
//  ServiceCellManager.m
//  Sport
//
//  Created by haodong  on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ServiceCellManager.h"

@interface ServiceCellManager()
@property (strong, nonatomic) UITextView *myTextView;
@end

static ServiceCellManager *_globalServiceCellManager= nil;

@implementation ServiceCellManager


+ (ServiceCellManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalServiceCellManager == nil) {
            _globalServiceCellManager = [[ServiceCellManager alloc] init];
            [_globalServiceCellManager initData];
        }
    });
    return _globalServiceCellManager;
}

- (void)initData
{
    self.myTextView = [self createTextView];
}

#define X_TEXT_VIEW 114
#define MAX_WIDTH_TEXT_VIEW ([UIScreen mainScreen].bounds.size.width - X_TEXT_VIEW - 10)
#define MAX_HEIGHT_TEXT_VIEW 300
- (CGSize)sizeWithText:(NSString *)text
{
    _myTextView.text = text; ;
    return [_myTextView sizeThatFits:CGSizeMake(MAX_WIDTH_TEXT_VIEW, MAX_HEIGHT_TEXT_VIEW)];
}

- (UITextView *)createTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(X_TEXT_VIEW-20,0, MAX_WIDTH_TEXT_VIEW, MAX_HEIGHT_TEXT_VIEW)] ;
    //textView.backgroundColor = [UIColor blueColor];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [SportColor highlightTextColor];
    textView.font = [UIFont systemFontOfSize:12];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    if ([textView respondsToSelector:@selector(setSelectable:)]) {
        [textView setSelectable:NO];
    }
    return textView;
}

@end
