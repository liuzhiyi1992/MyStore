//
//  OrderConfirmPriceDetailView.h
//  Sport
//
//  Created by 江彦聪 on 8/16/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderConfirmPriceDetailView : UIView
+ (OrderConfirmPriceDetailView *)createOrderConfirmPriceDetailView;
-(void) updateDataList:(NSArray *)dataList bottomViewHeight:(CGFloat) bottomHeight;
@end
