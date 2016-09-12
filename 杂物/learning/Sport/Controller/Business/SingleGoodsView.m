//
//  SingleGoodsView.m
//  Sport
//
//  Created by haodong  on 15/1/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SingleGoodsView.h"
#import "Goods.h"
#import "PriceUtil.h"
#import "UIView+Utils.h"
#import "SportPopupView.h"

@interface SingleGoodsView()
@property (strong, nonatomic) IBOutlet UIImageView *actClubImageView;
@property (strong, nonatomic) Goods *goods;
@end

@implementation SingleGoodsView


+ (SingleGoodsView *)createSingleGoodsView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SingleGoodsView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SingleGoodsView *view = [topLevelObjects objectAtIndex:0];
    
    [view.lineImageView setImage:[SportImage lineImage]];
    [view.backgroundButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 8.0f;
    
    return view;
}

+ (CGFloat)height
{
    return 83;
}

- (void)updateViewWithGoods:(Goods *)goods row:(NSUInteger)row
{
    self.goods = goods;
    
    if (row > 0) {
        self.lineImageView.hidden = NO;
    } else {
        self.lineImageView.hidden = YES;
    }
    
    self.nameLabel.text = goods.name;
    
    NSDictionary *dic = @{NSFontAttributeName : self.nameLabel.font};
    CGSize size = [self.nameLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.nameLabel.frame.size.height) options:NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    [self.actClubImageView updateOriginX:self.nameLabel.frame.origin.x + size.width + 10];
    [self.actClubImageView updateCenterY:self.nameLabel.center.y];
    
    if ([goods.isSupportClub isEqualToString:@"1"]) {
        self.actClubImageView.hidden = NO;
    }else{
        self.actClubImageView.hidden = YES;
    }
    
    self.priceLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:[goods validPrice]]];
    self.descriptionLabel.text = goods.desc;
    
    if (goods.price > 0 && goods.promotePrice > 0) {
        self.originalPriceHolderView.hidden = NO;
        
        CGSize size = [self.priceLabel sizeThatFits:CGSizeMake(50, 21)];
        [self.originalPriceHolderView updateOriginX:self.priceLabel.frame.origin.x + size.width + 5];
        
        self.originalPriceLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:goods.price]];
        size = [self.originalPriceLabel sizeThatFits:CGSizeMake(200, 21)];
        [self.originalPriceLineView updateWidth:size.width + 2];
    } else {
        self.originalPriceHolderView.hidden = YES;
    }
    
    self.promoteMessageLabel.text = goods.promoteMessage;
    
    if (goods.totalCount == 0) {
        [self.buyButton setTitle:@"已售完" forState:UIControlStateNormal];
//        [self.buyButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateNormal];
        [self.buyButton setBackgroundColor:[SportColor content1Color]];
        self.buyButton.layer.borderColor = [SportColor content1Color].CGColor;
        [self.buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self.buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
        [self.buyButton setBackgroundColor:[UIColor whiteColor]];
        self.buyButton.layer.borderColor = [SportColor defaultColor].CGColor;
        
        [self.buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.buyButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
//        [self.buyButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//        [self.buyButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
//        [self.buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        [self.buyButton setTitleColor:[UIColor hexColor:@"F28F4C"] forState:UIControlStateNormal];
    }
}

- (IBAction)clickBackgroundButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickSingleGoodsViewBuyBackgroundButton:)]) {
        [_delegate didClickSingleGoodsViewBuyBackgroundButton:_goods];
    }
}

- (IBAction)clickBuyButton:(id)sender {
    if (self.goods.totalCount == 0) {
        [SportPopupView popupWithMessage:@"该商品已售完，请选购其他商品"];
    }else{
        if ([_delegate respondsToSelector:@selector(didClickSingleGoodsViewBuyButton:)]) {
            [_delegate didClickSingleGoodsViewBuyButton:_goods];
        }
    }
}

@end
