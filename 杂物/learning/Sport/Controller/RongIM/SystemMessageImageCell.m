//
//  SystemMessageImageCell.m
//  Sport
//
//  Created by 江彦聪 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "SystemMessageImageCell.h"
#import "DateUtil.h"
#import "UIImageView+WebCache.h"

@interface SystemMessageImageCell()

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) SystemMessage *message;
@property (weak, nonatomic) IBOutlet UIButton *createTimeButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
/** 跳转URL */
@property(nonatomic, strong) NSString *url;
@end
@implementation SystemMessageImageCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundImageView.layer.borderColor = [[SportColor defaultButtonInactiveColor] CGColor];
    self.backgroundImageView.layer.borderWidth = 0.5f;
    self.backgroundImageView.layer.cornerRadius = 3.0f;
    self.backgroundImageView.layer.masksToBounds = YES;
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.detailImageView.layer.masksToBounds = YES;
    
    [self.createTimeButton setBackgroundImage:[SportImage systemMessageTimeBackground] forState:UIControlStateNormal];
    self.createTimeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString*)getCellIdentifier
{
    return @"SystemMessageImageCell";
}

- (IBAction)clickOpenDetailLinkButton:(id)sender {
    [MobClickUtils event:umeng_event_click_msg_act_list label:@"图文消息"];
    if (self.message.webUrl && [_delegate respondsToSelector:@selector(pushWebViewWithUrl:title:)]) {
        [_delegate pushWebViewWithUrl:self.message.webUrl title:@""];
    }
}

- (void)updateCell:(SystemMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast {
    self.indexPath = indexPath;
    self.message = message;
    
    [self.detailImageView sd_setImageWithURL:[NSURL URLWithString:message.imageUrl] placeholderImage:[SportImage bannerPlaceholderImage]];

    [self.createTimeButton setTitle:[DateUtil messageDetailTimeString:message.addTime formatter:nil] forState:UIControlStateNormal];
    self.dateLabel.text = message.activityTimeString;
    self.titleLable.text = message.title;
    self.contentLabel.text = message.message;
    
}


@end
