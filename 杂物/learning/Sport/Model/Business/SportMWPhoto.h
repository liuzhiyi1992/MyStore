//
//  SportMWPhoto.h
//  Sport
//
//  Created by 江彦聪 on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MWPhoto.h"

@interface SportMWPhoto : MWPhoto

@property (strong,nonatomic) NSString *title;
@property (assign, nonatomic) int index;
+ (SportMWPhoto *)photoWithURL:(NSURL *)url;

@end
