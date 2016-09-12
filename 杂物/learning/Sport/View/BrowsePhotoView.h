//
//  BrowsePhotoView.h
//  Sport
//
//  Created by haodong  on 14-5-8.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowsePhotoView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIControl *mainControl;

@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

+ (BrowsePhotoView *)createBrowsePhotoView;

//- (void)show:(NSString *)imageUrl;

- (void)showImageList:(NSArray *)imageList openIndex:(NSUInteger)openIndex;

@end
