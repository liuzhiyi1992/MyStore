//
//  MyVouchersController.h
//  Sport
//
//  Created by haodong  on 14-5-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "VoucherCell.h"
#import "UserService.h"
#import "MoneyCell.h"
#import "PointCell.h"
#import "actClubCell.h"
#import "InputPasswordView.h"
#import "Order.h"

#define  FROMNOORDER         @"0"

#define   FROMORDER         @"1"
@protocol MyVouchersControllerDelegate <NSObject>
@optional
- (void)didSelectedVoucher:(Voucher *)voucher;
@end

@interface MyVouchersController : SportController <UITableViewDataSource, UITableViewDelegate, UserServiceDelegate, VoucherCellDelegate, UIAlertViewDelegate, MoneyCellDelegate, PointCellDelegate, UIActionSheetDelegate,InputPasswordViewDelegate,actClubCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *noDataTipsImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *voucherDescButton;
@property (weak, nonatomic) IBOutlet UIButton *addVoucherButton;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

// 从确定订单选代金券时进入
@property (assign, nonatomic) BOOL canSelect;
@property (assign, nonatomic) double orderAmount;
@property (copy, nonatomic) NSString *orderId; //弃用
@property (copy, nonatomic) NSString *goodsIds;
@property (copy, nonatomic) NSString *orderType;
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *cityId;

@property (copy, nonatomic) NSString * entry;
@property (assign, nonatomic) id<MyVouchersControllerDelegate> delegate;

@end
