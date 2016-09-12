//
//  SystemMessageCategoryListCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SystemMessageCategoryListCell.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"

@interface SystemMessageCategoryListCell()
@property (retain, nonatomic) SystemMessage* message;
@property (retain, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *redPointButton;
@end

@implementation SystemMessageCategoryListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)getCellIdentifier
{
    return @"SystemMessageCategoryListCell";
}

-(void) awakeFromNib {
    self.avatarImageView.layer.cornerRadius = 20.0f;
    self.avatarImageView.layer.masksToBounds = YES;
}

+ (id)createCell
{
    SystemMessageCategoryListCell *cell = [super createCell];
    
    return cell;
}

// default
+ (CGFloat)getCellHeight
{
    return 100;
}


- (void)updateCell:(SystemMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    self.message = message;
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
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:message.iconUrl]
                            placeholderImage:[UIImage imageNamed:@"defaultIcon"]];
    self.titleLabel.text = message.typeName;
    
    if (message.type != MessageCountTypeForum) {
        self.subTitleLabel.text = message.message;
    } else {
        self.subTitleLabel.text = [NSString stringWithFormat:@"%@回复了我的帖子：%@",message.fromUser,message.message];
    }
    
    self.sendTimeLabel.text = [DateUtil messageBriefTimeString:message.addTime formatter:nil];
    
    if (message.number > 0) {
        self.redPointButton.hidden = NO;
        [self.redPointButton setTitle:[@(message.number) stringValue] forState:UIControlStateNormal];
    } else {
        self.redPointButton.hidden = YES;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
}

- (IBAction)clickMessageButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickMessageButton:)]) {
        [_delegate didClickMessageButton:self.message];
    }
}


@end
