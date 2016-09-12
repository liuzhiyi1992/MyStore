//
//  BrowsePhotoSubView.m
//  Sport
//
//  Created by 江彦聪 on 15/3/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "BrowsePhotoSubView.h"

@interface BrowsePhotoSubView()

@property (assign,nonatomic) CGSize imageSize;

@end

@implementation BrowsePhotoSubView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



+ (BrowsePhotoSubView *)createBrowsePhotoSubViewWithFrame:(CGRect) frame
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BrowsePhotoSubView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    BrowsePhotoSubView *view = (BrowsePhotoSubView *)[topLevelObjects objectAtIndex:0];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.frame = frame;
    view.delegate = view;
    view.scrollEnabled = NO;
    view.bouncesZoom = YES;
    view.minimumZoomScale = 1.0f;
    view.maximumZoomScale = 2.0f;
    view.zoomScale = 1.0;
    view.subImageView.contentMode = UIViewContentModeScaleAspectFit;
    view.contentInset = UIEdgeInsetsMake(5.0, 0, 5.0, 0);
    [view addTapRecognizer];
    return view;
}

- (void) addTapRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(tapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    
    [self addGestureRecognizer:tapGesture];
    
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(scrollViewDoubleTapped:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTapGesture];
    
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
}


- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:self.subImageView];
    CGFloat newZoomScale;
    
    if (self.zoomScale == 1.0f) {
        
        // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
        newZoomScale = self.maximumZoomScale;
    }
    else
    {
        newZoomScale = 1.0f;
    
    }
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self zoomToRect:rectToZoomTo animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.subImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
   if (self.zoomScale > 1) {
       scrollView.scrollEnabled = YES;
    }
    else {
        scrollView.scrollEnabled = NO;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self centerScrollViewContents];
    
}

- (void)centerScrollViewContents {
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.subImageView.frame;
    
    // center horizontally
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    // center vertically
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.subImageView.frame = contentsFrame;
}


- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    [self.superview.superview removeFromSuperview];
}


@end
