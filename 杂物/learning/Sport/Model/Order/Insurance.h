//
//  Insurance.h
//  Sport
//
//  Created by 江彦聪 on 16/1/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Insurance : NSObject
@property (copy, nonatomic) NSString *insuranceId;
@property (copy, nonatomic) NSString *insuranceName;
@property (assign, nonatomic) float unitPrice;
@end
