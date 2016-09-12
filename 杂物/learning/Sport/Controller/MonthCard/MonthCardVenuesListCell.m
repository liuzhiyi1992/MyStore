//
//  MonthCardVenuesListCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardVenuesListCell.h"

#import "UIImageView+WebCache.h"
#import "UserManager.h"
#import "BusinessCategory.h"
@interface MonthCardVenuesListCell()
@property (strong, nonatomic) Business* business;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *venuesImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) NSMutableArray *categoryList;

@end

@implementation MonthCardVenuesListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(NSMutableArray *)categoryList
{
    if (_categoryList == nil) {
        _categoryList = [[NSMutableArray alloc]init];
    }
    
    return _categoryList;
}

+ (NSString *)getCellIdentifier
{
    return @"MonthCardVenuesListCell";
}

// default
+ (CGFloat)getCellHeight
{
    return 100;
}

- (void)updateCell:(Business *)business
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    
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
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image];
    [self setBackgroundView:bv];
    
    [self.venuesImageView  sd_setImageWithURL:[NSURL URLWithString:business.imageUrl] placeholderImage:[SportImage businessDefaultImage]];
    [self.venuesImageView setClipsToBounds:YES];
    [self.venuesImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.nameLabel.text = business.name;
    self.regionLabel.text = [NSString stringWithFormat:@"【%@】",business.neighborhood];
    
    CLLocation *userLocation = [[UserManager defaultManager] readUserLocation];
    CLLocation *businessLocation = [[CLLocation alloc] initWithLatitude:business.latitude longitude:business.longitude];
    CLLocationDistance distance = [userLocation distanceFromLocation:businessLocation];
    
    if (userLocation == nil) {
        //self.distanceLabel.text = @"未知距离";
        self.distanceLabel.text = @"";
    } else {
        if (distance >= 1000.0) {
            self.distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", distance/1000.0];
        } else {
            if (distance < 100.0) {
                self.distanceLabel.text = @"<100m";
            } else {
                self.distanceLabel.text = [NSString stringWithFormat:@"%d0m", (int)distance/10];
            }
        }
    }
    
    for (UIImageView *view in self.categoryList) {
        [view removeFromSuperview];
    }
    
    int promoteMessageIndex = 0;
    UIImageView *previousCategoryIcon = nil;
    NSMutableDictionary *viewsDictionary = [[ NSMutableDictionary alloc] initWithDictionary:
                                             @{@"nameLabel":self.nameLabel,
                                               @"regionLabel":self.regionLabel,
                                               @"contentView":self.contentView
                                               }];
    NSMutableArray *constraints = [NSMutableArray array];
    for (BusinessCategory *category  in business.categoryList) {
        UIImageView *view = nil;
        if (promoteMessageIndex + 1 > [_categoryList count]) {
            view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
            [self.categoryList addObject:view];
            
        } else {
            view = [_categoryList objectAtIndex:promoteMessageIndex];
        }
        
        [self.contentView addSubview:view];
        //view.hidden = NO;
        
        [view sd_setImageWithURL:[NSURL URLWithString:category.imageUrl]];
        
        [viewsDictionary addEntriesFromDictionary:@{@"currentIcon":view}];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (promoteMessageIndex == 0) {
            //第一个活动与region左对齐，而且有垂直间隔为5
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[regionLabel]-5-[currentIcon]" options:NSLayoutFormatAlignAllLeading metrics:nil views:viewsDictionary]];
            //[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[currentView]-10-|" options:0 metrics:nil views:viewsDictionary]];
        }
        else {
            
            [viewsDictionary addEntriesFromDictionary:@{@"prevIcon":previousCategoryIcon}];
            if (previousCategoryIcon != nil) {
                // 活动之间水平间距
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[prevIcon]-3-[currentIcon]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDictionary]];
            }
            else {
                HDLog(@"previous view is nil, promoteMessageIndex = %d", promoteMessageIndex);
            }
        }
        
//        //活动高度
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[currentIcon(20)]" options:0 metrics:nil views:viewsDictionary]];
//        //活动宽度
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[currentIcon(20)]" options:0 metrics:nil views:viewsDictionary]];
        
        previousCategoryIcon = view;
        promoteMessageIndex ++;
    }
    
    [self.contentView addConstraints:constraints];

    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    
}

@end
