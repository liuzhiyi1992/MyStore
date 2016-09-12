//
//  BusinessPhoto.h
//  Sport
//
//  Created by haodong  on 14-9-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessPhoto : NSObject
@property(assign, nonatomic) int photoIndex;
@property(copy, nonatomic) NSString *photoId;
@property(copy, nonatomic) NSString *photoImageUrl;
@property(copy, nonatomic) NSString *photoThumbUrl;
@property(copy, nonatomic) NSString *imageTitle;
@property(copy, nonatomic) NSString *imageDescription;

@end
