//
//  BusinessGoodsListController.m
//  Sport
//
//  Created by 江彦聪 on 8/12/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import "BusinessGoodsListController.h"
#import "BusinessGoodsListCell.h"
#import "PriceUtil.h"
#import "ZYKeyboardUtil.h"

@interface BusinessGoodsListController ()<BusinessGoodsListCellDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *goodsListTableView;
@property (weak, nonatomic) IBOutlet UILabel *goodsTotalPriceLabel;
@property (strong, nonatomic) NSArray *goodsList;
@property (strong, nonatomic) ZYKeyboardUtil *keyboardUtil;
@end

@implementation BusinessGoodsListController
-(id) initWithGoodsList:(NSArray *)list {
    self = [super init];
    if (self) {
        self.goodsList = list;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"卖品列表";
    // Do any additional setup after loading the view from its nib.
    UINib *cellNib = [UINib nibWithNibName:[BusinessGoodsListCell getCellIdentifier] bundle:nil];
    [self.goodsListTableView registerNib:cellNib forCellReuseIdentifier:[BusinessGoodsListCell getCellIdentifier]];
    
    [self.goodsListTableView reloadData];
    
    [self updateSelectedGoods:nil];
    [self setupKeyboardUtils];
}

- (void)setupKeyboardUtils {
    self.keyboardUtil = [[ZYKeyboardUtil alloc] init];
    __weak typeof(self) weakSelf = self;
    [_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.goodsListTableView, nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.goodsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [BusinessGoodsListCell getCellIdentifier];
    BusinessGoodsListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    [cell updateCellWithGoods:self.goodsList[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BusinessGoodsListCell getCellHeight];
    
}

#pragma mark -BusinessListCellDelegate
- (void) updateSelectedGoods:(BusinessGoods *) goods {
    float totalPrice = 0;
    for (BusinessGoods *oneGoods in self.goodsList) {
        if (goods && [oneGoods.goodsId isEqualToString:goods.goodsId]) {
            oneGoods.totalCount = goods.totalCount;
        }
        
        totalPrice += oneGoods.totalCount*oneGoods.price;
    }
    
    self.goodsTotalPriceLabel.text = [PriceUtil toPriceStringWithYuan:totalPrice];
    
}

- (IBAction)clickConfirmButton:(id)sender {
    
    NSMutableArray *sortGoodsList = [NSMutableArray arrayWithArray:self.goodsList];
    //降序排列
    [sortGoodsList sortUsingComparator:^NSComparisonResult(BusinessGoods *goods1,BusinessGoods* goods2){
        return goods1.totalCount < goods2.totalCount;
    }];
    
    if ([_delegate respondsToSelector:@selector(refreshSelectedGoodsList:)]) {
        [_delegate refreshSelectedGoodsList:sortGoodsList];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
