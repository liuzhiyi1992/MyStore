//
//  MapBussinessView.h
//  Sport
//
//  Created by haodong  on 14-7-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Business;

@protocol MapBussinessViewDelegate <NSObject>
@optional
- (void)didClickMapBussinessView:(Business *)business;
@end

@interface MapBussinessView : UIView

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;

@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (assign, nonatomic) id<MapBussinessViewDelegate> delegate;

+ (MapBussinessView *)createMapBussinessView;

+ (CGSize)defaultSize;

- (void)updateViewWithBusinesss:(Business *)business;

@end
