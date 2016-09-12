//
//  ConfirmPayTypeCell.m
//  Sport
//
//  Created by haodong  on 15/4/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ConfirmPayTypeCell.h"
#import "CardSelectedCell.h"
#import "MembershipCard.h"
#import "PriceUtil.h"

@interface ConfirmPayTypeCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) ConfirmPayType type;

@end

@implementation ConfirmPayTypeCell

-(void)awakeFromNib {
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
}

+ (CGFloat)getCellHeight
{
    return 46;
}

+ (NSString *)getCellIdentifier
{
    return @"ConfirmPayTypeCell";
}

//会员卡支付
- (void)updateCellWithType:(ConfirmPayType)type
                isSelected:(BOOL)isSelected
                  subTitle:(NSString *)subTitle
                 indexPath:(NSIndexPath *)indexPath
                    isLast:(BOOL)isLast
                  cardList:(NSArray *)list
{
    [self updateCellWithType:type isSelected:isSelected subTitle:subTitle indexPath:indexPath isLast:isLast];
    self.cardList = list;
    [self.dataTableView reloadData];
}

//第三方支付
- (void)updateCellWithType:(ConfirmPayType)type
                isSelected:(BOOL)isSelected
                  subTitle:(NSString *)subTitle
                 indexPath:(NSIndexPath *)indexPath
                    isLast:(BOOL)isLast
{
    UIImage *image = nil;
    
    if (indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image] ;
    [self setBackgroundView:bv];
    
    self.type = type;
    self.subTitleLabel.hidden = NO;
    self.subTitleLabel.text = subTitle;
    
    if (self.type == ConfirmPayTypeMembershipCard) {
        self.titleLabel.text = @"会员卡订场";
        self.iconImageView.image = [SportImage cardPayImage];
    } else if (self.type == ConfirmPayTypeOnline) {
        self.titleLabel.text  = @"在线支付";
        self.iconImageView.image = [SportImage onlinePayImage];
    } else if (self.type == ConfirmPayTypeClub) {
        self.titleLabel.text  = @"动Club";
        self.iconImageView.image = [SportImage clubPayImage];
        self.subTitleLabel.hidden = NO;
        self.subTitleLabel.text = subTitle;
    }
    
    self.rightImageView.hidden = NO;
    if (isSelected) {
        image = [SportImage radioButtonSelectedImage];
        if (self.type == ConfirmPayTypeMembershipCard) {
            self.rightImageView.hidden = YES;
        }
    } else {
        image = [SportImage radioButtonUnselectedImage];
    }
    self.rightImageView.image = image;
}


#pragma mark - dataTableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cardList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CardSelectedCell getCellIdentifier];
    CardSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CardSelectedCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    MembershipCard *card = [self.cardList objectAtIndex:indexPath.row];
    
    BOOL isSelected = NO;
    NSString *selectedCardNumber = @"";
    if ([_delegate respondsToSelector:@selector(getSelectedMembershipCardNumber)]) {
        selectedCardNumber =[_delegate getSelectedMembershipCardNumber];
    }
    
    isSelected = ([selectedCardNumber isEqualToString:card.cardNumber]);
    [cell updateCellWithNumber:card.cardNumber balance:[PriceUtil toPriceStringWithYuan:card.money] isSelected:isSelected indexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ConfirmPayTypeCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     MembershipCard *card = [self.cardList objectAtIndex:indexPath.row];
    
    if ([_delegate respondsToSelector:@selector(setSelectedMembershipCardNumber:)]) {
        [_delegate setSelectedMembershipCardNumber:card.cardNumber];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

@end
