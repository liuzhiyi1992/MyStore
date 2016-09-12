//
//  DrawRecordController.m
//  Sport
//
//  Created by haodong  on 14/11/21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DrawRecordController.h"
#import "DrawRecord.h"
#import "User.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "ConvertPointGoodsController.h"
#import "PointGoods.h"
#import "UIView+Utils.h"
#import "UIScrollView+SportRefresh.h"

@interface DrawRecordController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) int page;
@property (assign, nonatomic) int count;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DrawRecordController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define COUNT_ONE_PAGE  20
#define PAGE_START      1
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"中奖记录";
    
    [self.tableView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - 40];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    self.myPointLabel.text = [NSString stringWithFormat:@"%d", user.point];
    
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.page = PAGE_START;
    [self queryData];
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [PointService queryDrawRecordList:self
                               userId:user.userId
                                 page:_page
                                count:COUNT_ONE_PAGE];
}

- (void)didQueryDrawRecordList:(NSArray *)list status:(NSString *)status msg:(NSString *)msg
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if ([self.dataList count] == 0 || _page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:list];
        } else {
            [self.dataList addObjectsFromArray:list];
        }
    }
    
    [self.tableView reloadData];
    
    if ([list count] < COUNT_ONE_PAGE) {
        [self.tableView canNotLoadMore];
    } else {
        [self.tableView canLoadMore];
    }
    [self.tableView endLoad];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [DrawRecordCell getCellIdentifier];
    DrawRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [DrawRecordCell createCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    DrawRecord *record = [_dataList objectAtIndex:indexPath.row];
    
    [cell updateCellWithDrawRecord:record indexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DrawRecordCell getCellHeight];
}

- (void)loadNewData
{
    self.page = PAGE_START;
    [self queryData];
}

- (void)loadMoreData
{
    self.page ++;
    [self queryData];
}

- (void)didCLickDrawRecordCellConvertButton:(NSIndexPath *)indexPath
{
    DrawRecord *record = [_dataList objectAtIndex:indexPath.row];
    
    PointGoods *goods = [[PointGoods alloc] init] ;
    goods.goodsId = record.giftId;
    goods.title = record.desc;
    
    ConvertPointGoodsController *controller = [[ConvertPointGoodsController alloc] initWithPointGoods:goods drawId:record.convertId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
