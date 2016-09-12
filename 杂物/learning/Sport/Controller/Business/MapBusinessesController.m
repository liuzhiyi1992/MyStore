//
//  MapBusinessesController.m
//  Sport
//
//  Created by haodong  on 14-7-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "MapBusinessesController.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "Business.h"
#import "BusinessDetailController.h"

#import "BusinessCategoryManager.h"
#import "BusinessCategory.h"

#import "BusinessAnnotation.h"
#import "BusinessAnnotationView.h"

#import "BusinessCalloutAnnotation.h"

#import "UIView+Utils.h"

#import "CityManager.h"
#import "City.h"

@interface MapBusinessesController ()

@property (copy, nonatomic) NSString *categoryId;

@property (assign, nonatomic) BOOL hasShowUserLocation;

@property (assign, nonatomic) CLLocationCoordinate2D lastTimeLoadCenterCoordinate;
@property (assign, nonatomic) CLLocationCoordinate2D currentCenterCoordinate;
@property (assign, nonatomic) BOOL isLoading;

@property (assign, nonatomic) double minLatitude;
@property (assign, nonatomic) double maxLatitude;
@property (assign, nonatomic) double minLongitude;
@property (assign, nonatomic) double maxLongitude;

@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) NSArray *businessAnnotationList;

@property (strong, nonatomic) BusinessCalloutAnnotation *currentShowBusinessCalloutAnnotation;
@property (assign, nonatomic) BOOL isOpen;

@end

@implementation MapBusinessesController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (instancetype)initWithCategoryId:(NSString *)categoryId
{
    self = [super init];
    if (self) {
        self.categoryId = categoryId;
    }
    return self;
}

#define MAX_LATITUDE_DELTA          2.00000
#define MAX_LONGITUDE_DELTA         2.00000
#define DEFAULT_LATITUDE_DELTA      0.10000
#define DEFAULT_LONGITUDE_DELTA     0.10000
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        [self.myMapView updateHeight:[UIScreen mainScreen].bounds.size.height];
//    } else {
//        [self.myMapView updateHeight:[UIScreen mainScreen].bounds.size.height - 20];
//        [self.backButton updateOriginY:16];
////        [self.categoryButton updateOriginY:16];
//    }
//    
//    [self.showMyLocationButton updateOriginY:self.myMapView.frame.size.height - 24 - _showMyLocationButton.frame.size.height];
//    [self.refreshButton updateOriginY:_showMyLocationButton.frame.origin.y];
    
//    self.myMapView.showsScale = YES;    
//     self.myMapView.scaleOrigin = CGPointMake(12, 12);
    
    self.myMapView.showsUserLocation = YES;
    
//    [self updateCategoryButton];
}

//- (void)updateCategoryButton
//{
//    NSString *name = [[BusinessCategoryManager defaultManager] categoryNameById:_categoryId];
//    [self.categoryButton setTitle:name forState:UIControlStateNormal];
//}

- (void)queryData
{
    if (_isLoading == NO) {
        self.isLoading = YES;
        
        if (_myMapView.region.span.latitudeDelta < 0.1) { //纬度范围小于0.1度 ,纬度相差1度相当于相差111km
            _minLatitude = _myMapView.region.center.latitude - 0.1 / 2;
            _maxLatitude = _myMapView.region.center.latitude + 0.1 / 2;
            _minLongitude = _myMapView.region.center.longitude - 0.1 / 2;  //经度先大约用0.1
            _maxLongitude = _myMapView.region.center.longitude + 0.1 / 2;
        } else {
            _minLatitude = _myMapView.region.center.latitude - _myMapView.region.span.latitudeDelta / 2;
            _maxLatitude = _myMapView.region.center.latitude + _myMapView.region.span.latitudeDelta / 2;
            _minLongitude = _myMapView.region.center.longitude - _myMapView.region.span.longitudeDelta / 2;
            _maxLongitude = _myMapView.region.center.longitude + _myMapView.region.span.longitudeDelta / 2;
        }
        
        //[SportProgressView showWithStatus:@"正在加载"];
        HDLog(@"queryMapBusinessList");
        [BusinessService queryMapBusinessList:self
                                       cityId:[CityManager readCurrentCityId]
                                   categoryId:_categoryId
                               centerLatitude:_currentCenterCoordinate.latitude
                              centerLongitude:_currentCenterCoordinate.longitude
                                  minLatitude:_minLatitude
                                  maxLatitude:_maxLatitude
                                 minLongitude:_minLongitude
                                 maxLongitude:_maxLongitude];
    }
}

- (void)didQueryMapBusinessList:(NSArray *)businessList
                         status:(NSString *)status
                            msg:(NSString *)msg
                 centerLatitude:(double)centerLatitude
                centerLongitude:(double)centerLongitude
{
    //[SportProgressView dismiss];
    self.isLoading = NO;
    self.lastTimeLoadCenterCoordinate = CLLocationCoordinate2DMake(centerLatitude, centerLongitude);
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.dataList = businessList;
        [self removeBusinessView];
        [self addBusinsessView];
        
    } else {
        if (msg) {
            [SportPopupView popupWithMessage:msg];
        } else {
            [SportPopupView popupWithMessage:@"网络错误"];
        }
    }
}

- (void)removeBusinessView
{
    if ([_businessAnnotationList count] > 0) {
        [self.myMapView removeAnnotations:_businessAnnotationList];
    }
}

- (void)addBusinsessView
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (Business *business in _dataList) {
        if (CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(business.latitude, business.longitude))) {
            BusinessAnnotation *annotation = [[BusinessAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(business.latitude, business.longitude) title:nil subtitle:nil] ;
            annotation.business = business;
            [self.myMapView addAnnotation:annotation];
            [mutableArray addObject:annotation];
        }
    }
    
    self.businessAnnotationList = mutableArray;
}

- (void)showLocation:(CLLocation *)location
{
    HDLog(@"showLocation 1");
    if (_hasShowUserLocation == NO) {
        _hasShowUserLocation = YES;
        HDLog(@"showLocation 2");
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            MKCoordinateRegion newRegion;
            newRegion.center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            newRegion.span.latitudeDelta = DEFAULT_LATITUDE_DELTA;
            newRegion.span.longitudeDelta = DEFAULT_LONGITUDE_DELTA;
            [self.myMapView setRegion:newRegion animated:NO];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self queryData];
                });
            });
        }
    }
}

- (void)didClickBusinessCalloutAnnotationView:(Business *)business
{
    BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusiness:business categoryId:business.defaultCategoryId];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    HDLog(@"mapView:viewForAnnotation:");
    
    if ([annotation isKindOfClass:[BusinessAnnotation class]]) {
        static NSString *identifier = @"BusinessAnnotationView";
        BusinessAnnotationView *customView = (BusinessAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (customView == nil) {
            customView = [[BusinessAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] ;
        }
        customView.annotation = annotation;
        
        BusinessAnnotation *an = (BusinessAnnotation *)annotation;
        
        NSString *categoryName = [[BusinessCategoryManager defaultManager] categoryNameById:_categoryId];
        BOOL canOrder = [an.business canOrder];
        
        customView.image = [SportImage mapCategoryImage:categoryName canOrder:canOrder];
        
        return customView;
    }
    
     else if ([annotation isKindOfClass:[BusinessCalloutAnnotation class]]) {
         static NSString *identifier = @"BusinessCalloutAnnotationView";
         BusinessCalloutAnnotationView *customView = (BusinessCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
         if (customView == nil) {
             customView = [[BusinessCalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] ;
             customView.delegate = self;
         }
         customView.annotation = annotation;
         BusinessCalloutAnnotation *an = (BusinessCalloutAnnotation *)annotation;
         [customView updateViewWithBusiness:an.business];
         return customView;
    }

    else {
//        static NSString *identifier = @"customAnnotationView";
//        MKPinAnnotationView *customView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//        if (customView == nil) {
//            customView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
//            customView.pinColor = MKPinAnnotationColorPurple;
//        }
//        
//        return customView;
        
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    HDLog(@"mapView:didSelectAnnotationView:");
    if ([view.annotation isKindOfClass:[BusinessAnnotation class]]) {
        if ( _isOpen && _currentShowBusinessCalloutAnnotation
            && _currentShowBusinessCalloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude
            && _currentShowBusinessCalloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
            return;
        }
        if (_isOpen && _currentShowBusinessCalloutAnnotation) {
            [mapView removeAnnotation:_currentShowBusinessCalloutAnnotation];
            //self.currentShowBusinessCalloutAnnotation = nil;
        }
        self.currentShowBusinessCalloutAnnotation = [[BusinessCalloutAnnotation alloc] initWithCoordinate:view.annotation.coordinate] ;
        self.currentShowBusinessCalloutAnnotation.business = ((BusinessAnnotation *)view.annotation).business;
        [mapView addAnnotation:_currentShowBusinessCalloutAnnotation];
        self.isOpen = YES;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
            [mapView setCenterCoordinate:CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude + 0.00000001, mapView.centerCoordinate.longitude + 0.0000001) animated:YES];
            //[mapView setCenterCoordinate:_currentShowBusinessCalloutAnnotation.coordinate animated:YES];
        }
	}
    else{
        //[self clickBusiness];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    HDLog(@"mapView:didDeselectAnnotationView:");
    
    if (_currentShowBusinessCalloutAnnotation && [view isKindOfClass:[BusinessCalloutAnnotationView class]] == NO) {
        if (_currentShowBusinessCalloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&&
            _currentShowBusinessCalloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
            
            [mapView removeAnnotation:_currentShowBusinessCalloutAnnotation];
            self.isOpen = NO;
            
            //self.currentShowBusinessCalloutAnnotation = nil;
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    HDLog(@"mapView:regionDidChangeAnimated:");
    
    BOOL isFirstOpen = NO;
    if (_currentCenterCoordinate.latitude == 0) {
        isFirstOpen = YES;
    }
    self.currentCenterCoordinate = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    
    if (isFirstOpen) {//第一次获取到地图中心位置
        //[self queryData];
    } else {
        if (_lastTimeLoadCenterCoordinate.latitude == 0) {
            //[self queryData];
        } else {
            CLLocation *currenLocation = [[CLLocation alloc] initWithLatitude:_currentCenterCoordinate.latitude
                                                                     longitude:_currentCenterCoordinate.longitude] ;
            CLLocation *lastTimeLocation = [[CLLocation alloc] initWithLatitude:_lastTimeLoadCenterCoordinate.latitude
                                                                       longitude:_lastTimeLoadCenterCoordinate.longitude];
            CLLocationDistance distance = [currenLocation distanceFromLocation:lastTimeLocation];
    
            if (distance > 5000) {
                [self queryData];
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    HDLog(@"didUpdateUserLocation");
    [[UserManager defaultManager] saveUserLocation:userLocation.location];
    [self showLocation:userLocation.location];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    CLLocation *location = [[UserManager defaultManager] readUserLocation];
    if (location && CLLocationCoordinate2DIsValid(location.coordinate)) {
        [self showLocation:location];
    } else {
        City *city = [CityManager readCurrentCity];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:city.latitude longitude:city.longitude] ;
        [self showLocation:location];
    }
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickShowMyLocationButton:(id)sender {
    CLLocation *location = [[UserManager defaultManager] readUserLocation];
    if (location) {
        [self.myMapView setCenterCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)  animated:YES];
    }
}

- (IBAction)clickRefreshButton:(id)sender {
    [self queryData];
}

//#define TAG_CATEGORY_FILTER_LIST_VIEW 2014072301
//- (IBAction)clickCategoryButton:(id)sender {
//    SportFilterListView *view = (SportFilterListView *)[self.view viewWithTag:TAG_CATEGORY_FILTER_LIST_VIEW];
//    if (view) {
//        [view hide];
//        return;
//    }
//    
//    NSMutableArray *nameList = [NSMutableArray array];
//    int selectedRow = 0;
//    int index = 0;
//    for (BusinessCategory *category in [[BusinessCategoryManager defaultManager] currentAllCategories]) {
//        if ([_categoryId isEqualToString:category.businessCategoryId]) {
//            selectedRow = index;
//            
//        } else if (_categoryId == nil && [category.name isEqualToString:@"羽毛球"]) {
//            selectedRow = index;
//        }
//        [nameList addObject:category.name];
//        index ++;
//    }
//    
//    SportFilterListView *filterListView = [SportFilterListView createSportFilterListViewWithDataList:nameList selectedRow:selectedRow];
//    filterListView.delegate = self;
//    filterListView.tableHeight = 200;
//    filterListView.holderButton = _categoryButton;
//    filterListView.tag = TAG_CATEGORY_FILTER_LIST_VIEW;
//    [filterListView showInView:self.view  y:57];
//    
//    self.topBackgroundControl.hidden = NO;
//}

//- (void)didSelectSportFilterListView:(SportFilterListView *)sportFilterListView indexPath:(NSIndexPath *)indexPath
//{
//    BusinessCategory *category = [[[BusinessCategoryManager defaultManager] currentAllCategories] objectAtIndex:indexPath.row];
//    self.categoryId = category.businessCategoryId;
////    [self updateCategoryButton];
//    [self queryData];
//}

//- (void)didHideSportFilterListView
//{
//    self.topBackgroundControl.hidden = YES;
//}

- (IBAction)touchDownTopBackgroundControl:(id)sender {
//    SportFilterListView *view = (SportFilterListView *)[self.view viewWithTag:TAG_CATEGORY_FILTER_LIST_VIEW];
//    if (view) {
//        [view hide];
//        return;
//    }
}

@end
