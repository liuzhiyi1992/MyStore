//
//  ActivityPeopleCell.m
//  Sport
//
//  Created by haodong  on 14-3-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ActivityPeopleCell.h"
#import "ActivityPromise.h"

@interface ActivityPeopleCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation ActivityPeopleCell

+ (NSString*)getCellIdentifier
{
    return @"ActivityPeopleCell";
}

+ (CGFloat)getCellHeight
{
    return 74;
}

- (void)updateCellWithPromise:(ActivityPromise *)promise indexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)clickAgreeButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickAgreeButton:)]) {
        [_delegate didClickAgreeButton:_indexPath];
    }
}

- (IBAction)clickRejectButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickRejectButton:)]) {
        [_delegate didClickRejectButton:_indexPath];
    }
}

@end
