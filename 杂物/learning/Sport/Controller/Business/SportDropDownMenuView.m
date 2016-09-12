//
//  SportDropDownMenuView.m
//  test
//
//  Created by 冯俊霖 on 15/9/23.
//  Copyright © 2015年 冯俊霖. All rights reserved.
//

#import "SportDropDownMenuView.h"
#import "SportFilterCell.h"
#import "SportDropDownLeftCell.h"


@interface  SportDropDownMenuView()

@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) UIView *backGroundView;

@property(nonatomic, strong) UILabel *selectLabel;

@property (strong, nonatomic) NSArray *leftDataList;
@property (strong, nonatomic) NSArray *rightDataList;

@property (strong, nonatomic) NSString *selectedCategoryId;
@property (strong, nonatomic) NSString *selectedRegionId;
@property (strong, nonatomic) NSString *selectedFilterId;
@property (strong, nonatomic) NSString *selectedSortId;

@end

#define ScreenWidth      [UIScreen mainScreen].bounds.size.width

@implementation SportDropDownMenuView

- (instancetype)initWithOrigin:(CGPoint)origin
                        height:(CGFloat)height
                    categoryId:(NSString *)categoryId
                      regionId:(NSString *)regionId
                      filterId:(NSString *)filterId
                        sortId:(NSString *)sortId
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, 0)];
    if (self) {
        _origin = origin;
        _show = NO;
        _height = height;
        
        self.selectedCategoryId = categoryId;
        self.selectedRegionId = regionId;
        self.selectedFilterId = filterId;
        self.selectedSortId = sortId;
        
        //tableView init
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, ScreenWidth * 0.3, 0) style:UITableViewStylePlain];
        _leftTableView.rowHeight = 45;
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.backgroundColor = [SportColor hexf6f6f9Color];
        
        
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x + ScreenWidth *0.3, self.frame.origin.y + self.frame.size.height, ScreenWidth * 0.7, 0) style:UITableViewStylePlain];
        _rightTableView.rowHeight = 45;
        _rightTableView.dataSource = self;
        _rightTableView.delegate = self;
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        //self tapped
        self.backgroundColor = [UIColor whiteColor];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, screenSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        [self reloadAllData];
    }
    return self;
}

#pragma mark - gesture handle
- (void)menuTapped{
    if (!_show) {
        [self reloadAllData];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.leftTableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    [self animateBackGroundView:self.backGroundView show:!_show complete:^{
        [self animateTableViewShow:!_show complete:^{
            [self tableView:self.leftTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            _show = !_show;
        }];
    }];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender{
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateTableViewShow:NO complete:^{
            _show = NO;
        }];
    }];
}


#pragma mark - animation method
- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTableViewShow:(BOOL)show complete:(void(^)())complete {
    if (show) {
        _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y, ScreenWidth * 0.3, 0);
        [self.superview addSubview:_leftTableView];
        _rightTableView.frame = CGRectMake(self.origin.x + ScreenWidth * 0.3, self.frame.origin.y, ScreenWidth * 0.7, 0);
        [self.superview addSubview:_rightTableView];
        
        _leftTableView.alpha = 1.f;
        _rightTableView.alpha = 1.f;
        [UIView animateWithDuration:0.2 animations:^{
            _leftTableView.frame = CGRectMake(self.origin.x, self.frame.origin.y, ScreenWidth * 0.3, _height);
            _rightTableView.frame = CGRectMake(self.origin.x + ScreenWidth * 0.3, self.frame.origin.y, ScreenWidth * 0.7, _height);
            if (self.transformView) {
                self.transformView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        } completion:^(BOOL finished) {
            
        }];
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            _leftTableView.alpha = 0.f;
            _rightTableView.alpha = 0.f;
            if (self.transformView) {
                self.transformView.transform = CGAffineTransformMakeRotation(0);
            }
        } completion:^(BOOL finished) {
            [_leftTableView removeFromSuperview];
            [_rightTableView removeFromSuperview];
        }];
    }
    complete();
}

#pragma mark - 刷新数据
- (void)reloadAllData {
    DropDownDataManager *m = [DropDownDataManager defaultManager];

    NSArray *dataList = [m leftAndRightDataListWithCategoryId:self.selectedCategoryId];
    if ([dataList count] < 2) {
        HDLog(@"SportDropDownMenuView:dataList error!");
        return;
    }
    
    self.leftDataList = dataList[0];
    self.rightDataList = dataList[1];
    
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
}

#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableView) {
        return self.leftDataList.count;
    }else{
        NSInteger leftRow = self.leftTableView.indexPathForSelectedRow.row;
        NSArray *list = [self.rightDataList objectAtIndex:leftRow];
        return list.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leftTableView) {        
        NSString *identifier = [SportDropDownLeftCell getCellIdentifier];
        SportDropDownLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [SportDropDownLeftCell createCell];
        }
        NSString *title = self.leftDataList[indexPath.row];
        [cell updateCellWithTitle:title];
        return cell;

    } else{
        NSInteger leftRow = self.leftTableView.indexPathForSelectedRow.row;
        NSString *leftTitle = @"";
        if (leftRow < self.leftDataList.count) {
            
             leftTitle = self.leftDataList[leftRow];
        }
        
        NSString *identifier = [SportFilterCell getCellIdentifier];
        SportFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            BOOL hasImage = (leftRow == 0);
            cell = [SportFilterCell createCellWithHasImage:hasImage];
        }
        
        DropDownData *data = self.rightDataList[leftRow][indexPath.row];
        
        BOOL isSelected = NO;
        
        if ([leftTitle isEqualToString:LEFT_TITLE_CATEGORY]) {
            isSelected = [data.idString isEqualToString:self.selectedCategoryId];
        } else if ([leftTitle isEqualToString:LEFT_TITLE_REGION]) {
            isSelected = [data.idString isEqualToString:self.selectedRegionId];
        } else if ([leftTitle isEqualToString:LEFT_TITLE_FILTRATE]) {
            isSelected = [data.idString isEqualToString:self.selectedFilterId];
        } else if ([leftTitle isEqualToString:LEFT_TITLE_SORT]) {
            isSelected = [data.idString isEqualToString:self.selectedSortId];
        }
        
        [cell updateCellWithImageUrl:data.iconUrl content:data.value isSelected:isSelected];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.leftTableView){
        
        [self.rightTableView reloadData];
        
        SportDropDownLeftCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.selectLabel.textColor = [SportColor hex6TextColor];
        cell.titleLabel.textColor = [SportColor highlightTextColor];
        self.selectLabel = cell.titleLabel;
    }else{
        [self animateBackGroundView:_backGroundView show:NO complete:^{
            [self animateTableViewShow:NO complete:^{
                _show = NO;
            }];
        }];
        
        NSInteger leftRow = self.leftTableView.indexPathForSelectedRow.row;
        NSString *leftTitle = @"";
        if (leftRow < self.leftDataList.count) {
            
            leftTitle = self.leftDataList[leftRow];
        }
        
        NSInteger rightRow = indexPath.row;
        DropDownData *data = self.rightDataList[leftRow][rightRow];
        if ([leftTitle isEqualToString:LEFT_TITLE_CATEGORY]) {
            self.selectedCategoryId = data.idString;
            
            //如果项目是不支持显示室内室外筛选的，则筛选置为默认
            if (![DropDownDataManager isShowIndoorOutdoorWithCategoryId:self.selectedCategoryId]) {
                self.selectedFilterId = FILTRATE_ID_ALL;
            }

        } else if ([leftTitle isEqualToString:LEFT_TITLE_REGION]) {
            self.selectedRegionId = data.idString;
        } else if ([leftTitle isEqualToString:LEFT_TITLE_FILTRATE]) {
            self.selectedFilterId = data.idString;
        } else if ([leftTitle isEqualToString:LEFT_TITLE_SORT]) {
            self.selectedSortId = data.idString;
        }
        
        if ([self.delegate respondsToSelector:@selector(didSelectedSportDropDownMenuViewWithCategoryId:regionId:filterId:sortId:)]) {
            [self.delegate didSelectedSportDropDownMenuViewWithCategoryId:self.selectedCategoryId
                                                                 regionId:self.selectedRegionId
                                                                 filterId:self.selectedFilterId
                                                                   sortId:self.selectedSortId];
        }
    }
}

@end
