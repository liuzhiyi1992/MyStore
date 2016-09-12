//
//  SportMWPhotoBrowser.h
//  Sport
//
//  Created by 江彦聪 on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MWPhotoBrowser.h"
#import "SportMWPhoto.h"

@interface SportMWPhotoBrowser : MWPhotoBrowser<MWPhotoBrowserDelegate>

@property (strong,nonatomic) NSMutableArray *photoList;
@property (assign, nonatomic) NSUInteger totalNumber;
- (CGRect)frameForPagingScrollView;
-(void) setPageViewAtIndex:(NSUInteger)index;
-(id)initMWPhotoBrowserWithDelegate:(id <MWPhotoBrowserDelegate>)delegate;
-(id)initWithPhotoList:(NSMutableArray *)list
             openIndex:(int) index;
@end
