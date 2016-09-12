//
//  LocateInMapController.h
//  Sport
//
//  Created by haodong  on 14-2-28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import <MapKit/MapKit.h>

@protocol LocateInMapControllerDelegate <NSObject>
@optional
- (void)didLocateInMap:(NSString *)address
              latitude:(double)latitude
             longitude:(double)longitude
isShowSelectedLocation:(BOOL)isShowSelectedLocation;

- (void)didClickCancelButton;
@end

@interface LocateInMapController : SportController<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (assign, nonatomic) id<LocateInMapControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *addressHolderView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

- (id)initWithDelegate:(id<LocateInMapControllerDelegate>)delegate
      SelectedLatitude:(double)selectedLatitude
    selectedLongtitude:(double)selectedLongitude
isShowSelectedLocation:(BOOL)isShowSelectedLocation;

@end
