//
//  SystemMessageImageCell.h
//  Sport
//
//  Created by 江彦聪 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

//#import <RongIMKit/RongIMKit.h>
#import "SystemMessage.h"

@protocol  SystemMessageImageCellDelegate<NSObject>
- (void)pushWebViewWithUrl:(NSString *)url
                     title:(NSString *)title;

@end
@interface SystemMessageImageCell : DDTableViewCell
- (void)updateCell:(SystemMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@property (weak, nonatomic) id<SystemMessageImageCellDelegate>delegate;
@end
