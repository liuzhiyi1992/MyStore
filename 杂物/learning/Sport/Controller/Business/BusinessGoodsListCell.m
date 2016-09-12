//
//  BusinessGoodsListCell.m
//  Sport
//
//  Created by 江彦聪 on 16/8/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessGoodsListCell.h"
#import "SportPlusMinusView.h"
#import "PriceUtil.h"

@interface BusinessGoodsListCell()<SportPlusMinusViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *plusMinusHolderView;
@property (strong, nonatomic) SportPlusMinusView *plusMinusView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *specLabel;
@property (strong, nonatomic) BusinessGoods *goods;

@end
@implementation BusinessGoodsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    if (self.plusMinusView == nil) {
        self.plusMinusView = [SportPlusMinusView createSportPlusMinusViewWithMaxNumber:99 minNumber:0];
        self.plusMinusView.delegate = self;
        
        [self.plusMinusHolderView addSubview:self.plusMinusView];
    }
}

+ (NSString *)getCellIdentifier
{
    return @"BusinessGoodsListCell";
}

-(void) updateCellWithGoods:(BusinessGoods *)goods {
    self.goods = goods;
    self.goodsNameLabel.text = [NSString stringWithFormat:@"%@ %@",goods.name, [PriceUtil toPriceStringWithYuan:goods.price]];
    self.specLabel.text = goods.speci;
    self.plusMinusView.countNumber = goods.totalCount;
    self.plusMinusView.maxNumber = goods.limitCount;
    
    [self.plusMinusView updateMinusButtonAndPlusButton];
}

+ (CGFloat)getCellHeight
{
    return 55;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) updateSelectNumber:(int) number {
    if ([_delegate respondsToSelector:@selector(updateSelectedGoods:)]) {
        self.goods.totalCount = number;
        [_delegate updateSelectedGoods:self.goods];
    }
}
@end
