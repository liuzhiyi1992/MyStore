//
//  Court.h
//  Sport
//
//  Created by haodong  on 13-7-17.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Court : NSObject

@property (copy, nonatomic) NSString *courtId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *positionName;
@property (strong, nonatomic) NSArray *productList;
@property (strong, nonatomic) NSArray *productGroupList;

@end
