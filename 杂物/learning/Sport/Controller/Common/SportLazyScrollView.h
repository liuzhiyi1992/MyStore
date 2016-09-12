//
//  SportLazyScrollView.h
//  Sport
//
//  Created by 江彦聪 on 15/6/4.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DMLazyScrollView.h"

@class SportLazyScrollView;

@protocol SportLazyScrollViewDelegate <NSObject>

- (void)SportLazyScrollViewCurrentPageChanged:(NSInteger)currentPageIndex;
-(UIView *) SportLazyScrollViewGetSubView:(NSInteger) index;

@end


@interface SportLazyScrollView : DMLazyScrollView<DMLazyScrollViewDelegate>

-(id)initWithFrame:(CGRect)frame
     numberOfPages:(NSUInteger)numberOfPages
          delegate:(id)delegate;

@property (weak, nonatomic) id<SportLazyScrollViewDelegate> sportDelegate;
@end
