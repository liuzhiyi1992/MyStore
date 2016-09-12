//
//  DDTableViewCell.h
//  QueueUp
//
//  Created by haodong on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTableViewCell : UITableViewCell

+ (NSString*)getCellIdentifier;
+ (id)createCell;
+ (CGFloat)getCellHeight;
@end
