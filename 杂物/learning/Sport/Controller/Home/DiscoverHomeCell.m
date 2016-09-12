//
//  DiscoverHomeCell.m
//  Sport
//
//  Created by xiaoyang on 16/5/10.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DiscoverHomeCell.h"
#import "UIImageView+WebCache.h"

@interface DiscoverHomeCell()

@property (copy, nonatomic) NSString *value;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
@implementation DiscoverHomeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"DiscoverHomeCell";
    DiscoverHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil){
        cell = [DiscoverHomeCell createCell];
    }
    return cell;
}

+ (NSString *)getCellIdentifier
{
    return @"DiscoverHomeCell";
}

+ (CGFloat)getCellHeight
{
    return 50.0;
}

+ (id)createCell{
    DiscoverHomeCell *cell = (DiscoverHomeCell *)[super createCell];
    cell.arrowImageView.image = [SportImage arrowRightImage];
    return cell;
}

- (void)updateCell:(NSString *)value
         iconImageUrl:(NSString *)iconImageUrl
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast{
    
    self.value = value;
    self.indexPath = indexPath;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:iconImageUrl] placeholderImage:[UIImage imageNamed:@"discoverControllerForum"]];
    self.valueLabel.text = value;
    
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
