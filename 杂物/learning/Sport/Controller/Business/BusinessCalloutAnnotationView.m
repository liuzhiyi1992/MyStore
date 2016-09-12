//
//  BusinessCalloutAnnotationView.m
//  Sport
//
//  Created by haodong  on 14-7-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BusinessCalloutAnnotationView.h"
#import "UIView+Utils.h"


@interface BusinessCalloutAnnotationView()
@property (strong, nonatomic) MapBussinessView *mapBussinessView;
@end

@implementation BusinessCalloutAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = [MapBussinessView defaultSize];
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        
        MapBussinessView *view = [MapBussinessView createMapBussinessView];
        view.delegate = self;
        self.mapBussinessView = view;
        
        [self addSubview:view];
    }
    return self;
}

- (void)updateViewWithBusiness:(Business *)business
{
    [_mapBussinessView updateViewWithBusinesss:business];
}

- (void)didClickMapBussinessView:(Business *)business
{
    if ([_delegate respondsToSelector:@selector(didClickBusinessCalloutAnnotationView:)]) {
        [_delegate didClickBusinessCalloutAnnotationView:business];
    }
}

@end
