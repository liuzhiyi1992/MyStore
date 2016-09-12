//
//  MyVouchersController.m
//  Sport
//
//  Created by haodong  on 14-5-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "MyVouchersController.h"
#import "Voucher.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "UIView+Utils.h"
#import "SportUUID.h"
#import "TipNumberManager.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"
#import "UnableVouchersController.h"
#import "MyMoneyController.h"
#import "MembershipCardVerifyPhoneController.h"
#import "RegisterController.h"
#import "TicketService.h"
#import "Voucher.h"
#import "SportVoucherCell.h"
#import "UIScrollView+SportRefresh.h"
#import "MonthCardRechargeController.h"
#import "ActClubIntroduceController.h"
#import "AddVoucherController.h"
#import "OtherController.h"
@interface MyVouchersController () <TicketServiceDelegate, SportVoucherCellDelegate,AddVoucherControllerDelegate>
@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) int page;
@property (assign, nonatomic) int point;
@property (assign, nonatomic) BOOL finishLoadData;
@property (assign, nonatomic) int userClubStatus;
@property (retain, nonatomic) NSString *usableDays;

@property (weak, nonatomic) IBOutlet UIButton *addNoneVoucherButton;

@end

#define COUNT_ONE_PAGE 5
#define PAGE_START     1

@implementation MyVouchersController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.title length] == 0) {
        self.title = @"我的钱包";
    }
    
    [self.dataTableView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - 44];
    
    [self.bottomHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _bottomHolderView.frame.size.height];
    [self.voucherDescButton setBackgroundImage:[SportImage topRightFrameGrayImage] forState:UIControlStateNormal];
    [self.addVoucherButton setBackgroundImage:[SportImage topRightFrameGrayImage] forState:UIControlStateNormal];
    
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    
    [self createRightTopButton:@"失效卡券"];
    self.noDataTipsImageView.hidden = NO;
    [self clearTipsCount];
    
    self.addNoneVoucherButton.layer.cornerRadius = 3;
    self.addNoneVoucherButton.layer.masksToBounds = YES;
    [self.addNoneVoucherButton setBackgroundColor:[SportColor defaultColor]];
}

- (void)loadNewData
{
    self.page = PAGE_START;
    [self queryData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.dataTableView reloadData];
    [self loadNewData];
    self.noDataTipsImageView.hidden = NO;
}

- (void)clearTipsCount
{
    if ([[TipNumberManager defaultManager] voucherCount] > 0) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        [UserService updateMessageCount:nil
                                 userId:user.userId
                               deviceId:[SportUUID uuid]
                                   type:[NSString stringWithFormat:@"%lu", (unsigned long)MessageCountTypeVoucher]
                                  count:[[TipNumberManager defaultManager] voucherCount]];
        
//        [[TipNumberManager defaultManager] setVoucherCount:0];
    }
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中..."];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
 
    [TicketService getNewTicketList:self userId:user.userId goodsIds:_goodsIds orderType:_orderType entry:self.entry categoryId:nil cityId:nil];
      
}

- (void)didGetTicketList:(NSArray *)list
                  status:(NSString *)status
                     msg:(NSString *)msg

             usableDays:(NSString *)usableDays
          userClubStatus:(int)userClubStatus
{
    [self.dataTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
    self.usableDays = usableDays;
    self.userClubStatus = userClubStatus;
    
    self.finishLoadData = YES;
    self.dataList = [NSMutableArray arrayWithArray:list];
    [self.dataTableView reloadData];
  
      //无数据时的提示&& _canSelect
    if ([_dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - self.bottomHolderView.frame.size.height);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有可用卡券"];
            
            self.noDataView.backgroundColor=[UIColor whiteColor];
            //隐藏添加卡券入口
            //[self.noDataView addSubview:self.addNoneVoucherButton];
            //self.addNoneVoucherButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height /2 + 10);
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

#define COUNT_HEAD  3
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_finishLoadData) {
        if (_canSelect) {
            return [_dataList count];
        } else {
            return [_dataList count] ;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
        Voucher *voucher  = _dataList[indexPath.row];
        
//        if (voucher.type == VoucherTypeSport) {
//            identifier = [SportVoucherCell getCellIdentifier];
//            SportVoucherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            if (cell == nil) {
//                cell = [SportVoucherCell createCell];
//                cell.delegate = self;
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            }
//            [cell updateCellWithVoucher:voucher isShowUseButton:YES];
//            return cell;
//        } else {
    
            identifier = [VoucherCell getCellIdentifier];
            VoucherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [VoucherCell createCell];
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //_canSelect
            [cell updateCellWithVoucher:voucher isShowUseButton:YES ];
            return cell;
        
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VoucherCell getCellHeight];
}

- (void)didClickVoucherCellVoucher:(Voucher *)voucher
{
    [self useVoucher:voucher];
}

- (void)didClickSportVoucherCellVoucher:(Voucher *)voucher
{
    [self useVoucher:voucher];
}

- (void)useVoucher:(Voucher *)voucher
{
  //如果是从我的卡券入口进来的不能点击
    
    if ([self.entry isEqualToString:FROMNOORDER]) {
        return;
    }
    //不可用
    if (! voucher.isEnable) {
        NSString *message = voucher.disableMessage;
        if ([message length] == 0) {
            message = @"不可使用此代金券";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil] ;
        [alertView show];
        return;
    }
    
    //订单金额至少要大于代金券金额或者大于代金券最小要求金额
    if (![voucher validToUse:_orderAmount]) {
        NSString *message = [NSString stringWithFormat:@"此代金劵只适用于支付金额大于%d元的订单", (int)([voucher minAmountToUse])];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (voucher.type == VoucherTypeDefault) {
        [MobClickUtils event:umeng_event_use_coupon label:@"可用"];
    } else if (voucher.type == VoucherTypeSport) {
        [MobClickUtils event:umeng_event_use_sport_stamps label:@"可用"];
    }
    
    if ([_delegate respondsToSelector:@selector(didSelectedVoucher:)]) {
        [_delegate didSelectedVoucher:voucher];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didAddVoucher:(NSString *)status msg:(NSString *)msg voucher:(Voucher *)voucher
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        if (voucher != nil) {
            BOOL isNew = YES;
            for (Voucher *existVoucher in self.dataList) {
                if ([existVoucher.voucherId isEqualToString:voucher.voucherId]) {
                    isNew = NO;
                    break;
                }
            }
            
            if (isNew) {
                [self.dataList insertObject:voucher atIndex:0];
                [SportProgressView dismissWithSuccess:@"添加成功"];
            } else {
                [SportProgressView dismissWithSuccess:@"已添加"];
            }
            
            [self.dataTableView reloadData];
            
            [self removeNoDataView];
            
            if (_canSelect) {
                [self useVoucher:voucher];
            }
        }
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (IBAction)clickVoucherDescButton:(id)sender {
    [MobClickUtils event:umeng_event_click_wallet_explanation];
    
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] couponRuleUrl] title:@"卡券使用说明"] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickAddVoucherButton:(id)sender {
    [MobClickUtils event:umeng_event_click_wallet_bind_ticket];
    
    AddVoucherController *controller=[[AddVoucherController alloc] init];
    controller.orderAmount = self.orderAmount;
    controller.goodsIds = self.goodsIds;
    controller.orderType = self.orderType;
    controller.entry=self.entry;

   [self.navigationController pushViewController:controller animated:YES];
    
}

#define TAG_SETTING_NO_PAYPASSWORD 0x001
#define TAG_SETTING_PAYPASSWORD 0x002

- (void)clickRightTopButton:(id)sender {
    
    [MobClickUtils event:umeng_event_click_wallet_failure_ticket];
    
    UnableVouchersController *controller = [[UnableVouchersController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];

}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (actionSheet.tag == TAG_SETTING_PAYPASSWORD) {
        if (buttonIndex == 0 || buttonIndex == 1) {
            if ([[[UserManager defaultManager] readCurrentUser].phoneNumber length] == 0) {
                
                // 没有绑定手机号码，需先绑定
                [self bindPhone];
                return;
            }
        }
        
        // 忘记支付密码
        if (buttonIndex == 0) {

            MembershipCardVerifyPhoneController *controller =[[MembershipCardVerifyPhoneController alloc]initWithType:VerifyPhoneTypeForgotPayPassword];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        // 修改支付密码
        else if(buttonIndex == 1) {
            [self performSelector:@selector(showInputPasswordView:) withObject:@(InputPasswordTypeModify) afterDelay:0.5];
        }
        else if (buttonIndex == 2) {
            UnableVouchersController *controller = [[UnableVouchersController alloc] init] ;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    }
    else if(actionSheet.tag == TAG_SETTING_NO_PAYPASSWORD) {
        if (buttonIndex == 0) {
            
            if ([[[UserManager defaultManager] readCurrentUser].phoneNumber length] == 0) {
                
                // 没有绑定手机号码，需先绑定
                [self bindPhone];
                return;
            }
            
            //设置支付密码
            [self performSelector:@selector(showInputPasswordView:) withObject:@(InputPasswordTypeSet) afterDelay:0.5];
            
        }
        else if (buttonIndex == 1) {
            UnableVouchersController *controller = [[UnableVouchersController alloc] init] ;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
}

- (void)bindPhone
{
    RegisterController *controller  = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBind] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];

        if ([textField.text length] == 0) {
            [SportPopupView popupWithMessage:@"请输入卡券密码"];
            return;
        }
        
        [SportProgressView showWithStatus:@"正在提交"];
        User *user = [[UserManager defaultManager] readCurrentUser];
        [TicketService addVoucher:self
                           userId:user.userId
                    voucherNumber:textField.text
                         goodsIds:_goodsIds
                        orderType:_orderType];
        
        
        
        
    }
}

//- (void)didClickMoneyCell
//{
//    [MobClickUtils event:umeng_event_click_wallet_balance];
//    MyMoneyController *controller = [[MyMoneyController alloc] initWithMoney:[[UserManager defaultManager] readCurrentUser].balance] ;
//    [self.navigationController pushViewController:controller animated:YES];
//}

//- (void)didClickPointCell
//{
//    [MobClickUtils event:umeng_event_click_wallet_integer];
//    MyMoneyController *controller = [[MyMoneyController alloc] initWithPoint:_point] ;
//    [self.navigationController pushViewController:controller animated:YES];
//}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (void)showInputPasswordView:(NSNumber *)typeValue
{
    InputPasswordType type = (InputPasswordType)[typeValue intValue];
    
    [InputPasswordView popUpViewWithType:type
                                delegate:self
                                 smsCode:nil];
}

/**
 *  点击动club优惠劵
 */
-(void)didClickactClubCell{
    [MobClickUtils event:umeng_event_click_my_wallet_club_button];
    if (self.userClubStatus == 1) {
        MonthCardRechargeController *vc = [[MonthCardRechargeController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        ActClubIntroduceController *vc = [[ActClubIntroduceController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
