//
//  PostPhoto.h
//  Sport
//
//  Created by 江彦聪 on 15/5/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostPhoto : NSObject
@property(assign, nonatomic) NSUInteger photoIndex;
@property(copy, nonatomic) NSString *photoId;
@property(copy, nonatomic) NSString *photoImageUrl;
@property(copy, nonatomic) NSString *photoThumbUrl;
@end
