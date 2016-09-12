//
//  FacilityCell.m
//  Sport
//
//  Created by haodong  on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "FacilityCell.h"
#import "Business.h"
#import "UIImageView+WebCache.h"

@interface FacilityCell()

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageCountButton;

@property (weak, nonatomic) IBOutlet UILabel *firstValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondValueLabel;

@end

@implementation FacilityCell


+ (NSString *)getCellIdentifier
{
    return @"FacilityCell";
}

+ (CGFloat)getCellHeight
{
    return 85;
}

+ (id)createCell
{
    FacilityCell *cell = [super createCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.imageCountButton setBackgroundImage:[SportImage numberGrayBackgroundImage] forState:UIControlStateNormal];
    cell.thumbImageView.layer.cornerRadius = 1;
    cell.thumbImageView.layer.masksToBounds = YES;
    return cell;
}

- (void)updateCellWithFacility:(Facility *)facility
                     indexPath:(NSIndexPath *)indexPath
                        isLast:(BOOL)isLast
{
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
    
    NSURL *thumbUrl = (facility.thumbImageUrl ? [NSURL URLWithString:facility.thumbImageUrl] : nil);
    [self.thumbImageView sd_setImageWithURL:thumbUrl placeholderImage:[SportImage defaultImage_143x115]];
    
    NSURL *iconUrl = (facility.iconImageUrl ? [NSURL URLWithString:facility.iconImageUrl] : nil);
    [self.iconImageView sd_setImageWithURL:iconUrl placeholderImage:nil];
    
    self.nameLabel.text = facility.name;
    
    self.valueLabel.text = @"";
    self.firstValueLabel.text = @"";
    self.secondValueLabel.text = @"";
    
    if ([facility.valueList count] == 1) {
        self.valueLabel.hidden = NO;
        self.firstValueLabel.hidden = YES;
        self.secondValueLabel.hidden = YES;
        self.valueLabel.text = [facility.valueList objectAtIndex:0];
        
    } else if ([facility.valueList count] >= 2) {
        self.valueLabel.hidden = YES;
        self.firstValueLabel.hidden = NO;
        self.secondValueLabel.hidden = NO;
        self.firstValueLabel.text = [facility.valueList objectAtIndex:0];
        self.secondValueLabel.text = [facility.valueList objectAtIndex:1];
    }
    
    if (facility.imageCount > 0) {
        self.imageCountButton.hidden = NO;
        [self.imageCountButton setTitle:[@(facility.imageCount) stringValue] forState:UIControlStateNormal];
    } else {
        self.imageCountButton.hidden = YES;
    }
}

@end
