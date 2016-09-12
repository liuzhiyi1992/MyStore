//
//  BusinessMapController.h
//  Sport
//
//  Created by haodong  on 13-8-25.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import <MapKit/MapKit.h>
#import "BussinessNavigationView.h"

@interface BusinessMapController : SportController <MKMapViewDelegate, UIActionSheetDelegate,BussinessNavigationViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *myMapView;

- (id)initWithLatitude:(double)latitude
             longitude:(double)longitude
          businessName:(NSString *)businessName
       businessAddress:(NSString *)businessAddress
        parkingLotList:(NSArray *)parkingLotList
            businessId:(NSString *)businessId
            categoryId:(NSString *)categoryId
                  type:(NSInteger)type;
- (id)initWithLatitude:(double)latitude
             longitude:(double)longitude
          businessName:(NSString *)businessName
       businessAddress:(NSString *)businessAddress
            categoryId:(NSString *)categoryId;

-(void)startNavigation;

@end
