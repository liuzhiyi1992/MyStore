//
//  OrderDetailViewVenue.m
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailViewVenue.h"
#import "Product.h"
#import "BusinessGoods.h"
#import "PriceUtil.h"
#import "Order.h"

NSInteger const ITEM_LINE_SPACING = 8;

@interface OrderDetailViewVenue ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsLabel;
@property (weak, nonatomic) IBOutlet UIView *goodsView;
@property (strong, nonatomic) Order *order;
@end

@implementation OrderDetailViewVenue
+ (OrderDetailViewVenue *)createViewWithOrder:(Order *)order {
    OrderDetailViewVenue *view = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailViewVenue" owner:self options:nil][0];
    view.order = order;
    [view configureView];
    return view;
}

- (void)configureView {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *weekdayArray = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    [formatter setShortWeekdaySymbols:weekdayArray];
    [formatter setDateFormat:@"MM月dd日(eee)"];
    _dateLabel.text = [formatter stringFromDate:_order.useDate];
    
    //productList
    NSMutableString *mutableString = [NSMutableString string];
    for (Product *product in _order.productList) {
        NSString *priceString = (_order.type != OrderTypeMembershipCard) ? [NSString stringWithFormat:@" %@", [PriceUtil toPriceStringWithYuan:[product price]]] : @"";
        [mutableString appendString:[NSString stringWithFormat:@"%@ %@%@\n", product.courtName, [product startTimeToEndTime], priceString]];
    }
    //调整行距
    [self fitLineSpacingWithLabel:_venuesLabel mutableString:mutableString];
    
    //goodsList
    if (_order.goodsList.count == 0) {
        [_goodsView removeFromSuperview];
    } else {
        NSMutableString *goodMutableString = [NSMutableString string];
        for (BusinessGoods *goods in _order.goodsList) {
            NSString *totalCountString = @"";
            if (goods.totalCount > 1) {
                totalCountString = [NSString stringWithFormat:@"x%d", goods.totalCount];
            }
            [goodMutableString appendString:[NSString stringWithFormat:@"%@ %@%@\n", goods.name, [PriceUtil toPriceStringWithYuan:goods.price], totalCountString]];
        }
        //调整行距
        [self fitLineSpacingWithLabel:_goodsLabel mutableString:goodMutableString];
    }
}

- (void)fitLineSpacingWithLabel:(UILabel *)label mutableString:(NSMutableString *)mutableString {
    if (mutableString.length > 2) {
        //去除最后换行符
        NSString *productString = [mutableString substringToIndex:mutableString.length - 1];
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:productString];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:ITEM_LINE_SPACING];
        [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, productString.length)];
        label.attributedText = attributeString;
    }
}


@end
