//
//  CoachBriefCell.m
//  Sport
//
//  Created by liuzhiyi on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachBriefCell.h"
#import "SportImage.h"
#import "UIImage+normalized.h"
#import "UIView+Utils.h"
#import "UIImageView+WebCache.h"
#import "CLLocation+Util.h"
#import "UserManager.h"
#import "BusinessCategory.h"
#import "PriceUtil.h"

@implementation CoachBriefCell

+ (id)createCell {
    CoachBriefCell *cell = [super createCell];
    
    //初始化cell布局
    [cell initLayout];
    return cell;
}

+ (NSString *)getCellIdentifier {
    return @"CoachBriefCell";
}

+ (CGFloat)getCellHeight {
    return 110.0;
}

- (void)initLayout {
    //分类图标
    _categoryButton.layer.cornerRadius = _categoryButton.bounds.size.height/2;
    _categoryButton.layer.borderColor = [UIColor hexColor:@"4f6dcf"].CGColor;
    _categoryButton.layer.borderWidth = 1.f;
    [_categoryButton setTitleColor:[UIColor hexColor:@"5b73f2"] forState:UIControlStateNormal];
    
    //cell背景图片
    self.backgroundView = [[UIImageView alloc] initWithImage:[[SportImage whiteBackgroundWithGrayLineImage] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    
    //适配iphone4
    if([UIScreen mainScreen].bounds.size.height <= 480) {
        for (NSLayoutConstraint *constraint in self.sizedConstraints) {
            constraint.constant = 0.9 * constraint.constant;
        }
    }
    
    //圆形imageview
    self.headImageView.layer.cornerRadius = 0.5 * self.headImageViewHeightConstraint.constant;
    self.headImageView.layer.masksToBounds = YES;
    
    if([[UserManager defaultManager] readUserLocation] == nil) {
        self.distanceButton.hidden = YES;
    }
}

- (void)updateCellWithCoach:(Coach *)coach {
    
    //名字
    self.nameLabel.text = coach.name;
    
    //描述
    self.descLabel.text = coach.introduction;
    
    //头像
    NSURL *imgUrl = [NSURL URLWithString:coach.imageUrl];
    [self.headImageView sd_setImageWithURL:imgUrl];
    
    //价格
    self.priceLabel.text = [NSString stringWithFormat:@"均价：%@元",coach.price];
    
    //项目
    if(coach.categoryList.count > 0){
        BusinessCategory *businessCategory = coach.categoryList[0];
        [_categoryButton setTitle:businessCategory.name forState:UIControlStateNormal];
        _categoryButton.hidden = NO;
    }else {
        _categoryButton.hidden = YES;
    }
    
    //距离-1.9不做，暂时去掉
    /*
    NSString *distance = [self getDistanceStringWithLatitude:coach.latitude Longitude:coach.longitude];
    if(nil == distance) {
        self.distanceButton.hidden = YES;
    }else {
        [self.distanceButton setTitle:distance forState:UIControlStateNormal];
        self.distanceButton.hidden = NO;
    }
     */
    
    /*  1.9去掉，统一只有一个项目标签
    //约练项目标签
    //先重置隐藏所有项目标签（防止cell重用导致全部标签都显示）
    for (UIButton *btn in _categaryItems) {
        btn.hidden = YES;
    }
    
    int allItemCharCount = 0;
    int charlimit = 0;
    for (int i = 0; i < coach.categoryList.count; i++) {
        BusinessCategory *businessCategory = coach.categoryList[i];
        UIButton *categoryBtn = self.categaryItems[i];
        [categoryBtn setTitle:businessCategory.name forState:UIControlStateNormal];
        categoryBtn.hidden = NO;
        
        allItemCharCount += businessCategory.name.length;

        //iphone4,5防止项目标签超出屏幕边缘(超出标签整体不予显示)
        if([UIScreen mainScreen].bounds.size.height <= 480) {
            charlimit = 11;
        }else {//iphone6
            charlimit = 15;
        }
        
        if(allItemCharCount > charlimit) {
            categoryBtn.hidden = YES;
        }else {
            categoryBtn.hidden = NO;
        }
    }
     */
}

- (NSString *)getDistanceStringWithLatitude:(double)latitude Longitude:(double)longitude {
    
    CLLocation *userLocation = [[UserManager defaultManager] readUserLocation];
    CLLocation *coachLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    return [userLocation distanceStringValueFromLocation:coachLocation];
}

@end
