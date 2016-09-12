//
//  ConvertPointGoodsController.m
//  Sport
//
//  Created by haodong  on 14/11/21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ConvertPointGoodsController.h"
#import "PointGoods.h"
#import "User.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"

@interface ConvertPointGoodsController ()
@property (strong, nonatomic) PointGoods *pointGoods;
@property (copy, nonatomic) NSString *drawId;
@end

@implementation ConvertPointGoodsController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithPointGoods:(PointGoods *)pointGoods
                            drawId:(NSString *)drawId
{
    self = [super init];
    if (self) {
        self.pointGoods = pointGoods;
        self.drawId = drawId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"领取奖品";
    
    [self.backgroundImageView setImage:[SportImage whiteBackgroundRoundImage]];
    [self.phoneBackgroundImageView setImage:[SportImage grayBackgroundRoundImage]];
    
    self.goodsTitleLabel.text = _pointGoods.title;
    
//    [self.submitButton setBackgroundImage:[SportImage blueFrameButtonImage] forState:UIControlStateNormal];
}

- (IBAction)clickSubmitButton:(id)sender {
    
    if ([_phoneTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请填写手机号码"];
        return;
    }
    
    if ([_phoneTextField.text length] != 11) {
        [SportPopupView popupWithMessage:@"请填写11位手机号码"];
        return;
    }
    
    [_phoneTextField resignFirstResponder];
    
    [SportProgressView showWithStatus:@"加载中"];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    [PointService convertGoods:self
                        userId:user.userId
                       goodsId:_pointGoods.goodsId
                        drawId:_drawId
                          type:@"1"
                         phone:_phoneTextField.text];
    
}

- (void)didConvertGoods:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"提交成功"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"奖品领取成功，请耐心等候工作人员的来电" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView performSelector:@selector(show) withObject:nil afterDelay:0.5];
        
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithSuccess:@"提交失败，请重试"];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:nil afterDelay:0.25];
}

- (IBAction)touchDownBackground:(id)sender {
    [self.phoneTextField resignFirstResponder];
}

@end
