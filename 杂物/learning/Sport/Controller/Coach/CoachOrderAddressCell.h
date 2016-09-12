//
//  CoachOrderAddressCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
@class CoachOftenArea;
@protocol CoachOrderAddressCellDelegate <NSObject>
-(void)didClickCellWithIndex:(NSIndexPath *)indexPath
                     address:(NSString *)address
                       isPop:(BOOL)isPop;
-(void)popBackButton;
-(void)refreshSelectionWithAddress;
@end

@interface CoachOrderAddressCell : DDTableViewCell<UITextViewDelegate>

- (void)updateCellWithTitle:(CoachOftenArea *)area
                 isSelected:(BOOL)isSelected
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast;

@property (assign,nonatomic) id<CoachOrderAddressCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) NSArray *serviceAreaList;
@end
