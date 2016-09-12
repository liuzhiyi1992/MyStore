//
//  SystemMessageView.h
//  Sport
//
//  Created by 江彦聪 on 15/10/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIScrollView+SportRefresh.h"
@protocol SystemMessageCategoryListViewDelegate<NSObject>
-(void)getMessageCountList;
@end

@interface SystemMessageCategoryListView : UIView

@property (weak, nonatomic) IBOutlet UITableView *systemMessageTableView;
@property (assign, nonatomic) id<SystemMessageCategoryListViewDelegate> delegate;

+ (SystemMessageCategoryListView *)createSystemMessageCategoryListViewWithFrame:(CGRect)frame
                                                                     controller:(UIViewController *)controller;
- (void)queryData;
@end
