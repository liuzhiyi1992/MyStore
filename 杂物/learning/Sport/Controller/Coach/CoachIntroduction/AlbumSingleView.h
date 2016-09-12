//
//  AlbumSingleView.h
//  Coach
//
//  Created by quyundong on 15/9/1.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachPhoto.h"

@protocol AlbumSingleViewDelegate <NSObject>
@optional
- (void)didClickAlbumSingleView:(int)index;
@end
@interface AlbumSingleView : UIView

@property (assign, nonatomic) id<AlbumSingleViewDelegate> delegate;

+ (AlbumSingleView *)createBookingSimpleView;

+ (CGSize)defaultSize;

- (void)updatView:(CoachPhoto *)onePhoto
            index:(int)index;

@end
