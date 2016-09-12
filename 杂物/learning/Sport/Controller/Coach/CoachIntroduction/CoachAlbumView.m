//
//  CoachAlbumView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachAlbumView.h"
#import "SportLazyScrollView.h"
#import "UIImageView+WebCache.h"
#import "CoachPhoto.h"

@interface CoachAlbumView() <SportLazyScrollViewDelegate>
@property (assign, nonatomic) id<CoachAlbumViewDelegate> delegate;
@property (strong, nonatomic) NSArray *photolist;
@property (weak, nonatomic) IBOutlet UIView *countHolderView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@end

@implementation CoachAlbumView

#define TAG_SPORT_LAZY_SCROLLVIEW 2015072301

- (void)dealloc
{
    [(SportLazyScrollView*)[self viewWithTag:TAG_SPORT_LAZY_SCROLLVIEW] autoPlayPause];
}

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define FRAME   CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * ( 370.0 / 640.0 ))
+ (CoachAlbumView *)createViewWithPhotoList:(NSArray *)photoList
                                   delegate:(id<CoachAlbumViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachAlbumView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CoachAlbumView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    view.frame = FRAME;
    view.countHolderView.layer.cornerRadius = view.countHolderView.frame.size.height / 2;
    view.countHolderView.layer.masksToBounds = YES;
    view.photolist = photoList;
    SportLazyScrollView *sportLazyScrollView = [[SportLazyScrollView alloc] initWithFrame:FRAME numberOfPages:[photoList count] delegate:view] ;
    sportLazyScrollView.tag = TAG_SPORT_LAZY_SCROLLVIEW;
    [view insertSubview:sportLazyScrollView belowSubview:view.countHolderView];
    //[sportLazyScrollView autoPlay];
    [view updateCountLabelWithIndex:1];
    return view;
}

- (void)updateCountLabelWithIndex:(int)index
{
    if ([self.photolist count] > 0) {
        self.countHolderView.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat:@"%d/%d", index, (int)[self.photolist count]];
    } else {
        self.countHolderView.hidden = YES;
    }
}

- (void)SportLazyScrollViewCurrentPageChanged:(NSInteger)currentPageIndex
{
    [self updateCountLabelWithIndex:(int)currentPageIndex + 1];
}

#define TAG_BASE_PHOTO_BUTTON 2015072201
- (UIView *)SportLazyScrollViewGetSubView:(NSInteger)index
{
    CoachPhoto *photo = [_photolist objectAtIndex:index];
    UIView *view = [[UIView alloc] initWithFrame:FRAME];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:FRAME] ;
    [imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoUrl] placeholderImage:nil];
    imageView.contentMode= UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    UIButton *button = [[UIButton alloc] initWithFrame:FRAME] ;
    [button setBackgroundImage:[[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] stretchableImageWithLeftCapWidth:1 topCapHeight:1] forState:UIControlStateHighlighted];
    button.tag = TAG_BASE_PHOTO_BUTTON + index;
    [button addTarget:self action:@selector(clickPhotoButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:imageView];
    [view addSubview:button];
    
    return view;
}

- (void)clickPhotoButton:(id)sender
{
    int index = (int)[(UIButton *)sender tag] - TAG_BASE_PHOTO_BUTTON;
    if ([self.delegate respondsToSelector:@selector(didClickCoachAlbumViewWithIndex:)]) {
        [self.delegate didClickCoachAlbumViewWithIndex:index];
    }
}

@end
