//
//  BrowsePhotoSubView.h
//  Sport
//
//  Created by 江彦聪 on 15/3/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowsePhotoSubView : UIScrollView<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;

+ (BrowsePhotoSubView *)createBrowsePhotoSubViewWithFrame:(CGRect) frame;
- (void)centerScrollViewContents;
@end
