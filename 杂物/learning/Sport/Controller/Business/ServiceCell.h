//
//  ServiceCell.h
//  Sport
//
//  Created by haodong  on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "ServiceGroup.h"
#import "Service.h"

@protocol ServiceCellDelegate <NSObject>
@optional
- (void)didClickServiceCellDetailButton:(NSIndexPath *)indexPath;
@end


@class Facility;

@interface ServiceCell : DDTableViewCell

@property (strong, nonatomic) id<ServiceCellDelegate> delegate;

+ (CGFloat)getCellHeightWithService:(Service *)service;

- (void)updateCellWithService:(Service *)service
                    indexPath:(NSIndexPath *)indexPath
                       isLast:(BOOL)isLast
                     canClick:(BOOL)canClick;


@end
