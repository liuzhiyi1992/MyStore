//
//  OtherServiceView.h
//  Sport
//
//  Created by haodong  on 13-6-27.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class OtherServiceItem;

@interface OtherServiceView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (OtherServiceView *)createOtherServiceView;

+ (CGSize)defaultSize;

+ (CGFloat)getHeight;

+ (CGFloat)getWidth:(OtherServiceItem *)item;

- (void)updateView:(OtherServiceItem *)item;

@end
