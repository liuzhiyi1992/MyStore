//
//  UITableView+Utils.m
//  Sport
//
//  Created by 江彦聪 on 15/6/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UITableView+Utils.h"

@implementation UITableView (Utils)

- (void)sizeHeaderToFit:(CGFloat)height
{
    UIView *header = self.tableHeaderView;
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        [header setNeedsLayout];
        [header layoutIfNeeded];
    }
    
    if (height == 0) {
        height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    
    CGRect frame = header.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.size.height = height;
    header.frame = frame;
    
    self.tableHeaderView = header;
}

- (void)sizeFooterToFit:(CGFloat)height
{
    UIView *footer = self.tableFooterView;
    
    [footer setNeedsLayout];
    [footer layoutIfNeeded];
    
    if (height == 0) {
        height = [footer systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    
    
    CGRect frame = footer.frame;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.size.height = height;
    footer.frame = frame;
    
    self.tableFooterView = footer;
}

@end
