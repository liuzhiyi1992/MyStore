//
//  ForumSearchResultCell.m
//  Sport
//
//  Created by haodong  on 15/5/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumSearchResultCell.h"

@interface ForumSearchResultCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation ForumSearchResultCell

+ (CGFloat)getCellHeight
{
    return 48;
}

+ (NSString *)getCellIdentifier
{
    return @"ForumSearchResultCell";
}

- (void)updateCellWith:(NSString *)name
                  city:(NSString *)city
             indexPath:(NSIndexPath *)indexPath
                isLast:(BOOL)isLast
{
    self.nameLabel.text = name;
    
    UIImage *image = nil;
    if (indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    UIImageView *bv = [[UIImageView alloc] initWithImage:image] ;
    [self setBackgroundView:bv];
}

@end
