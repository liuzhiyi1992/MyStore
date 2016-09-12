//
//  MapBussinessView.m
//  Sport
//
//  Created by haodong  on 14-7-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "MapBussinessView.h"
#import "Business.h"

@interface MapBussinessView()
@property (strong, nonatomic) Business *business;
@end

@implementation MapBussinessView


+ (MapBussinessView *)createMapBussinessView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MapBussinessView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

+ (CGSize)defaultSize
{
    return CGSizeMake(274, 214);
}

- (void)updateViewWithBusinesss:(Business *)business
{
    self.business = business;
    
    self.businessNameLabel.text = business.name;
    self.addressLabel.text = business.address;
    
    if (business.promotePrice > 0) {
        self.oldPriceLabel.hidden = NO;
        self.lineView.hidden = NO;
        self.latestPriceLabel.text = [NSString stringWithFormat:@"￥%d", (int)business.promotePrice];
        self.oldPriceLabel.text = [NSString stringWithFormat:@"￥%d", (int)business.price];
    } else {
        self.oldPriceLabel.hidden = YES;
        self.lineView.hidden = YES;
        self.latestPriceLabel.text = [NSString stringWithFormat:@"￥%d", (int)business.price];
    }
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMapBussinessView:)]) {
        [_delegate didClickMapBussinessView:_business];
    }
}

@end
