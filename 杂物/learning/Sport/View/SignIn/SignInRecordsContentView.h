//
//  SignInRecordsContentView.h
//  Sport
//
//  Created by lzy on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInRecordsContentView : UIView
+ (SignInRecordsContentView *)createViewWithContent:(NSString *)content imageArray:(NSArray *)imageArray;
- (void)configureViewWithContent:(NSString *)content imageArray:(NSArray *)imageArray;
- (void)calculateContentLabelheight;
@end
