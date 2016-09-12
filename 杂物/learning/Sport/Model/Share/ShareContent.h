//
//  ShareContent.h
//  Sport
//
//  Created by qiuhaodong on 15/5/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareContent : NSObject

@property (strong, nonatomic) UIImage *thumbImage;  //微信分享web时用到
@property (copy, nonatomic) NSString *title;      //微信分享web时用到
@property (copy, nonatomic) NSString *subTitle;   //微信分享web时用到

@property (strong, nonatomic) UIImage *image;       //新浪微博用到
@property (copy, nonatomic) NSString *imageUrL;   //新浪微博用到

@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *linkUrl;

@end
