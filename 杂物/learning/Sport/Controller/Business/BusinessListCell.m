//
//  BusinessListCell.m
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessListCell.h"
#import "Business.h"
#import "UIView+Utils.h"
#import <CoreLocation/CoreLocation.h>
#import "UserManager.h"
#import "PriceUtil.h"
#import "SmallPromoteView.h"
#import "BusinessCategoryManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSString+Utils.h"
#import "CLLocation+Util.h"

#define ICON_FIRST_IMAGEVIEW_TAG     20
#define ICON_SECOND_IMAGEVIEW_TAG    30

@interface BusinessListCell()
@property (strong, nonatomic) NSMutableArray *smallPromoteViewList;
@property (strong, nonatomic) NSArray *priceButtomConstraintArray;
@property (strong, nonatomic) NSMutableArray *promoteViewConstraintArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceButtomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceHolderViewConstraintY;

@property (strong, nonatomic) IBOutlet UILabel *idleVenueLabel;

@end

@implementation BusinessListCell

+ (NSString*)getCellIdentifier
{
    return @"BusinessListCell";
}
#define CELL_DEFAULT_MARGIN 8
#define CELL_BLANK_MARGIN 7


// default without promote
+ (CGFloat)getCellHeight
{
    // priceHolderView.orgin.y + priceHolderView.size.height +  X
    return 77;
}

+ (CGFloat)getCellHeightWithBusiness:(Business *)business
{
    if([business.promoteList count] != 0)
    {
        //SmallPromoteView.orgin.y + SmallPromoteView.size.height +  X
        return 83+10;
    }
    else
    {
        return [self getCellHeight];
    }
}

+ (id)createCell
{
    BusinessListCell *cell = [super createCell];
    [cell.oldPriceLineImageView setImage:[SportImage lineImage]];
    cell.smallPromoteViewList = [NSMutableArray array];
    return cell;
}

//#define MAX_WIDTH_LATEST_PRICE_LABEL    150
#define SPACE_BETWEEN_TWO_PRICE         0

- (void)updateCell:(Business *)business
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    [self updateCell:business indexPath:indexPath isLast:isLast isShowCategory:NO];
}

- (void)updateCell:(Business *)business
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
    isShowCategory:(BOOL)isShowCategory
{
    self.accessibilityLabel = business.name;
    
    UIImage *backgroundImage = nil;
    if (indexPath.row == 0 && isLast ) {
        backgroundImage = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        backgroundImage = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        backgroundImage = [SportImage otherCellBackground3Image];
    } else {
        backgroundImage = [SportImage otherCellBackground2Image];
    }
    UIImageView *bv = [[UIImageView alloc] initWithImage:backgroundImage];
    [self setBackgroundView:bv];
    
    self.nameLabel.text = business.name;
    
    NSString *category = nil;
    if (isShowCategory) {
        category = [[BusinessCategoryManager defaultManager] categoryNameById:business.defaultCategoryId];
    }
    
    if ([business.neighborhood length] > 0 || (isShowCategory && category)) {
        self.neighborhoodLabel.hidden = NO;
        NSMutableString *neighborhoodString = [NSMutableString stringWithFormat:@""];
        
        if (isShowCategory && category) {
            [neighborhoodString appendFormat:@"[%@]", category];
        }
        
        if ([business.neighborhood length] > 0) {
            [neighborhoodString appendFormat:@"[%@]", business.neighborhood];
        }
        
        self.neighborhoodLabel.text = neighborhoodString;
        CGSize neighborhoodSize = [self.neighborhoodLabel.text sizeWithMyFont:self.neighborhoodLabel.font];
        [self.neighborhoodLabel updateWidth:neighborhoodSize.width];

        self.priceHolderViewConstraintY.constant = 42;
    } else {
        self.neighborhoodLabel.hidden = YES;
        self.priceHolderViewConstraintY.constant = 10;
    }
    
    CLLocation *userLocation = [[UserManager defaultManager] readUserLocation];
    CLLocation *businessLocation = [[CLLocation alloc] initWithLatitude:business.latitude longitude:business.longitude];
    self.distanceLabel.text = [userLocation distanceStringValueFromLocation:businessLocation];
    
    
    //如果有折后价，则显示折后价和原价
    if (business.promotePrice > 0) {
        
        self.priceHolderView.hidden = NO;
        self.oldPriceLabel.hidden = NO;
        self.oldPriceLineImageView.hidden = NO;
        
        _latestPriceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:business.promotePrice]];
        _oldPriceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:business.price]];
        
    } else {
        
        if (business.price > 0) {//如果没有折后价，有原价则只显示原价
            
            self.priceHolderView.hidden = NO;
            self.oldPriceLabel.hidden = YES;
            self.oldPriceLineImageView.hidden = YES;
            
            _latestPriceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:business.price]];
            
        } else { //如果没有折后价，没有原价则什么都不显示
            
            self.priceHolderView.hidden = YES;
            self.priceHolderViewConstraintY.constant = 10;
        }
    }
    
    UIView *vflRightView = self.nameLabel;//动态添加的icon的右边的控件
    
    UIImageView *firstImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RefundImage"]];
    UIImageView *secondImageView = [[UIImageView alloc] init];
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(firstImageView, secondImageView, vflRightView);
    
    [firstImageView setTag:ICON_FIRST_IMAGEVIEW_TAG];
    [secondImageView setTag:ICON_SECOND_IMAGEVIEW_TAG];
    
    
    if([self viewWithTag:ICON_FIRST_IMAGEVIEW_TAG] != nil) {
        [[self viewWithTag:ICON_FIRST_IMAGEVIEW_TAG] removeFromSuperview];
    }
    if([self viewWithTag:ICON_SECOND_IMAGEVIEW_TAG] != nil) {
        [[self viewWithTag:ICON_SECOND_IMAGEVIEW_TAG] removeFromSuperview];
    }
    
    firstImageView.translatesAutoresizingMaskIntoConstraints = NO;
    secondImageView.translatesAutoresizingMaskIntoConstraints = NO;
    vflRightView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if(business.canRefund) {//可退款
        if(business.isCardUser || business.isOften) {//有第二个icon
            if(business.isCardUser) {//会员
                [secondImageView setImage:[UIImage imageNamed:@"VIPImage"]];
            }else if(business.isOften) {
                [secondImageView setImage:[UIImage imageNamed:@"OftenImage"]];
            }
            //执行
            [self addSubview:firstImageView];
            [self addSubview:secondImageView];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[firstImageView(13)]-5-[secondImageView(13)]-5-[vflRightView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstImageView(13)]" options:0 metrics:nil views:viewDict]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[secondImageView(13)]" options:0 metrics:nil views:viewDict]];
        }else {//只有可退款
            //执行
            [self addSubview:firstImageView];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[firstImageView(13)]-5-[vflRightView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstImageView(13)]" options:0 metrics:nil views:viewDict]];
        }
    }else if(business.isCardUser || business.isOften){//没有可退款,有剩下两个其一
        if(business.isCardUser) {//会员
            [secondImageView setImage:[UIImage imageNamed:@"VIPImage"]];
        }else if(business.isOften) {
            [secondImageView setImage:[UIImage imageNamed:@"OftenImage"]];
        }
        //执行
        [self addSubview:secondImageView];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[secondImageView(13)]-5-[vflRightView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[secondImageView(13)]" options:0 metrics:nil views:viewDict]];
    }

    //判断场馆是否支持动club
    if (business.isSupportClub == 0) {
        self.clubImageView.hidden = YES;
    }else{
        self.clubImageView.hidden = NO;
    }
    
    if (business.idleVenue == nil) {
        self.idleVenueLabel.hidden = YES;
    }else{
        self.idleVenueLabel.hidden = NO;
        self.idleVenueLabel.text = business.idleVenue;
    }

    for (SmallPromoteView *view in _smallPromoteViewList) {
        
        //不要Hide，需要remove
        //view.hidden = YES;
        [view removeFromSuperview];
    }
    
    int promoteMessageIndex = 0;
    CGFloat promoteMessageLast = 0;
    CGFloat promoteMessageX = 0;
    SmallPromoteView *previousView = nil;
    NSMutableDictionary *viewsDictionary = [[ NSMutableDictionary alloc] initWithDictionary:    @{@"priceHolderView":self.priceHolderView,
                                               @"contentView":self.contentView
                                               }];
    NSMutableArray *constraints = [NSMutableArray array];
    for (NSString *promote in business.promoteList) {
        SmallPromoteView *view = nil;
        if (promoteMessageIndex + 1 > [_smallPromoteViewList count]) {
            view = [SmallPromoteView createSmallPromoteView];
            [self.smallPromoteViewList addObject:view];

        } else {
            view = [_smallPromoteViewList objectAtIndex:promoteMessageIndex];
        }
        
        [self.contentView addSubview:view];
        //view.hidden = NO;
        
        [view updateView:promote];
        
        [viewsDictionary addEntriesFromDictionary:@{@"labelView":view.valueLabel,
                                                    @"currentView":view}];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        if (promoteMessageIndex == 0) {
            //第一个活动与价钱左对齐，而且有垂直间隔为5
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[priceHolderView]-5-[currentView]" options:NSLayoutFormatAlignAllLeading metrics:nil views:viewsDictionary]];
            //[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[currentView]-10-|" options:0 metrics:nil views:viewsDictionary]];
        }
        else {
            
            [viewsDictionary addEntriesFromDictionary:@{@"prevView":previousView}];
            if (previousView != nil) {
                // 活动之间水平间距
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[prevView]-3-[currentView]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDictionary]];
            }
            else {
                HDLog(@"previous view is nil, promoteMessageIndex = %d", promoteMessageIndex);
            }
        }

        //活动高度
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[currentView(==labelView)]" options:0 metrics:nil views:viewsDictionary]];
        //活动宽度
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[currentView(==labelView)]" options:0 metrics:nil views:viewsDictionary]];

        //promoteMessageX = promoteMessageEnd - view.frame.size.width;
        promoteMessageX = self.priceHolderView.frame.origin.x + promoteMessageLast;
        [view updateOriginX:promoteMessageX];
        [view updateOriginY:self.priceHolderView.frame.origin.y+self.priceHolderView.frame.size.height+5];
        promoteMessageLast += view.frame.size.width+3;
        previousView = view;
        promoteMessageIndex ++;
    }

    if (promoteMessageIndex == 0) {

        self.priceButtomConstraint.constant = 15.0f;
     }
    else
    {
        
        SmallPromoteView *view = [self.smallPromoteViewList objectAtIndex:0];
        self.priceButtomConstraint.constant = 5.0f + view.frame.size.height + 15.0f;
        
        if (self.promoteViewConstraintArray == nil) {
            self.promoteViewConstraintArray = constraints;
        }
        
        [self.contentView addConstraints:constraints];
    }
}
@end

