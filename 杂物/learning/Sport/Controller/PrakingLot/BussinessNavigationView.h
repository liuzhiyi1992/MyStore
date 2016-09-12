//
//  BussinessNavigationView.h
//  Sport
//
//  Created by xiaoyang on 15/12/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
@class Business;

@protocol BussinessNavigationViewDelegate <NSObject>
@optional
- (void)didClickBussinessNavigationView:(Business *)business;

-(void)startNavigation;

-(void)parkingLotNavigation;

@end

@interface BussinessNavigationView : UIView

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) id<BussinessNavigationViewDelegate> delegate;

+ (BussinessNavigationView *)createBussinessNavigationView;

+ (CGSize)defaultSize;

- (void)updateViewWithBusinesss:(Business *)business;

@end
