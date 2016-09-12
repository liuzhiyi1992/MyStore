//
//  MembershipCardListController.h
//  Sport
//
//  Created by 江彦聪 on 15/4/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "MembershipCardCell.h"
#import "InputPasswordView.h"
#import "MembershipCardService.h"

@interface MembershipCardListController : SportController<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate,InputPasswordViewDelegate,MembershipCardServiceDelegate,MemberShipCardCellDelegate>

-(void)setBindOneCard:(MembershipCard *)card;
-(id)initWithBindOneCard:(MembershipCard *)card;
@end
