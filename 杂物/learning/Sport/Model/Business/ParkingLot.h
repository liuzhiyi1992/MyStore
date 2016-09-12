//
//  ParkingLot.h
//  Sport
//
//  Created by xiaoyang on 15/12/11.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParkingLot : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) double lon;
@property (assign, nonatomic) double lat;
@property (assign, nonatomic) double distance;

@end
