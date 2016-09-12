//
//  AboutController.m
//  Sport
//
//  Created by haodong  on 13-8-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "AboutController.h"
#import "UIView+Utils.h"
#import "SportCommonCell.h"
#import "BootPageView.h"
#import "UIUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "ShareView.h"
#import "BaseConfigManager.h"
#import "SportWebController.h"
#import "UICopyLabel.h"

@interface AboutController ()
@property (weak, nonatomic) IBOutlet UIView *tableViewHeadView;
@property (weak, nonatomic) IBOutlet UIView *tableViewFootView;
@property (strong, nonatomic) NSArray *dataList;
@end

#define TITLE_SHARE             @"分享趣运动"
#define TITLE_GIVE_PRAISE       @"打分鼓励"
#define TITLE_BOOT_PAGE         @"欢迎页"
#define TITLE_GROUP_BUY         @"企业礼品采购"

@implementation AboutController


- (void)viewDidUnload {
    [self setBusinessCooperationLabel:nil];
    [self setVersionLabel:nil];
    [self setWebsiteLabel:nil];
    [super viewDidUnload];
}

- (NSDate *)getDateWithString:(NSString *)date
                   DateFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatString];
    
    NSDate *date_ = [dateFormat dateFromString:date];
    
    //[dateFormat release];
    return date_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getDateWithString:@"2013-03-30" DateFormat:@"yyyy-MM-dd"];
    
    self.title = @"关于趣运动";
    
    NSString *currentVersion = [UIUtils getAppVersion];
    self.versionLabel.text = [NSString stringWithFormat:@"%@", currentVersion];
    
    self.websiteLabel.text = [ConfigData website];
    
    self.businessCooperationLabel.text = [ConfigData  businessCooperation];

    //ios7才有
    //[self setNeedsStatusBarAppearanceUpdate];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
        [mutableArray addObject:[NSArray arrayWithObjects:TITLE_SHARE, TITLE_GIVE_PRAISE,TITLE_BOOT_PAGE, TITLE_GROUP_BUY , nil]];
    } else {
        [mutableArray addObject:[NSArray arrayWithObjects:TITLE_SHARE, TITLE_GIVE_PRAISE, TITLE_GROUP_BUY , nil]];
    }
    
    self.dataList = mutableArray;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = [_dataList objectAtIndex:section];
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [SportCommonCell getCellIdentifier];
    SportCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [SportCommonCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *cellTitle = [list objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [list count] - 1 ? YES : NO);
    
    [cell updateCell:cellTitle indexPath:indexPath isLast:isLast tipsCount:0 isShowRedPoint:NO];
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SportCommonCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *cellTitle = [list objectAtIndex:indexPath.row];
    
    if ([cellTitle isEqualToString:TITLE_GIVE_PRAISE]) {
        [self givePraise];
    } else if ([cellTitle isEqualToString:TITLE_BOOT_PAGE]) {
        [self showBootPage];
    } else if ([cellTitle isEqualToString:TITLE_SHARE]) {
        [self showShare];
    } else if ([cellTitle isEqualToString:TITLE_GROUP_BUY]) {
        [self showGroupBuy];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)givePraise
{
    [UIUtils gotoReview:APP_ID];
}

- (void)showBootPage
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
    {
        BootPageView *view  = [BootPageView createBootPageView];
        [view show];
    }
}

- (void)showShare
{
    ShareContent *shareContent = [[ShareContent alloc] init];
    shareContent.thumbImage = [UIImage imageNamed:@"defaultIcon"];
    shareContent.title = @"推荐一个预订运动场地的应用";
    shareContent.subTitle = @"趣运动手机客户端，数百间优质球馆在线查询预订，低至1折免预约订场，赶紧来试试吧！";
    shareContent.image = nil;
    shareContent.content = [ConfigData shareAppText];
    shareContent.linkUrl = @"http://m.quyundong.com";
    
    [ShareView popUpViewWithContent:shareContent channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatTimeline), @(ShareChannelWeChatSession), @(ShareChannelSina), @(ShareChannelSMS), nil] viewController:self delegate:nil];
}


- (void)showGroupBuy
{
    NSString *url = [[BaseConfigManager defaultManager] groupBuyUrl];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:url title:TITLE_GROUP_BUY] ;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
