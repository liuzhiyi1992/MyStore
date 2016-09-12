//
//  OrderDetailViewSingle.h
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailViewSingle : UIView
- (instancetype)initWithGoodsName:(NSString *)goodsName
                       goodsPrice:(double)goodPrice
                            count:(int)count
                        detailUrl:(NSString *)detailUrl;
@end
