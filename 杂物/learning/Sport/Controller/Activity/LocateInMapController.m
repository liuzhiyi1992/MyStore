//
//  LocateInMapController.m
//  Sport
//
//  Created by haodong  on 14-2-28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "LocateInMapController.h"
#import "UserManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UIView+Utils.h"
#import "BusinessAnnotation.h"

@interface LocateInMapController ()
@property (copy, nonatomic) NSString *address;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (strong, nonatomic) CLLocation *submitLocation;
@property (assign, nonatomic) BOOL hasShowUserLocation;
@property (assign, nonatomic) BOOL isShowSelectedLocation;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation LocateInMapController
- (id)initWithDelegate:(id<LocateInMapControllerDelegate>)delegate
      SelectedLatitude:(double)selectedLatitude
            selectedLongtitude:(double)selectedLongitude
        isShowSelectedLocation:(BOOL)isShowSelectedLocation {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.latitude = selectedLatitude;
        self.longitude = selectedLongitude;
        self.isShowSelectedLocation = isShowSelectedLocation;
    }
    return self;
}

- (void)viewDidUnload {
//    [self setMyMapView:nil];
//    [self setAddressLabel:nil];
//    [self setAddressHolderView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"定位";
    self.myMapView.delegate = self;
    self.myMapView.showsUserLocation = YES;
    [self createRightTopButton:@"提交"];
    if (self.isShowSelectedLocation) {
        
        [self showLocationWithLatitude:_latitude longitude:_longitude];
    }
    
    self.submitButton.layer.cornerRadius = 20;
    self.submitButton.layer.masksToBounds = YES;
    
    self.cancelButton.layer.cornerRadius = 20;
    self.cancelButton.layer.masksToBounds = YES;
    [self.cancelButton.layer setBorderWidth:0.5];
    self.cancelButton.layer.borderColor=[UIColor hexColor:@"5b73f2"].CGColor;
    
}

- (void)clickRightTopButton:(id)sender
{
    [self submit];
}

- (IBAction)clickAddressLabelButton:(id)sender {
    if ([_addressLabel.text length] > 0) {
            [self submit];
    }
}

- (IBAction)clickCancelButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    if ([_delegate respondsToSelector:@selector(didClickCancelButton)]) {
        [_delegate didClickCancelButton];
    }
}

- (void)submit
{
    if ([_delegate respondsToSelector:@selector(didLocateInMap:latitude:longitude:isShowSelectedLocation:)]) {
        [_delegate didLocateInMap:_address latitude:_latitude longitude:_longitude isShowSelectedLocation:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// 以下是生成大头针的方法
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
//{
//    NSString *AnnotationViewID = @"renameMark";
//    MKAnnotationView *customView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
//    if (customView == nil) {
//        customView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//        
//        // 设置颜色
//        ((MKPinAnnotationView*)customView).pinColor = MKPinAnnotationColorPurple;
//        // 从天上掉下效果
//        ((MKPinAnnotationView*)customView).animatesDrop = YES;
//        // 设置可拖拽
//        ((MKPinAnnotationView*)customView).draggable = YES;
//        
//        // newAnnotation.frame=CGRectMake(180, 200, 50, 50);
//    }
//    
//    customView.centerOffset = CGPointMake(0, -(customView.frame.size.height * 0.5));
//    customView.annotation = annotation;
//    [customView setSelected:YES animated:YES];
//    return customView;
//}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    MKCoordinateRegion region;
//    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
//    region.center= centerCoordinate;
//    
//    BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithCoordinate:region.center title:nil subtitle:nil];
//    [self.myMapView addAnnotation:annotation];
    
//    self.latitude = mapView.centerCoordinate.latitude;
//    self.longitude = mapView.centerCoordinate.longitude;
    CLLocationCoordinate2D getIconLocation = [self.myMapView convertPoint:CGPointMake(_locationIcon.frame.origin.x, _locationIcon.frame.origin.y) toCoordinateFromView:self.myMapView];

    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:getIconLocation.latitude longitude:getIconLocation.longitude];
    
    self.latitude = getIconLocation.latitude;
    self.longitude = getIconLocation.longitude;
    self.submitLocation = location;
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSMutableString *address = [NSMutableString stringWithString:@""];
        if (placemark.locality) {
            [address appendString:placemark.locality];
        }
        if (placemark.subLocality) {
            [address appendString:placemark.subLocality];
        }
        if (placemark.thoroughfare) {
            [address appendString:placemark.thoroughfare];
        }
        if (placemark.subThoroughfare) {
            [address appendString:placemark.subThoroughfare];
        }
        self.address = address;
        self.addressLabel.text = address;
        
        HDLog(@"您当前所在位置:%@",address);
        /*
        HDLog(@"name:%@", placemark.name);
        HDLog(@"thoroughfare:%@", placemark.thoroughfare);
        HDLog(@"subThoroughfare:%@", placemark.subThoroughfare);
        HDLog(@"locality:%@", placemark.locality);
        HDLog(@"subLocality:%@", placemark.subLocality);
        HDLog(@"administrativeArea:%@", placemark.administrativeArea);
        HDLog(@"subAdministrativeArea:%@", placemark.subAdministrativeArea);
        HDLog(@"postalCode:%@", placemark.postalCode);
        HDLog(@"ISOcountryCode:%@", placemark.ISOcountryCode);
        HDLog(@"country:%@", placemark.country);
        HDLog(@"inlandWater:%@", placemark.inlandWater);
        HDLog(@"ocean:%@", placemark.ocean);
        HDLog(@"areasOfInterest:%@", placemark.areasOfInterest);
         */
    }];
    
}

- (void)showLocationWithLatitude:(double)latitude longitude:(double)longitude
{
    MKCoordinateRegion newRegion;
    newRegion.center = CLLocationCoordinate2DMake(latitude,longitude);
    newRegion.span.latitudeDelta = 0.01000;
    newRegion.span.longitudeDelta = 0.01000;
    [self.myMapView setRegion:newRegion animated:NO];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.isShowSelectedLocation) {
        
        [self showLocationWithLatitude:_latitude longitude:_longitude];
        
    }else {
        if (self.hasShowUserLocation == NO) {
            self.hasShowUserLocation = YES;
            
            [self showLocationWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
        }
        
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if (self.isShowSelectedLocation == NO) {
        
        CLLocation *location = [[UserManager defaultManager] readUserLocation];
//        [self showLocation:location];
        [self showLocationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    }
}

@end
