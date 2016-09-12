//
//  CoachOrderAddressCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachOrderAddressCell.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
#import "UIColor+HexColor.h"
#import "CoachServiceArea.h"
#import "SportPopupView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "AMapSearchAddressView.h"
#import "CityManager.h"
#import "CoachOftenArea.h"

@interface CoachOrderAddressCell()<AMapSearchDelegate,AMapSearchAddressViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UIView *inputAddressView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (strong, nonatomic) AMapSearchAPI *searchAPI;
@property (strong, nonatomic) AMapSearchAddressView *searchView;
@property (weak, nonatomic) IBOutlet UIImageView *cancelInputIcon;
@property (copy, nonatomic) NSString *selectedAddress;
@property (assign, nonatomic) CGFloat keyboardHeight;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@end
#define MAX_INPUT_LENGTH 50
@implementation CoachOrderAddressCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)registerForKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
     ];
    [self.searchView removeFromSuperview];
}

+ (NSString *)getCellIdentifier
{
    return @"CoachOrderAddressCell";
}

+ (CGFloat)getCellHeight
{
    return 43;
}

- (void) awakeFromNib
{
    [self initSearching];
    self.inputTextView.delegate = self;
    [self registerForKeyboardNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelInput) name:NOTIFICATION_NAME_CANCEL_COACH_ADDRESS_INPUT object:nil];
    
}

- (void)updateCellWithTitle:(CoachOftenArea *)area
                 isSelected:(BOOL)isSelected
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    UIImage *image = nil;
    if (indexPath.section == 0 && indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image];
    [self setBackgroundView:bv];
    
    if (indexPath.section == 0) {
        self.rightImageView.hidden = YES;
        self.inputAddressView.hidden = NO;
        self.itemLabel.hidden = YES;
        self.addressLabel.hidden = YES;
        self.selectedButton.hidden = YES;
        if (area == nil || area.businessName == nil) {
            self.noticeLabel.hidden = NO;
//            NSMutableString *areaString = [NSMutableString string];
//            for (CoachServiceArea *area in self.serviceAreaList) {
//                [areaString appendString:area.regionName];
//            }
            
            //self.noticeLabel.text = [NSString stringWithFormat:@"输入指定地点（须在%@内）",areaString];
            self.noticeLabel.text = [NSString stringWithFormat:@"请提前与教练确认地址"];
        } else {
            self.noticeLabel.hidden = YES;
            self.inputTextView.text = area.businessName;
            self.selectedAddress = area.businessName;
        }

        self.cancelInputIcon.hidden = YES;
    } else {
        self.inputAddressView.hidden = YES;
        self.selectedButton.hidden = NO;
        self.itemLabel.hidden = NO;
        self.itemLabel.text = area.businessName;
        self.addressLabel.hidden = NO;
        self.addressLabel.text = area.addressName;
        self.rightImageView.hidden = NO;
        
    }
    
    if (isSelected) {
        image = [SportImage radioButtonSelectedImage];
    } else {
        image = [SportImage radioButtonUnselectedImage];
    }
    self.rightImageView.image = image;
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
}

#define OFFSET (20+44+44+45)
- (IBAction)didClickButton:(id)sender {
    
    if (self.indexPath.section == 0) {
//        if ([self.inputTextView.text isEqualToString:@""]) {
//            self.noticeLabel.hidden = NO;
//        }else {
//            self.noticeLabel.hidden = YES;
//        }
//        
//        [self initSearching];
//        
//        self.searchView = [AMapSearchAddressView createAMapSearchAddressView];
//        self.searchView.delegate = self;
//        
//        [self.inputTextView becomeFirstResponder];
        
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(didClickCellWithIndex:address:isPop:)]) {
        [_delegate didClickCellWithIndex:self.indexPath address:self.inputTextView.text isPop:YES];
    }
    
    [self.inputTextView resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.noticeLabel.hidden = YES;
    //self.selectedButton.hidden = YES;
    self.cancelInputIcon.hidden = NO;
    if ([_delegate respondsToSelector:@selector(refreshSelectionWithAddress)]) {
        [_delegate refreshSelectionWithAddress];
    }
    
    if (self.searchView == nil) {
        self.searchView = [AMapSearchAddressView createAMapSearchAddressView];
        self.searchView.delegate = self;
    }
    
    [self.searchView showWithFrame:CGRectMake(0, OFFSET, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - OFFSET)];
    
    self.rightImageView.image = [SportImage radioButtonSelectedImage];
    if (![textView.text isEqualToString:@""]) {
        [self placeSearchingWithKey:textView.text city:[CityManager readCurrentCityName]];
    }
    
    return YES;

}

//收起textView键盘时会自动调用
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.noticeLabel.hidden = NO;
    }else {
        self.noticeLabel.hidden = YES;
    }
    
    self.cancelInputIcon.hidden = YES;
    //self.selectedButton.hidden = NO;
    
    return YES;

}


- (void)textViewDidChange:(UITextView *)textView {
    [self placeSearchingWithKey:textView.text city:[CityManager readCurrentCityName]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * aString = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if (aString.length > MAX_INPUT_LENGTH) {
        textView.text = [aString substringToIndex:MAX_INPUT_LENGTH];
        [SportPopupView popupWithMessage:@"超过最长长度啦！"];
        return NO;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [self.inputTextView resignFirstResponder];
        return NO;
    }
    
    
    return YES;
}

- (void)initSearching {
    self.searchAPI = [[AMapSearchAPI alloc] init];
    self.searchAPI.delegate = self;
}

- (void)placeSearchingWithKey:(NSString *)key city:(NSString *)city {
    
    //POI搜索
    //AMapPOIKeywordsSearchRequest *tipsRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
    //    tipsRequest.types = @"体育休闲服务";
    //    tipsRequest.requireExtension = YES;
    //    [self.searchAPI AMapPOIKeywordsSearch:tipsRequest];

    //输入提示
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = key;
    tipsRequest.city = city;
    [self.searchAPI AMapInputTipsSearch:tipsRequest];

}
//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {
    
    NSMutableArray *dataList = [NSMutableArray array];
    
    for (AMapTip *tip in response.tips) {
        //HDLog(@"\n%@\n%@\n(%f, %f)", tip.name, tip.district, tip.location.latitude, tip.location.longitude);
        [dataList addObject:tip];
    }
    
    [self.searchView refreshDataList:dataList height:[UIScreen mainScreen].bounds.size.height - OFFSET - self.keyboardHeight];
}

-(void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    
    NSLog(@"%@", error);
}

- (void) keyboardWasShown:(NSNotification *) notif {
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    self.keyboardHeight = [value CGRectValue].size.height;
    
    ///keyboardWasShown = YES;
}

- (void) keyboardWasHidden:(NSNotification *) notif {

    // keyboardWasShown = NO;
    self.keyboardHeight = 0;
    [self.searchView refreshHeight:[UIScreen mainScreen].bounds.size.height - OFFSET];

}
- (IBAction)clickCancelInputButton:(id)sender {
    [self didCancelInput];
}

-(void) didClickAddress:(NSString *)address {
    self.selectedAddress = address;
    [self.inputTextView resignFirstResponder];
    
    [self.searchView removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(didClickCellWithIndex:address:isPop:)]) {
        [_delegate didClickCellWithIndex:self.indexPath address:self.selectedAddress isPop:YES];
    }
//    
//    if ([_delegate respondsToSelector:@selector(popBackButton)]) {
//        [_delegate popBackButton];
//    }
}

-(void)didCancelInput {
    self.inputTextView.text = @"";
    [self.inputTextView resignFirstResponder];
    [self.searchView removeFromSuperview];
}

-(void) didScrollTableView {
    [self.inputTextView resignFirstResponder];
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    self.noticeLabel.hidden = YES;
//    if ([_delegate respondsToSelector:@selector(refreshSelectionWithAddress)]) {
//        [_delegate refreshSelectionWithAddress];
//    }
//    
//    self.rightImageView.image = [SportImage radioButtonSelectedImage];
//    
//    return YES;
//}
//
//
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if ([self.addressTextField.text isEqualToString:@""]) {
//        self.noticeLabel.hidden = NO;
//    }else {
//        self.noticeLabel.hidden = YES;
//    }
//    
//    if ([_delegate respondsToSelector:@selector(didClickCellWithIndex:address:isPop:)]) {
//        [_delegate didClickCellWithIndex:self.indexPath address:self.addressTextField.text isPop:NO];
//    }
//    
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
////    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//
//    return YES;
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    if ([_delegate respondsToSelector:@selector(popBackButton)]) {
//        [_delegate popBackButton];
//    }
//    
//    [self.addressTextField resignFirstResponder];
//    return YES;
//}

@end
