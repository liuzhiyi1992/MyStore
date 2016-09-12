//
//  BusinessGoodsListCell.h
//  Sport
//
//  Created by 江彦聪 on 16/8/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

#import "BusinessGoods.h"

@protocol BusinessGoodsListCellDelegate <NSObject>
- (void) updateSelectedGoods:(BusinessGoods *) goods;

@end

@interface BusinessGoodsListCell : DDTableViewCell
@property (assign, nonatomic) id<BusinessGoodsListCellDelegate> delegate;
-(void) updateCellWithGoods:(BusinessGoods *)goods;

@end
