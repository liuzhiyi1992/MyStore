//
//  SelectGoodsKindView.h
//  Sport
//
//  Created by haodong  on 14-8-16.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Goods;

@protocol SelectGoodsKindViewDelegate <NSObject>

- (void)didSelectedGoods:(Goods *)goods row:(NSInteger)row;

@end


@interface SelectGoodsKindView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *tableHolderView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) id<SelectGoodsKindViewDelegate> delegate;

+ (SelectGoodsKindView *)createSelectGoodsKindView;

- (void)showInView:(UIView *)view dataList:(NSArray *)dataList selectedRow:(NSInteger)selectedRow;

@end
