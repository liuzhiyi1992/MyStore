//
//  CoachAlbumView.h
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoachAlbumViewDelegate <NSObject>
@optional
- (void)didClickCoachAlbumViewWithIndex:(int)index;
@end

@interface CoachAlbumView : UIView

+ (CoachAlbumView *)createViewWithPhotoList:(NSArray *)photoList
                                   delegate:(id<CoachAlbumViewDelegate>)delegate;

@end
