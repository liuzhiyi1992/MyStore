//
//  BusinessAnnotationView.m
//  Sport
//
//  Created by haodong  on 14-7-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BusinessAnnotationView.h"
#import "UIView+Utils.h"

@implementation BusinessAnnotationView

//- (void)dealloc
//{
//    [super dealloc];
//}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.canShowCallout = NO;
    }
    return self;
}

@end
