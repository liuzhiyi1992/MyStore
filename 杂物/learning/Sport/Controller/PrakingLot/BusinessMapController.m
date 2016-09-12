//
//  BusinessMapController.m
//  Sport
//
//  Created by haodong  on 13-8-25.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessMapController.h"
#import "BusinessAnnotation.h"
#import "ParkingLot.h"
#import "ParkingLotAnnotation.h"
#import "ParkingLotAnnotationView.h"
#import "BusinessNavigationCalloutView.h"
#import "BusinnessNavigationCalloutAnnotation.h"
#import "ParkingLotCalloutAnnotation.h"
#import "BusinessService.h"
#import "BusinessMapCell.h"
#import "UIView+Utils.h"
#import "TrafficInfo.h"

@interface BusinessMapController ()<BussinessNavigationViewDelegate,BusinessServiceDelegate,UITableViewDelegate,UITableViewDataSource>
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (copy, nonatomic) NSString *businessName;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *businessAddress;
@property (strong, nonatomic) NSArray *parkingLotList;
@property (strong, nonatomic) NSArray *trafficInfoList;
@property (assign,nonatomic) NSInteger type;
@property (strong, nonatomic) id<MKAnnotation> currentCallOutAnnotation;

@property (weak, nonatomic) IBOutlet UITextView *trafficDetailTextView;
@property (weak, nonatomic) IBOutlet UILabel *trafficInformationAlertLabel;
@property (weak, nonatomic) IBOutlet UIImageView *trafficInformationAlertIcon;
@property (weak, nonatomic) IBOutlet UIView *trafficAlertHolderView;
@property (strong, nonatomic) TrafficInfo *currentSeletedTrafficInfo;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIButton *backBusinessButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trafficAlertHeightConstraint;
@property (copy, nonatomic) NSString *categoryId;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIView *trafficAlertView;
@property (weak, nonatomic) IBOutlet UIView *queryFailAlertView;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;

@end

@implementation BusinessMapController

#define CELL_HEIGHT 45.0

- (void)viewDidUnload {
    [self setMyMapView:nil];

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

- (id)initWithLatitude:(double)latitude
             longitude:(double)longitude
          businessName:(NSString *)businessName
       businessAddress:(NSString *)businessAddress
            categoryId:(NSString *)categoryId{
    self = [super init];
    if (self) {
        self.type = 0;
        self.latitude = latitude;
        self.longitude = longitude;
        self.businessName = businessName;
        self.businessAddress = businessAddress;
        self.categoryId = categoryId;
    }
    
    return self;
}

- (id)initWithLatitude:(double)latitude
             longitude:(double)longitude
          businessName:(NSString *)businessName
       businessAddress:(NSString *)businessAddress
        parkingLotList:(NSArray *)parkingLotList
            businessId:(NSString *)businessId
            categoryId:(NSString *)categoryId
                  type:(NSInteger)type
{
    self = [self initWithLatitude:latitude longitude:longitude businessName:businessName businessAddress:businessAddress categoryId:categoryId];
    if (self) {
        self.businessId = businessId;
        self.parkingLotList = parkingLotList;
        self.type = type;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(_type ==0){
    self.title = DDTF(@"kBusinessLocation");
    }else if(_type ==1){
        self.title = @"停车场位置";
    }
    
    self.trafficAlertView.layer.cornerRadius = 5;
    self.trafficAlertView.layer.masksToBounds = YES;
    
    self.tryAgainButton.layer.cornerRadius = 14;
    self.tryAgainButton.layer.masksToBounds = YES;
    [self.tryAgainButton setBackgroundImage:[[UIImage imageNamed:@"GrayButtonBackground"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];    
    
    self.backBusinessButton.layer.cornerRadius = 3;
    self.backBusinessButton.layer.masksToBounds = YES;

    [self showBuinsess];
    
    [self showParkingLot];
    
    [self queryData];

    self.myMapView.showsUserLocation = YES;
    [self.view bringSubviewToFront:self.trafficAlertHolderView];
    self.trafficAlertHolderView.hidden = YES;
    
    self.trafficDetailTextView.editable = NO;
    self.dataTableView.scrollEnabled = NO;
    self.indicatorView.hidesWhenStopped = YES;
    [self.indicatorView startAnimating];

    
    [self updateAllSize:3];
    self.queryFailAlertView.hidden = YES;
    
    [self queryData];

}

- (void)queryData {
    
    [BusinessService getVenueParkList:self venuesId:_businessId categoryId:_categoryId];

}

- (void)updateAllSize:(NSInteger)trafficInfoListCount {
    
    self.trafficAlertHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - trafficInfoListCount * CELL_HEIGHT; 
}

-(void)didGetVenueParkList:(NSArray *)parkList trafficInfoList:(NSArray *)trafficInfoList status:(NSString *)status msg:(NSString *)msg{
    
    [self.indicatorView stopAnimating];
    
    self.queryFailAlertView.hidden = YES;
    
    if([status isEqualToString:STATUS_SUCCESS]){
        self.parkingLotList = parkList;
        self.trafficInfoList = trafficInfoList;
        [self updateAllSize:[trafficInfoList count]];
        [self.dataTableView reloadData];
        [self showParkingLot];
    } else {
        self.queryFailAlertView.hidden = NO;
    }
}

- (IBAction)clickTryAgainButton:(id)sender {
    
    [self queryData];
    self.queryFailAlertView.hidden = YES;
    [self.indicatorView startAnimating];
}

-(void)startNavigation{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"使用本机地图导航", nil];
    [actionSheet showInView:self.view];
}

- (ParkingLot *)findMinDistanceParkingLot
{
    int index = 0;
    ParkingLot *resultParkingLot = nil;
    for(ParkingLot *parkingLot in _parkingLotList) {
        
        if (index == 0) {
            resultParkingLot = parkingLot;
        } else {
            if (parkingLot.distance < resultParkingLot.distance) {
                resultParkingLot = parkingLot;
            }
        }
        index ++;
    }
    
    return resultParkingLot;
}

-(void)navigationLatitude:(double)latitude navigationLongitude:(double)longitude  navigationName:(NSString *)Name{
    
    CLLocationCoordinate2D to;
    to.latitude = latitude;
    to.longitude = longitude;
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil] ] ;
    
    toLocation.name = Name;
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        [self navigationLatitude:self.currentCallOutAnnotation.coordinate.latitude navigationLongitude:self.currentCallOutAnnotation.coordinate.longitude navigationName:self.currentCallOutAnnotation.title];
        
    }
}

- (BOOL)isValidLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude
{
    if (-90.0 <= latitude && latitude <= 90.0 &&  -180.0 <= longitude && longitude <= 180.0){
        return YES;
    }else {
        return NO;
    }
}

- (void)showBuinsess
{
    if ([self isValidLatitude:_latitude Longitude:_longitude]) {
        MKCoordinateRegion newRegion;
        newRegion.center = CLLocationCoordinate2DMake(_latitude, _longitude);
        newRegion.span.latitudeDelta = 0.01000;
        newRegion.span.longitudeDelta = 0.01000;
        [self.myMapView setRegion:newRegion animated:YES];
        
        BusinessAnnotation *annotation = [[BusinessAnnotation alloc] initWithCoordinate:newRegion.center title:_businessName subtitle:_businessAddress];
        [self.myMapView addAnnotation:annotation];
        
        if (self.type == 0) {
            [self selectAnnotation:annotation];
        }
    }
}

//原本需求是场馆不在屏幕内才显示返回按钮，现在是一直显示，原代码暂先保留
//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
////        MKCoordinateRegion region;
//        CLLocationCoordinate2D centerCoordinate = mapView.region.center;
////        region.center= centerCoordinate;
//    if ((centerCoordinate.latitude - self.latitude > mapView.region.span.latitudeDelta / 2)||(centerCoordinate.longitude - self.longitude > mapView.region.span.longitudeDelta / 2)){
//        self.backBusinessButton.hidden = NO;
//    }else {
//        self.backBusinessButton.hidden = YES;
//    }
//}

//计算距离
- (void)calculateAllParkingLotDistance
{
    CLLocation* businessLocation = [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
    for(ParkingLot *parkingLot  in _parkingLotList){
        if ([self isValidLatitude:parkingLot.lat Longitude:parkingLot.lon]) {
            CLLocation* parkingLotLocation = [[CLLocation alloc] initWithLatitude:parkingLot.lat longitude:parkingLot.lon];
            double distance  = [businessLocation distanceFromLocation:parkingLotLocation];
            parkingLot.distance = distance;
        }
    }
}

- (void)showParkingLot
{
    [self calculateAllParkingLotDistance];
    ParkingLot *minParkingLot = [self findMinDistanceParkingLot];
    
    ParkingLotAnnotation *willShowAnnotation  = nil;
    
    for(ParkingLot *parkingLot  in _parkingLotList){
        
        if ([self isValidLatitude:parkingLot.lat Longitude:parkingLot.lon]) {
            
            ParkingLotAnnotation *parkingLotAnnotation = [[ParkingLotAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(parkingLot.lat, parkingLot.lon) title:parkingLot.name subtitle:parkingLot.address];
            parkingLotAnnotation.distance = parkingLot.distance;
            
            [self.myMapView addAnnotation:parkingLotAnnotation];
            
            if (parkingLot == minParkingLot) {
                willShowAnnotation = parkingLotAnnotation;
            }
        }
    }
        
    if(self.type == 1) {
        [self selectAnnotation:willShowAnnotation];
    }
}

- (void)selectAnnotation:(id <MKAnnotation>)annotation
{
    [self.myMapView selectAnnotation:annotation animated:YES];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBackBusinessLocation:(id)sender {
    
    [self.myMapView setCenterCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) animated:YES];
}

- (IBAction)closeButton:(id)sender {
    self.trafficAlertHolderView.hidden = YES;
}

- (IBAction)clickBackgroundButton:(id)sender {
    self.trafficAlertHolderView.hidden = YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.trafficInfoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [BusinessMapCell getCellIdentifier];
    BusinessMapCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [BusinessMapCell createCell];
        
    }
    [cell updateCellWithTrafficInfo:[self.trafficInfoList objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentSeletedTrafficInfo = self.trafficInfoList[indexPath.row];
    self.trafficAlertHolderView.hidden = NO;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_currentSeletedTrafficInfo.name isEqualToString:@"停车"]) {
        [self.trafficInformationAlertIcon setImage:[UIImage imageNamed:@"ParkIcon"]];
    }else if([_currentSeletedTrafficInfo.name isEqualToString:@"公交"]) {
        [self.trafficInformationAlertIcon setImage:[UIImage imageNamed:@"BusIcon"]];
    }else if([_currentSeletedTrafficInfo.name isEqualToString:@"地铁"]) {
        [self.trafficInformationAlertIcon setImage:[UIImage imageNamed:@"SubwayIcon"]];
    }
    
    self.trafficInformationAlertLabel.text = _currentSeletedTrafficInfo.name;
    self.trafficDetailTextView.text = _currentSeletedTrafficInfo.content;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
        UIView *view=nil;
    if ([annotation isKindOfClass:[BusinessAnnotation class]]) {
        
        
        static NSString *identifier = @"customAnnotationView";
        MKAnnotationView *customView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (customView ==nil ) {
            customView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            //customView.pinColor = MKPinAnnotationColorPurple;
            customView.canShowCallout =NO;
            customView.image = [UIImage imageNamed:@"business"];
            
        }
        return customView;
        
    } else if([annotation isKindOfClass:[ParkingLotAnnotation class]]){
        
        static NSString *parkingLotIdentifier = @"parkingLotAnnotationView";
        MKAnnotationView *parkingLotView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:parkingLotIdentifier];
        if(parkingLotView== nil){
            parkingLotView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:parkingLotIdentifier];
            parkingLotView.canShowCallout = NO;
            parkingLotView.image =[UIImage imageNamed:@"parkingLot"];
        }
        return parkingLotView;
        
    } else if([annotation isKindOfClass:[BusinessNavigationCalloutAnnotation class]]
              || [annotation isKindOfClass:[ParkingLotCalloutAnnotation class]] ){
        
        static NSString *calloutKey=@"BusinessNavigationCalloutView";
        BusinessNavigationCalloutView *calloutView=(BusinessNavigationCalloutView *)[mapView dequeueReusableAnnotationViewWithIdentifier:calloutKey];
        if (!calloutView) {
            calloutView=[[BusinessNavigationCalloutView alloc]initWithAnnotation:annotation reuseIdentifier:calloutKey delegate:self];
        }
        
        NSString *title = nil;
        NSString *subtitle = nil;
        
        if ([annotation isKindOfClass:[BusinessNavigationCalloutAnnotation class]]) {
            BusinessNavigationCalloutAnnotation *bvca = (BusinessNavigationCalloutAnnotation *)annotation;
            title = bvca.title;
            subtitle = bvca.subtitle;
            
        } else if ([annotation isKindOfClass:[ParkingLotCalloutAnnotation class]]) {
            ParkingLotCalloutAnnotation *plca = (ParkingLotCalloutAnnotation *)annotation;
            title = plca.title;
            //subtitle = plca.subtitle;
            subtitle = [NSString stringWithFormat:@"距离场馆 %.0f m", plca.distance];
        }
        
        [calloutView updateViewWithTitle:title subtitle:subtitle];
        //calloutView.image =[UIImage imageNamed:@"backgroundMapImage"];
        view = calloutView;
        return calloutView;
        
    } else {
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
 
    if ([view.annotation isKindOfClass:[BusinessAnnotation class]]) {
        
        BusinessNavigationCalloutAnnotation *calloutAnnotation = [[BusinessNavigationCalloutAnnotation alloc] initWithCoordinate: CLLocationCoordinate2DMake(_latitude, _longitude) title:_businessName subtitle:_businessAddress];
        
        [self.myMapView addAnnotation:calloutAnnotation];
        
        self.currentCallOutAnnotation = calloutAnnotation;
        
    } else if([view.annotation isKindOfClass:[ParkingLotAnnotation class]]){
        
        
        ParkingLotCalloutAnnotation *pLCalloutAnnotation = [[ParkingLotCalloutAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(view.annotation.coordinate.latitude,view.annotation.coordinate.longitude) title:view.annotation.title subtitle:view.annotation.subtitle];
        ParkingLotAnnotation *pla =  (ParkingLotAnnotation *)view.annotation;
        pLCalloutAnnotation.distance = pla.distance;

        [self.myMapView addAnnotation:pLCalloutAnnotation];
        
        self.currentCallOutAnnotation = pLCalloutAnnotation;
    }
}

-(void)mapView:(MKMapView *)mapView showCallViewWhenComeIn:(MKAnnotationView *)view{
   
    if ([view.annotation isKindOfClass:[BusinessAnnotation class]]) {
        
        BusinessNavigationCalloutAnnotation *calloutAnnotation = [[BusinessNavigationCalloutAnnotation alloc] initWithCoordinate: CLLocationCoordinate2DMake(_latitude, _longitude) title:_businessName subtitle:_businessAddress];
        [self.myMapView addAnnotation:calloutAnnotation];
        
        self.currentCallOutAnnotation = calloutAnnotation;
        
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    
    [self.myMapView removeAnnotation:self.currentCallOutAnnotation];
    
}

@end
