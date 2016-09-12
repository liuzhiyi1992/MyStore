//
//  BusinessOrderConfirmBottomView.h
//  Sport
//
//  Created by 江彦聪 on 8/9/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BusinessOrderConfirmBottomViewDelegate<NSObject>
-(void) prepareForPriceDetailView:(NSMutableArray *)priceDetailArray;
-(void) didClickSubmitButton;
@end
@interface BusinessOrderConfirmBottomView : UIView
@property (assign, nonatomic) id<BusinessOrderConfirmBottomViewDelegate> delegate;
+ (BusinessOrderConfirmBottomView *)createBusinessOrderConfirmBottomView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *detailPriceHolderView;

@property (weak, nonatomic) IBOutlet UILabel *needPayPriceLabel;
-(void) isShowPriceDetail:(BOOL)isShow;
@end
