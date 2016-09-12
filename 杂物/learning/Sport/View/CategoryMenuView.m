//
//  CategoryMenuView.m
//  Sport
//
//  Created by haodong  on 13-6-12.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "CategoryMenuView.h"
#import "BusinessCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"

@interface CategoryMenuView()

@property (strong, nonatomic) BusinessCategory *category;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *clubImageViewConstraintX;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;

@end

@implementation CategoryMenuView

+ (CategoryMenuView *)createCategoryMenuView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategoryMenuView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    CategoryMenuView *view = [topLevelObjects objectAtIndex:0];
    [view updateWidth:[self defaultSize].width];
//    [view.clubImageView updateOriginX:view.center.x + 10];
    view.clubImageViewConstraintX.constant = view.center.x + 12;
    UIImage *image = [[SportColor createImageWithColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1]] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    [view.backgroundButton setBackgroundImage:image forState:UIControlStateHighlighted];
    return view;
}

+ (CGSize)defaultSize
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, 85);
}

//由于button的setImageWithURL有问题，所以用imageview加载网络图片
- (void)updateView:(BusinessCategory *)oneCategory index:(int)index
{
    self.category = oneCategory;
    self.nameLabel.text = oneCategory.name;
    //配合UI Automation Test
    self.backgroundButton.accessibilityLabel = oneCategory.name;
    self.totalCountLable.text = [NSString stringWithFormat:@"%d", (int)oneCategory.totalCount];
    
//    HDLog(@"imageUrl:%@", oneCategory.imageUrl);
//    HDLog(@"activeImageUrl:%@", oneCategory.activeImageUrl);
    
    //是否显示动club图标
    if (oneCategory.isSupportClub == YES) {
        self.clubImageView.hidden = NO;
    }else{
        self.clubImageView.hidden = YES;
    }
    
    [self.normalImageView sd_setImageWithURL:[NSURL URLWithString:oneCategory.imageUrl] placeholderImage:[SportImage categoryImage:oneCategory.name isSelected:NO]];
    [self.selectedImageView sd_setImageWithURL:[NSURL URLWithString:oneCategory.activeImageUrl] placeholderImage:[SportImage categoryImage:oneCategory.name isSelected:YES]];
    
    //HDLog(@"active image url:%@", oneCategory.activeImageUrl);
    
    self.normalImageView.hidden = NO;
    self.selectedImageView.hidden = YES;
}

- (IBAction)clickCategoryButton:(id)sender {
    HDLog(@"touchUpInside");
    
    self.normalImageView.hidden = NO;
    self.selectedImageView.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(didClickCategoryButton:)]) {
        [_delegate didClickCategoryButton:_category];
    }
}

- (IBAction)touchCancel:(id)sender {
    HDLog(@"touchCancel");
    self.normalImageView.hidden = NO;
    self.selectedImageView.hidden = YES;
}

- (IBAction)touchDown:(id)sender {
    HDLog(@"touchDown");
    self.normalImageView.hidden = YES;
    self.selectedImageView.hidden = NO;
}

- (IBAction)touchDragExit:(id)sender {
    HDLog(@"touchDragExit");
    self.normalImageView.hidden = NO;
    self.selectedImageView.hidden = YES;
}

@end
