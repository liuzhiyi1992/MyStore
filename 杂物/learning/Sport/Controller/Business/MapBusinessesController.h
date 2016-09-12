//
//  MapBusinessesController.h
//  Sport
//
//  Created by haodong  on 14-7-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import <MapKit/MapKit.h>
#import "BusinessService.h"
#import "BusinessCalloutAnnotationView.h"
#import "SportFilterListView.h"

@interface MapBusinessesController : SportController<MKMapViewDelegate, BusinessServiceDelegate, BusinessCalloutAnnotationViewDelegate, SportFilterListViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (weak, nonatomic) IBOutlet UIButton *showMyLocationButton;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;

@property (weak, nonatomic) IBOutlet UIControl *topBackgroundControl;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

- (instancetype)initWithCategoryId:(NSString *)categoryId;

@end
