//
//  BrowsePhotoView.m
//  Sport
//
//  Created by haodong  on 14-5-8.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BrowsePhotoView.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import "BrowsePhotoSubView.h"

@interface BrowsePhotoView()
{
    int previousPage;
    int page;

}
@property (retain,nonatomic) NSArray *imageList;
@property (assign,nonatomic) CGAffineTransform oriTransform;
@property (assign,nonatomic) CGPoint oriCenter;
//@property (retain,nonatomic) UITapGestureRecognizer *tapGesture;
@end

@implementation BrowsePhotoView

+ (BrowsePhotoView *)createBrowsePhotoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BrowsePhotoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    BrowsePhotoView *view = (BrowsePhotoView *)[topLevelObjects objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    view.mainScrollView.delegate = view;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [view updateHeight:screenHeight];
    [view.mainScrollView updateHeight:screenHeight];
    [view.pageLabel updateOriginY:screenHeight - 43];
    
    return view;
}


#pragma mark - Now we use sub scroll view instead, just keep it here
- (void) pinch:(UIPinchGestureRecognizer *)sender
{
    UIView *view = sender.view;
   
    if(([sender state] == UIGestureRecognizerStateChanged) ||
       ([sender state] == UIGestureRecognizerStateEnded)){
        
        CGAffineTransform currentTransform = self.mainScrollView.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, sender.scale, sender.scale);

        if (newTransform.a / _oriTransform.a < 0.8)
        {
            newTransform = CGAffineTransformScale(_oriTransform, 0.8,0.8);
        }
        else if (newTransform.a / _oriTransform.a > 3)
        {
            newTransform = CGAffineTransformScale(_oriTransform, 3,3);
        }

        [UIView animateWithDuration:0.2 animations:^{
            [view setTransform:newTransform];
        }];
        
        sender.scale = 1.0;
    }
}
//
//
//- (void)addTapGestureRecognizer
//{
//    self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
//                                                            action:@selector(tapGesture:)]autorelease];
//    [self.mainScrollView addGestureRecognizer:self.tapGesture];
//    //[tapGesture release];
//}
//
//- (void)tapGesture:(UITapGestureRecognizer *)tap
//{
//    [self removeFromSuperview];
//}

//- (void)show:(NSString *)imageUrl
//{
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.activityIndicatorView startAnimating];
//    [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        [self.activityIndicatorView stopAnimating];
//    }];
//    [[UIApplication sharedApplication].keyWindow addSubview:self];
//}

//- (IBAction)clickCancelButton:(id)sender {
//    [self removeFromSuperview];
//}

#define SUB_SCROLLVIEW_TAG 100
- (void)showImageList:(NSArray *)imageList openIndex:(NSUInteger)openIndex
{
    if ([imageList count] == 0) {
        return;
    }
    
    self.imageList = imageList;

    for (UIView *subView in self.mainScrollView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    int index = 0;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    for (NSString *urlString in imageList) {
        CGRect frame = CGRectMake(screenWidth * index, 0, screenWidth, screenHeight);
        
        BrowsePhotoSubView *subScrollView = [BrowsePhotoSubView createBrowsePhotoSubViewWithFrame:frame];
        [subScrollView setTag:SUB_SCROLLVIEW_TAG + index];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] init] ;
        activityIndicatorView.hidesWhenStopped = YES;
        [activityIndicatorView setCenter:CGPointMake(screenWidth/2, _mainScrollView.center.y - 40)];
        
        [self.mainScrollView addSubview:activityIndicatorView];
        
        [_activityIndicatorView startAnimating];
        
        [subScrollView.subImageView sd_setImageWithURL:[NSURL URLWithString:urlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_activityIndicatorView stopAnimating];

            CGSize size =CGSizeAspectFit(image.size,subScrollView.subImageView.frame.size);
            subScrollView.contentSize = size;
            [subScrollView.subImageView updateWidth:size.width];
            [subScrollView.subImageView updateHeight:size.height];

            [subScrollView centerScrollViewContents];
        }];
        
        [self.mainScrollView addSubview:subScrollView];

        
        index ++;
    }
    
    _oriTransform = self.mainScrollView.transform;
    _oriCenter = self.mainScrollView.center;
    [self.mainScrollView setContentSize:CGSizeMake(screenWidth * index, _mainScrollView.frame.size.height)];
    
    [self.mainScrollView setContentOffset:CGPointMake(openIndex * screenWidth, 0)];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if ([imageList count] == 1) {
        self.pageLabel.hidden = YES;
    } else {
        previousPage = (int)openIndex + 1;
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%d", (int)openIndex + 1, (int)[_imageList count]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat scale = self.mainScrollView.transform.a/_oriTransform.a;
    page = MAX(1, offset.x*scale / scrollView.frame.size.width + 1);
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%d", page, (int)[_imageList count]];
    
    if (page != previousPage) {
        
        BrowsePhotoSubView *view = (BrowsePhotoSubView *)[self viewWithTag:SUB_SCROLLVIEW_TAG + previousPage - 1];
        if (view) {
            [view setZoomScale:1.0f animated:YES];
        }
        
        previousPage = page;
    }

}

// get the size after aspect fit
CGSize CGSizeAspectFit(CGSize aspectRatio, CGSize boundingSize)
{
    float mW = boundingSize.width / aspectRatio.width;
    float mH = boundingSize.height / aspectRatio.height;
    if( mH < mW )
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
    else if( mW < mH )
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
    return boundingSize;
}

@end
