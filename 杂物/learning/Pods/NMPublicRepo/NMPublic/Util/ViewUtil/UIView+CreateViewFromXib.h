//
//  UIView+CreateViewFromXib.h
//  Sport
//
//  Created by xiaoyang on 16/4/15.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CreateViewFromXib)

+ (id)createXibView:(NSString *)className;

@end
