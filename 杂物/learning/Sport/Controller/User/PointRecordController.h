//
//  PointRecordController.h
//  Sport
//
//  Created by haodong  on 14/11/17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PointService.h"

@interface PointRecordController : SportController<PointServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

@end
