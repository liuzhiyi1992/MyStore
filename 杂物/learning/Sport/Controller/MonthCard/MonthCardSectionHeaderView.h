//
//  MonthCardSectionHeaderView.h
//  Sport
//
//  Created by 江彦聪 on 15/6/7.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthCardSectionHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
+ (NSString *)getCellIdentifier;
@end
