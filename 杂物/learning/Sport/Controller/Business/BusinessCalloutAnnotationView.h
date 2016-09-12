//
//  BusinessCalloutAnnotationView.h
//  Sport
//
//  Created by haodong  on 14-7-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapBussinessView.h"

@class Business;

@protocol BusinessCalloutAnnotationViewDelegate <NSObject>
- (void)didClickBusinessCalloutAnnotationView:(Business *)business;

@end

@interface BusinessCalloutAnnotationView : MKAnnotationView<MapBussinessViewDelegate>

@property (assign, nonatomic) id<BusinessCalloutAnnotationViewDelegate> delegate;

- (void)updateViewWithBusiness:(Business *)business;

@end
