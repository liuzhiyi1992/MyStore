//
//  SystemMessageTextCell.m
//  Sport
//
//  Created by 江彦聪 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "SystemMessageTextCell.h"
#import "DateUtil.h"
#import "UIImageView+WebCache.h"

@interface SystemMessageTextCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *createTimeButton;

@property (strong, nonatomic) SystemMessage *message;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *messageBackgroundButton;

@end

@implementation SystemMessageTextCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.layer.cornerRadius = 20.0f;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.createTimeButton setBackgroundImage:[SportImage systemMessageTimeBackground] forState:UIControlStateNormal];
    [self.messageButton setBackgroundImage:[SportImage systemMessageBackground] forState:UIControlStateNormal];
    
    self.createTimeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickAvatarButton:(id)sender {
}
- (IBAction)clickMessageButton:(id)sender {
    [MobClickUtils event:umeng_event_click_msg_act_list label:@"文本消息"];
    switch (self.message.messageType) {
        case MessageTypeRecommendVenues:
            if ([_delegate respondsToSelector:@selector(pushBusinessDetailControllerWithBusinessId:categoryId:)]) {
                [_delegate pushBusinessDetailControllerWithBusinessId:self.message.businessId categoryId:self.message.categroyId];
            }
            break;
        case MessageTypeVoucher:
            if ([_delegate respondsToSelector:@selector(pushVoucherController)]) {
                [_delegate pushVoucherController];
            }
            break;
        case MessageTypeOrder:
            if ([_delegate respondsToSelector:@selector(pushOrderListController)]) {
                [_delegate pushOrderListController];
            }
            break;
        case MessageTypeShare:
            if ([_delegate respondsToSelector:@selector(pushInviteShareController)]) {
                [_delegate pushInviteShareController];
            }
            break;
        case MessageTypeMembership:
            if (self.message.webUrl && [_delegate respondsToSelector:@selector(pushWebViewWithUrl:title:)]) {
                [_delegate pushMembershipWebController:self.message.webUrl];
            }
            break;
        case MessageTypeFancyForum:
            if ([_delegate respondsToSelector:@selector(pushPostDetailControllerWithPostId:content:)]) {
                [_delegate pushPostDetailControllerWithPostId:self.message.postId content:self.message.message];
            }
            break;
        default:
            break;
    }
}

+ (NSString*)getCellIdentifier
{
    return @"SystemMessageTextCell";
}

#define HIGHTLIGHT_STRING @"点击"
- (void)updateCell:(SystemMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast {
    self.indexPath = indexPath;
    self.message = message;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:message.iconUrl] placeholderImage:[UIImage imageNamed:@"defaultIcon"]];
    [self.createTimeButton setTitle:[DateUtil messageDetailTimeString:message.addTime formatter:nil] forState:UIControlStateNormal];
    
    //self.messageTextView.text = message.message;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:message.message attributes:@{NSForegroundColorAttributeName:[SportColor highlightTextColor],NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    [attrString addAttributes:@{NSForegroundColorAttributeName:[UIColor hexColor:@"2577ee"]} range:[message.message rangeOfString:HIGHTLIGHT_STRING]];
    self.messageTextView.attributedText = attrString;

    //    [self.messageButton setBackgroundImage:[SportImage commentMessageLeftImage] forState:UIControlStateNormal];
    

}

@end
