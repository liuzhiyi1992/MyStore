//
//  CategorySimpleView.m
//  Sport
//
//  Created by haodong  on 13-6-26.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "CategorySimpleView.h"
#import "BusinessCategory.h"
#import "UIImageView+WebCache.h"

@interface CategorySimpleView()
@property (strong, nonatomic) BusinessCategory *category;
@property (assign, nonatomic) int index;
@end

@implementation CategorySimpleView

+ (CategorySimpleView *)createCategorySimpleView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategorySimpleView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

+ (CGSize)defaultSize
{
    return CGSizeMake(82, 44);
}

- (void)updateText:(BusinessCategory *)oneCategory index:(int)index
{
    self.category = oneCategory;
    self.nameLabel.text = oneCategory.name;
    self.index = index;
    //[self.smallImageView setImageWithURL:[NSURL URLWithString:oneCategory.smallImageUrl]];
    [self.smallImageView sd_setImageWithURL:[NSURL URLWithString:oneCategory.smallImageUrl] placeholderImage:[SportImage smallCategoryImage:oneCategory.name]];
}

- (void)updateSelected:(BOOL)isSelected
{
    if (isSelected) {
        self.backgroundImageView.image = [SportImage categorySimpleSelectedImage];
    } else {
        self.backgroundImageView.image = [SportImage categorySimpleImage];
    }
}

- (IBAction)clickCategoryButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickCategoryButton:)]) {
        [_delegate didClickCategoryButton:_index];
    }
}

@end
