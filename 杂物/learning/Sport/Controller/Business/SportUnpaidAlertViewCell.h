//
//  SportUnpaidAlertViewCell.h
//  Sport
//
//  Created by 江彦聪 on 8/18/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

@interface SportUnpaidAlertViewCell : DDTableViewCell
-(void) updateViewWithTitle:(NSString *)title
                     detail:(NSString *)detail;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end
