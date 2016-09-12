//
//  MembershipCardCell.m
//  Sport
//
//  Created by 江彦聪 on 15/4/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MembershipCardCell.h"
#import "PriceUtil.h"

@interface MembershipCardCell()
@property (weak, nonatomic) IBOutlet UILabel *cardNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardMoneyLabel;
@property (weak, nonatomic) IBOutlet UIView *unBindedCardView;
@property (weak, nonatomic) IBOutlet UILabel *unBindedCardNameLabel;
@property (weak, nonatomic) IBOutlet UIView *bindCardView;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
@property (weak, nonatomic) IBOutlet UIImageView *infoIcon;

@property (strong,nonatomic) NSIndexPath *indexPath;

@end

@implementation MembershipCardCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (CGFloat)getCellHeight
{
    return 77;
}

+ (CGFloat)getCellHeightWithIndex:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 77;
    }
    else
    {
        return 55;
    }
}

+ (NSString *)getCellIdentifier
{
    return @"MembershipCardCell";
}

+ (id)createCell
{
    MembershipCardCell *cell = (MembershipCardCell *)[super createCell];
    
    cell.bindButton.layer.cornerRadius = 3.0f;
    cell.bindButton.layer.masksToBounds = YES;
    cell.bindButton.layer.borderColor = [[SportColor defaultColor] CGColor];
    cell.bindButton.layer.borderWidth = 1.0;
    
    [cell.bindButton setBackgroundImage:[SportColor createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    return cell;
}

- (void)updateCellWithCard:(MembershipCard *)card
                isSelected:(BOOL)isSelected
                 indexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    if (indexPath.section == 0) {
        self.unBindedCardView.hidden = YES;
        self.bindCardView.hidden = NO;
        self.cardNameLabel.text = card.businessName;
        self.cardMoneyLabel.text = [PriceUtil toValidPriceString:card.money];
        self.cardNumberLabel.text = card.cardNumber;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if (card.status == CardStatusLock){
            self.infoIcon.hidden = NO;
        } else {
            self.infoIcon.hidden = YES;
        }
    }
    else
    {
        self.unBindedCardView.hidden = NO;
        self.bindCardView.hidden = YES;
        self.unBindedCardNameLabel.text = card.businessName;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *backgroundImage = nil;
        backgroundImage = [SportImage otherCellBackground4Image];
        UIImageView *bv = [[UIImageView alloc] initWithImage:backgroundImage] ;
        [self setBackgroundView:bv];
        
    }
}

- (IBAction)clickBindButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickBindButton:)]) {
        [_delegate didClickBindButton:self.indexPath];
    }
}


@end
