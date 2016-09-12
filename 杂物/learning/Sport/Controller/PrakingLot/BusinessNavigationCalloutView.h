//
//  BusinessNavigationCalloutView.h
//  Sport
//
//  Created by xiaoyang on 15/12/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BussinessNavigationView.h"

@class Business;

@protocol BusinessNavigationCalloutViewDelegate <NSObject>
- (void)didClickBusinessNavigationCalloutView:(Business *)business;

@end

@interface BusinessNavigationCalloutView : MKAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
                delegate:(id<BussinessNavigationViewDelegate>)delegate;
- (void)updateViewWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
