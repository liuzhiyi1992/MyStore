//
//  SportLazyScrollView.m
//  Sport
//
//  Created by 江彦聪 on 15/6/4.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportLazyScrollView.h"

@interface SportLazyScrollView()

@property (strong, nonatomic) NSMutableArray* viewControllerArray;
@end


@implementation SportLazyScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
}

-(id)initWithFrame:(CGRect)frame
          numberOfPages:(NSUInteger)numberOfPages
          delegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.viewControllerArray = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
        for (NSUInteger k = 0; k < numberOfPages; ++k) {
            [self.viewControllerArray addObject:[NSNull null]];
        }
        
        [self setEnableCircularScroll:YES];
        [self setAutoPlay:YES];
        self.sportDelegate = delegate;
        self.controlDelegate = self;
        
        __weak __typeof(&*self)weakSelf = self;
        self.dataSource = ^(NSUInteger index) {
            return [weakSelf controllerAtIndex:index];
        };
        
        self.numberOfPages = numberOfPages;
        self.scrollsToTop = NO;
    }
    
    return self;
}

- (void)lazyScrollView:(DMLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex
{
    if ([_sportDelegate respondsToSelector:@selector(SportLazyScrollViewCurrentPageChanged:)]) {
        [_sportDelegate SportLazyScrollViewCurrentPageChanged:currentPageIndex];
    }
}

#define ARC4RANDOM_MAX	0x100000000
- (UIViewController *) controllerAtIndex:(NSInteger) index {
    if (index >= _viewControllerArray.count || index < 0) return nil;
    id res = [_viewControllerArray objectAtIndex:index];
    if (res == [NSNull null]) {
        UIViewController *contr = [[UIViewController alloc] init];
        
        if ([_sportDelegate respondsToSelector:@selector(SportLazyScrollViewGetSubView:)]) {
            UIView *subView = [_sportDelegate SportLazyScrollViewGetSubView:index];
            [contr.view addSubview:subView];
        }
        
        [_viewControllerArray replaceObjectAtIndex:index withObject:contr];
        return contr;
    }
    return res;
}


@end
