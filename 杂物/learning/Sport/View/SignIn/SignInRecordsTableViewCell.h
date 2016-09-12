//
//  SignInRecordsTableViewCell.h
//  Sport
//
//  Created by lzy on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"

@interface SignInRecordsTableViewCell : DDTableViewCell
- (void)updateCellWithDataDict:(NSDictionary *)dataDict;
@end
