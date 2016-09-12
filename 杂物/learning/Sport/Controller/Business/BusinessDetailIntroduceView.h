//
//  BusinessDetailIntroduceView.h
//  Sport
//
//  Created by xiaoyang on 16/8/8.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"
#import "Facility.h"
#import "GalleryCategory.h"


@protocol BusinessDetailIntroduceViewDelegate <NSObject>
@optional

- (void)didClickBusinessDetailIntroduceViewWithIndex:(NSUInteger)index;
@end

@interface BusinessDetailIntroduceView : UIView
@property (assign, nonatomic) id<BusinessDetailIntroduceViewDelegate > delegate;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (assign, nonatomic) int index;

+ (BusinessDetailIntroduceView *)createBusinessDetailIntroduceViewWithHoldViewWidth:(CGFloat)holdViewWidth;

- (void)updateView:(GalleryCategory *)galleryCategory
       isSelected:(BOOL)isSelected
            index:(int)index;

- (void)updateSelected:(BOOL)isSelected;
@end
