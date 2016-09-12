//
//  ParkingLotAnnotationView.m
//  Sport
//
//  Created by xiaoyang on 15/12/11.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "ParkingLotAnnotationView.h"
#import "UIView+Utils.h"
@implementation ParkingLotAnnotationView

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
