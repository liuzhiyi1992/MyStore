//
//  DDTableViewCell.m
//  QueueUp
//
//  Created by haodong on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DDTableViewCell.h"



@implementation DDTableViewCell

+ (NSString*)getCellIdentifier
{
    return @"DDTableViewCell";
}

+ (id)createCell
{
    NSString *cellId = [self getCellIdentifier];
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
      //  NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    DDTableViewCell *cell = [topLevelObjects objectAtIndex:0];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }

    return cell;
}

+ (CGFloat)getCellHeight
{
    return 44;
}


@end
