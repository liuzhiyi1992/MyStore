//
//  ReportErrorView.h
//  Sport
//
//  Created by lzy on 16/8/11.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Business;
@interface ReportErrorView : UIView
+ (ReportErrorView *)showViewWithVenuesId:(NSString *)venuesId
                               categoryId:(NSString *)categoryId;
@end
