//
//  MonthCardAssistentController.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "MonthCardAssistentUnfoldCell.h"
#import "MonthCardAssistentFoldCell.h"
#import "MonthCardService.h"

@interface MonthCardAssistentController : SportController<UITableViewDataSource,UITableViewDelegate,MonthCardServiceDelegate,MonthCardAssistentFoldCellDelegate,MonthCardAssistentUnfoldCellDelegate>

-(id)initWithIsShowExpire:(BOOL)isShow;

@end
