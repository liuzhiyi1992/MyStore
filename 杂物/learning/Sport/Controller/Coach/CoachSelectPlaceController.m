//
//  CoachSelectPlaceController.m
//  Sport
//
//  Created by 江彦聪 on 15/7/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachSelectPlaceController.h"
#import "SportPopupView.h"
#import "CoachOrderSectionHeaderView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CoachOftenArea.h"

@interface CoachSelectPlaceController ()

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) int selectedAddressIndex;
@property (strong, nonatomic) NSMutableArray *dataList;  //默认第一个值为手动填写地址
@property (strong, nonatomic) NSArray *oftenAddressList;
@property (strong, nonatomic) NSArray *serviceAreaList;
@property (assign, nonatomic) BOOL isHasServiceArea;


@end

@implementation CoachSelectPlaceController

-(NSMutableArray *)dataList
{
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    
    return _dataList;
}

-(id)initWithSelectedAddressIndex:(int)index
                 serviceArea:(NSArray *)serviceAreaList
                    dataList:(NSMutableArray *)dataList
                    delegate:(id)delegate
{
    self = [super init];
    if (self) {
        self.selectedAddressIndex = index;
        self.dataList = dataList;
        self.serviceAreaList = serviceAreaList;
        
        if ([self.serviceAreaList count] > 0) {
            //为了标示是否设置服务区域
            self.isHasServiceArea = YES;
        } else {
            self.isHasServiceArea = NO;
        }
        
        self.oftenAddressList = [dataList subarrayWithRange:NSMakeRange(1, [self.dataList count]-1)];
        self.delegate = delegate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.title = @"请选择约练地址";
    UINib *cellNib = [UINib nibWithNibName:[CoachOrderAddressCell getCellIdentifier] bundle:nil];
    [self.dataTableView registerNib:cellNib forCellReuseIdentifier:[CoachOrderAddressCell getCellIdentifier]];
    
    //重用headerView
    [self.dataTableView registerNib:[UINib nibWithNibName:[CoachOrderSectionHeaderView getCellIdentifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[CoachOrderSectionHeaderView getCellIdentifier]];

    [self.dataTableView reloadData];
}

#pragma mark-- tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return  _isHasServiceArea?1:0;
    } else {
        return [_oftenAddressList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CoachOrderAddressCell getCellIdentifier];
    CoachOrderAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 45;
    } else {
        return 65;
    }
    //return [CoachOrderAddressCell getCellHeight];
//    return [tableView fd_heightForCellWithIdentifier:[CoachOrderAddressCell getCellIdentifier] configuration:^(CoachOrderAddressCell *cell) {
//        [self configureCell:cell atIndexPath:indexPath];
//    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section == 0 && !_isHasServiceArea) ||
        (section == 1 && [self.oftenAddressList count] == 0)) {
        return 0;
    }
    
    if (section == 0) {
        return 44;
    } else {
        return 52;
    }
    
//    CoachOrderSectionHeaderView *header=[tableView dequeueReusableHeaderFooterViewWithIdentifier:[CoachOrderSectionHeaderView getCellIdentifier]];
//    return header.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CoachOrderSectionHeaderView *header=[tableView dequeueReusableHeaderFooterViewWithIdentifier:[CoachOrderSectionHeaderView getCellIdentifier]];
    
    if (section == 0) {
        header.titleLabel.text = @"我来指定地址：";
    } else {
        header.titleLabel.text=@"选择TA常驻场馆：";
    }
        
    return header;
}

- (void)configureCell:(CoachOrderAddressCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLast;
    BOOL isSelected = YES;
    if (indexPath.section == 0) {
        isLast = NO;
        CoachOftenArea *title = nil;
        
        if (self.selectedAddressIndex == 0) {
            isSelected = YES;
            title = self.dataList[0];
        }else {
            isSelected = NO;
        }
        
        //存入上门服务的区域
        cell.serviceAreaList = self.serviceAreaList;
        [cell updateCellWithTitle:title isSelected:isSelected indexPath:indexPath isLast:isLast];

    } else {
        isLast = (indexPath.row == [self.oftenAddressList count] - 1);
        
        CoachOftenArea *area = [self.oftenAddressList objectAtIndex:indexPath.row];
        isSelected = (self.selectedAddressIndex == indexPath.row+1);
        [cell updateCellWithTitle:area isSelected:isSelected indexPath:indexPath isLast:isLast];
    }
}

-(void)didClickCellWithIndex:(NSIndexPath *)indexPath
                     address:(NSString *)address
                       isPop:(BOOL)isPop
{
    if (indexPath.section == 0) {
        self.selectedAddressIndex = (int)indexPath.row;
        CoachOftenArea *area = [[CoachOftenArea alloc]init];
        area.businessName = address;
        self.dataList[0] = area;
        self.dataTableView.scrollEnabled = YES;
    }else {
        
        //若选择常驻场馆，就将第一行的TextField释放
        [self.view.window endEditing:YES];
        
        if (indexPath.row >= [self.oftenAddressList count]) {
            return;
        }
        
        self.selectedAddressIndex = (int)indexPath.row+1;
    }
    
    if ([_delegate respondsToSelector:@selector(didFinishAddressSelection:)]) {
        
        [_delegate didFinishAddressSelection:self.selectedAddressIndex];
    }
    
    if (isPop) {
        [self popBackButton];
    } else {
        [self.dataTableView reloadData];
    }
}

-(void)refreshSelectionWithAddress {
    self.selectedAddressIndex = 0;
    NSMutableArray *array = [NSMutableArray array];
    for (int row = 0;row < [_oftenAddressList count];row++) {
        [array addObject:[NSIndexPath indexPathForRow:row inSection:1]];
    }
    
    [self.dataTableView reloadRowsAtIndexPaths:array withRowAnimation:NO];
    self.dataTableView.scrollEnabled = NO;
}

-(void)clickBackButton:(id)sender
{
    [self popBackButton];
}

-(void)popBackButton {
    
//    if ([_delegate respondsToSelector:@selector(didFinishAddressSelection:selectedIndex:)]) {
//        
//        [_delegate didFinishAddressSelection:self.dataList[0] selectedIndex:self.selectedAddressIndex];
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_CANCEL_COACH_ADDRESS_INPUT object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
