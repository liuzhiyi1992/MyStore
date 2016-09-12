//
//  BussinessNavigationView.m
//  Sport
//
//  Created by xiaoyang on 15/12/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "BussinessNavigationView.h"
#import "Business.h"
#import "BusinessMapController.h"

@interface BussinessNavigationView()<UIActionSheetDelegate>
@property (strong, nonatomic) Business *business;
@property (weak, nonatomic) IBOutlet UIButton *navigationButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@end

@implementation BussinessNavigationView


+ (BussinessNavigationView *)createBussinessNavigationView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BussinessNavigationView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

+ (CGSize)defaultSize
{
    return CGSizeMake(274,150);
}

- (void)updateViewWithBusinesss:(Business *)business
{
    self.business = business;
    self.businessNameLabel.text = business.name;
    self.addressLabel.text = business.address;
    [self addSubview:self.backgroundView];
}

//- (IBAction)clickButton:(id)sender {
//    HDLog(@"clickButton");
//    
//    if ([_delegate respondsToSelector:@selector(didClickBussinessNavigationView:)]) {
//        [_delegate didClickBussinessNavigationView:_business];
//    }
//}

- (IBAction)didClickButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(startNavigation)]) {
        [_delegate  startNavigation];
    }else if([_delegate respondsToSelector:@selector(parkingLotNavigation)]){
        [_delegate parkingLotNavigation];
    }

}

@end
