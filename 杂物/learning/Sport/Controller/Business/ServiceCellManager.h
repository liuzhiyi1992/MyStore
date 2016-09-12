//
//  ServiceCellManager.h
//  Sport
//
//  Created by haodong  on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceCellManager : UIView

+ (ServiceCellManager *)defaultManager;

- (CGSize)sizeWithText:(NSString *)text;

- (UITextView *)createTextView;

@end
