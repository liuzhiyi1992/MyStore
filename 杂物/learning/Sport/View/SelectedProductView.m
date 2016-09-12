//
//  SelectedProductView.m
//  Sport
//
//  Created by haodong  on 15/1/27.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SelectedProductView.h"

@implementation SelectedProductView


+ (SelectedProductView *)createSelectedProductView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SelectedProductView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SelectedProductView *view = (SelectedProductView *)[topLevelObjects objectAtIndex:0];
    [view.backgroundImageView setImage:[SportImage selectedProductBackgroundImage]];
    return view;
}

+ (CGSize)defaultSize
{
    return CGSizeMake(71, 48);
}

- (void)updateViewWithValue1:(NSString *)value1 value2:(NSString *)value2
{
    self.timeLabel.text = value1;//[NSString stringWithFormat:@"%d:00-%d:00", product.hour, product.hour + 1];
    self.courtNameLabel.text = value2;//product.courtName;
}

@end
