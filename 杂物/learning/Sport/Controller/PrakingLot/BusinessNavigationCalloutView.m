//
//  BusinessNavigationCalloutView.m
//  Sport
//
//  Created by xiaoyang on 15/12/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "BusinessNavigationCalloutView.h"

#import "UIView+Utils.h"


@interface BusinessNavigationCalloutView()
@property (strong, nonatomic) BussinessNavigationView *bussinessNavigationView;
@end

@implementation BusinessNavigationCalloutView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
                delegate:(id<BussinessNavigationViewDelegate>)delegate
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = [BussinessNavigationView defaultSize];
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        
        
        self.bussinessNavigationView = [BussinessNavigationView createBussinessNavigationView];
        
        self.bussinessNavigationView.delegate = delegate;
               
        [self addSubview:self.bussinessNavigationView];
    }
    return self;
}

- (void)updateViewWithTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    self.bussinessNavigationView.businessNameLabel.text = title;
    self.bussinessNavigationView.addressLabel.text = subtitle;
}


@end
