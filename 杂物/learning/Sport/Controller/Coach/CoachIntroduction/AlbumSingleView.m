//
//  AlbumSingleView.m
//  Coach
//
//  Created by quyundong on 15/9/1.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import "AlbumSingleView.h"
#import "UIImageView+WebCache.h"

@interface AlbumSingleView ()
@property (weak, nonatomic) IBOutlet UIImageView *singleImageView;
@property (assign, nonatomic) int index;
@end

@implementation AlbumSingleView


+ (AlbumSingleView *)createBookingSimpleView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AlbumSingleView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    AlbumSingleView *view = [topLevelObjects objectAtIndex:0];

    
    return view;
}

+ (CGSize)defaultSize
{
    return CGSizeMake(83, 79);
}

- (void)updatView:(CoachPhoto *)onePhoto
            index:(int)index
{
    self.index = index;
    [self.singleImageView sd_setImageWithURL:[NSURL URLWithString:onePhoto.thumbUrl] placeholderImage:nil];
}

- (IBAction)clickImageButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didClickAlbumSingleView:)]) {
        [_delegate didClickAlbumSingleView:self.index];
    }
}

@end
