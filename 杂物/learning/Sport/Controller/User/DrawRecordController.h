//
//  DrawRecordController.h
//  Sport
//
//  Created by haodong  on 14/11/21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "DrawRecordCell.h"
#import "PointService.h"

@interface DrawRecordController : SportController <DrawRecordCellDelegate, PointServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *myPointLabel;


@end
