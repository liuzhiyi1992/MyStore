//
//  CoachOrderSectionHeaderView.h
//  Sport
//
//  Created by 江彦聪 on 15/7/21.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachOrderSectionHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
+ (NSString *)getCellIdentifier;

@end
