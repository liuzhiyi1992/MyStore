//
//  LoginDelegate.h
//  Sport
//
//  Created by qiuhaodong on 15/6/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginDelegate <NSObject>
@optional
- (void)didLoginAndPopController:(NSString *)parameter;
@end
