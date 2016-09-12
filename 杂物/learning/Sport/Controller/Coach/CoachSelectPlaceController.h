//
//  CoachSelectPlaceController.h
//  Sport
//
//  Created by 江彦聪 on 15/7/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "CoachOrderAddressCell.h"

@protocol CoachSelectPlaceControllerDelegate <NSObject>

@optional
- (void)didFinishAddressSelection:(int)index;

- (void)popBackButton;

@end

@interface CoachSelectPlaceController : SportController<UITableViewDataSource,UITableViewDelegate,CoachOrderAddressCellDelegate,UITextFieldDelegate>
@property (assign, nonatomic) id<CoachSelectPlaceControllerDelegate>delegate;

-(id)initWithSelectedAddressIndex:(int)index
                 serviceArea:(NSArray *)serviceAreaList
                         dataList:(NSMutableArray *)dataList
                         delegate:(id)delegate;
@end
