//
//  BusinessDetailIntroduceView.m
//  Sport
//
//  Created by xiaoyang on 16/8/8.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessDetailIntroduceView.h"

@implementation BusinessDetailIntroduceView

+ (BusinessDetailIntroduceView *)createBusinessDetailIntroduceViewWithHoldViewWidth:(CGFloat)holdViewWidth
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BusinessDetailIntroduceView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    BusinessDetailIntroduceView *view = [topLevelObjects objectAtIndex:0];
    
//    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, holdViewWidth, view.frame.size.height);
    
    return view;
}

- (void)updateView:(GalleryCategory *)galleryCategory
       isSelected:(BOOL)isSelected
            index:(int)index
{
    self.index = index;
//            Facility * facility = [[Facility alloc] init];
//            facility = [business.facilityList objectAtIndex:index];
    self.introduceLabel.text = [NSString stringWithFormat:@"%@(%lu)", galleryCategory.galleryCategoryName,(unsigned long)galleryCategory.galleryCategoryCount];
    [self updateSelected:isSelected];
}

- (void)updateSelected:(BOOL)isSelected
{
    UIColor *topColor;
    UIColor *textColor;
    
    if (isSelected){
        textColor = [UIColor whiteColor];
        topColor = textColor;
        
    } else {
        textColor = [UIColor hexColor:@"666666"];
        topColor = [UIColor clearColor];
        
    }
    self.introduceLabel.textColor = textColor;
    self.topLineView.backgroundColor = topColor;
}
- (IBAction)clickIntroduceButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickBusinessDetailIntroduceViewWithIndex:)]) {
        
        [_delegate didClickBusinessDetailIntroduceViewWithIndex:_index];
    }
    [self updateSelected:YES];
}


@end
