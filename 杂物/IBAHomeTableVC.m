//
//  IBAHomeTableVC.m
//  IBABoss
//
//  Created by lzy on 16/9/1.
//  Copyright © 2016年 IBA. All rights reserved.
//

#import "IBAHomeTableVC.h"
#import "Masonry.h"
#import "IBAHomeCatContentManager.h"
#import "IBAHomeRecommendPageManager.h"
#import "IBAHomeBrandPageManager.h"
#import "IBAHomeCountryPageManager.h"
#import "IBAGoodsLRCollectionTableViewCell.h"
#import "IBAHomeBannerManager.h"
#import "IBAImageUtil.h"
#import "UIColor+hexColor.h"
#import "MJRefreshAutoGifFooter.h"

NSString * const CAT_ID_INDEX = @"CAT_ID_INDEX";
NSString * const CAT_ID_COUNTRY = @"CAT_ID_COUNTRY";
NSString * const CAT_ID_BRAND = @"CAT_ID_BRAND";
const char kHomeTableViewCellName;

#define INDEX_COLLECTION_PAGE_SIZE 2
#define PAGE_FIRST_PAGE 1 //后台配置从1开始

@interface UITableViewCell ()
- (void)updateCellWithDataDict:(NSDictionary *)dict;
@end

@interface IBAHomeTableVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) NSMutableDictionary *templateCellDict;
@property (strong, nonatomic) IBAHomeCatContentManager *catContentManager;
@property (strong, nonatomic) IBAHomeRecommendPageManager *recommendPageManager;
@property (strong, nonatomic) IBAHomeBrandPageManager *brandPageManager;
@property (strong, nonatomic) IBAHomeCountryPageManager *countryPageManager;
@property (strong, nonatomic) IBAHomeBannerManager *bannerManager;
@property (strong, nonatomic) UIView *loadingPlaceHolderView;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) BOOL haveLoadingData;
@end

@implementation IBAHomeTableVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [_tableView setBackgroundColor:[UIColor hexColor:@"f8f8f8"]];
    [self.view addSubview:_tableView];
    
    self.loadingPlaceHolderView = [[UIView alloc] init];
    UIImageView *placeHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"prod_default_bg"]];
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    [placeHolderLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
    [placeHolderLabel setTextColor:[UIColor hexColor:@"aaaaaa"]];
    [placeHolderLabel setText:@"加载中..."];
    [_loadingPlaceHolderView addSubview:placeHolderImageView];
    [_loadingPlaceHolderView addSubview:placeHolderLabel];
    [self.tableView addSubview:_loadingPlaceHolderView];
    [self.tableView sendSubviewToBack:_loadingPlaceHolderView];
    
    WS(weakSelf);
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    [placeHolderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.loadingPlaceHolderView);
        make.left.equalTo(weakSelf.loadingPlaceHolderView);
        make.right.equalTo(weakSelf.loadingPlaceHolderView);
    }];
    
    [placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(placeHolderImageView.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf.loadingPlaceHolderView);
        make.bottom.equalTo(weakSelf.loadingPlaceHolderView);
    }];
    
    [_loadingPlaceHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.tableView);
        make.centerX.equalTo(weakSelf.tableView);
    }];
}

- (void)setupMJRefresh {
    if (!(_tableView.mj_header || _tableView.mj_footer)) {
        WS(weakSelf);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf loadNewData];
        }];
        if ([weakSelf.catId isEqualToString:CAT_ID_INDEX]) {
            //业务关系，部分页面不设footer
            _tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
                [weakSelf loadMoreData];
            }];
            [((MJRefreshAutoGifFooter *)_tableView.mj_footer) setTitle:@"已无更多数据" forState:MJRefreshStateNoMoreData];
        }
    }
}

- (void)loadNewData {
    //清空数据(在网络回调后清有可能会清掉banner数据)
    self.dataList = [NSArray array];
    //请求首页数据
    self.page = PAGE_FIRST_PAGE;
    [self queryDataWithCatId:_catId];
}

- (void)loadMoreData {
    //请求分页数据
    self.page ++;
    [self queryDataWithCatId:_catId];
}

- (void)hadLoadData {
    self.haveLoadingData = YES;
}

- (void)freshData {
    self.haveLoadingData = NO;
    //释放所有cell
    for (UIView *view in _tableView.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewWrapperView"]) {
            for (UITableViewCell *cell in view.subviews) {
                [cell removeFromSuperview];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryDataWithCatId:(NSString *)catId {
    if ([catId isEqualToString:CAT_ID_INDEX]) {
        //推荐
        [self queryRecommendPageWithPage:_page pageSize:INDEX_COLLECTION_PAGE_SIZE];
    } else if ([catId isEqualToString:CAT_ID_COUNTRY]) {
        //国家馆
        [self queryCountryPage];
    } else if ([catId isEqualToString:CAT_ID_BRAND]) {
        //品牌
        [self queryBrandPage];
    } else {
        //default
        [self queryCategoryPageWithCatId:catId];
    }
}

- (void)queryCategoryPageWithCatId:(NSString *)catId {
    //二级目录页 不设分页
    NSDictionary *reqDict = @{@"navId":catId, @"page":@(1), @"pageSize":@(GOODS_PAGE_COLLECTION_PAGE_SIZE)};
    WS(weakSelf);
    [self.catContentManager reqWithParameter:reqDict succeed:^(NSDictionary *resultDict) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf packageCategoryPageDataListWithResultDict:resultDict];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
                [weakSelf hadLoadData];
            });
        });
        [weakSelf tableViewEndLoad];
    } failed:^{
        [weakSelf showHint:@"请下拉刷新重试"];
        [weakSelf tableViewEndLoad];
    }];
}

- (void)queryRecommendPageWithPage:(NSInteger)page pageSize:(NSInteger)pageSize {
    NSDictionary *reqDict = @{@"page":@(page), @"pageSize":@(pageSize)};
    WS(weakSelf);
    [self.recommendPageManager reqWithParameter:reqDict succeed:^(NSDictionary *resultDict) {
        [weakSelf packageRecommendDataListWithResultDict:resultDict];
        //firstPage ? 同时请求banner图
        if (PAGE_FIRST_PAGE == weakSelf.page) {
            [weakSelf.bannerManager reqWithParameter:@{@"type":@"1"} succeed:^(NSDictionary *resultDict) {
                NSDictionary *bannerDataList = [weakSelf packageBannerDataWithResultDict:resultDict];
                NSMutableArray *mutDataList = [NSMutableArray arrayWithArray:weakSelf.dataList];
                if (bannerDataList.count > 0) {
                    [weakSelf attachCellClassName:@"IBAHomeBannerTableViewCell" dataDict:bannerDataList];
                    [mutDataList insertObject:bannerDataList atIndex:0];
                }
                weakSelf.dataList = [mutDataList copy];
                [weakSelf hadLoadData];
                [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
                [weakSelf tableViewEndLoad];
            } failed:^{
                [weakSelf showHint:@"请下拉刷新重试"];
                [weakSelf tableViewEndLoad];
            }];
        } else {
            [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
        }
//        [weakSelf tableViewEndLoad];
    } failed:^{
        [weakSelf showHint:@"请下拉刷新重试"];
        [weakSelf tableViewEndLoad];
    }];
}

- (void)queryBrandPage {
    WS(weakSelf);
    [self.brandPageManager reqWithParameter:@{} succeed:^(NSDictionary *resultDict) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf packageBrandDataListWithResultDict:resultDict];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hadLoadData];
                [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
            });
        });
        [weakSelf tableViewEndLoad];
    } failed:^{
        [weakSelf showHint:@"请下拉刷新重试"];
        [weakSelf tableViewEndLoad];
    }];
}

- (void)queryCountryPage {
    WS(weakSelf);
    [self.countryPageManager reqWithParameter:@{} succeed:^(NSDictionary *resultDict) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf packageCountryPageDataListWithResultDict:resultDict];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hadLoadData];
                [weakSelf.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
            });
        });
        [weakSelf tableViewEndLoad];
    } failed:^{
        [weakSelf showHint:@"请下拉刷新重试"];
        [weakSelf tableViewEndLoad];
    }];
}

- (void)packageRecommendDataListWithResultDict:(NSDictionary *)resultDict {
    //组装数据
    NSArray *nationList = [resultDict objectForKey:@"nationList"];
    //MJ
    if (nationList.count < INDEX_COLLECTION_PAGE_SIZE) {
//        [self tableViewEndLoad];
        [self canNotLoadMore];
    } else {
        [self tableViewEndLoad];
        [self canLoadMore];
    }
    NSMutableArray *mutDataList = [NSMutableArray arrayWithArray:self.dataList];
    for (NSDictionary *dict in nationList) {
        //处理后台字段名不统一
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSString *navName = [dict objectForKey:@"alias"];
        if (navName) {
            [tmpDict setValue:navName forKey:@"navName"];
        }
        NSDictionary *packageDict = [tmpDict copy];
        //attachCellClassName
        [self attachCellClassName:@"IBAGoodsLRCollectionTableViewCell" dataDict:packageDict];
        [mutDataList addObject:packageDict];
    }
    self.dataList = [mutDataList copy];
}

- (void)packageCountryPageDataListWithResultDict:(NSDictionary *)resultDict {
    NSMutableArray *mutDataList = [NSMutableArray arrayWithArray:self.dataList];
    //添加默认图片cell
    UIImage *countryPageHeaderImage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"countryPageHeaderImage.jpg"]];
    UIImage *countryPageHeaderSubImage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"countryPageHeaderSubImage.png"]];
    UIImage *countryExpectationImage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"national_expectation.png"]];
    NSDictionary *countryPageHeaderImageDict = @{@"image":countryPageHeaderImage};
    NSDictionary *countryPageHeaderSubImageDict = @{@"image":countryPageHeaderSubImage};
    NSDictionary *countryExpectationImageDict = @{@"image":countryExpectationImage};
    [self attachCellClassName:@"IBAHomeBigImageCell" dataDict:countryPageHeaderImageDict];
    [self attachCellClassName:@"IBAHomeBigImageCell" dataDict:countryPageHeaderSubImageDict];
    [self attachCellClassName:@"IBAHomeCountryCollectionTableViewCell" dataDict:resultDict];
    [self attachCellClassName:@"IBAHomeBigImageCell" dataDict:countryExpectationImageDict];
    [mutDataList addObject:countryPageHeaderImageDict];
    [mutDataList addObject:countryPageHeaderSubImageDict];
    [mutDataList addObject:resultDict];
    [mutDataList addObject:countryExpectationImageDict];
    self.dataList = [mutDataList copy];
}

- (void)packageBrandDataListWithResultDict:(NSDictionary *)resultDict {
    NSArray *brandGroupList = [resultDict objectForKey:@"brandList"];
    NSMutableArray *mutDataList = [NSMutableArray arrayWithArray:self.dataList];
    for (NSDictionary *dict in brandGroupList) {
        [self attachCellClassName:@"IBABrandGroupTableViewCell" dataDict:dict];
        [mutDataList addObject:dict];
    }
    self.dataList = [mutDataList copy];
}

- (void)packageCategoryPageDataListWithResultDict:(NSDictionary *)resultDict {
    NSArray *productList = [resultDict objectForKey:@"navProdList"];
    NSMutableArray *mutDataList = [NSMutableArray arrayWithArray:self.dataList];
    for (NSDictionary *dict in productList) {
        //处理后台字段名不统一
        //内层结构抽出navName secondText cataId
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSString *navName = [[dict objectForKey:@"childNav"] objectForKey:@"navName"];
        NSString *subNavName = [[dict objectForKey:@"childNav"] objectForKey:@"secondText"];
        NSString *catID = [[[dict objectForKey:@"childNav"] objectForKey:@"parameters"] objectForKey:@"cataId"];
        if (navName) {
            [tmpDict setValue:navName forKey:@"navName"];
        }
        if (subNavName) {
            [tmpDict setValue:subNavName forKey:@"secondText"];
        }
        if (catID) {
            [tmpDict setValue:catID forKey:@"cataId"];
        }
        //mpromName 2 promName
        NSArray *productList = tmpDict[@"prodList"];
        if (productList) {
            NSMutableArray *tmpProductList = [NSMutableArray array];
            for (NSDictionary *productDict in productList) {
                NSMutableDictionary *tmpProductDict = [NSMutableDictionary dictionaryWithDictionary:productDict];
                NSString *promotionName = productDict[@"mpromName"];
                if (promotionName) {
                    [tmpProductDict setValue:promotionName forKey:@"promName"];
                }
                [tmpProductList addObject:tmpProductDict];
            }
            tmpDict[@"prodList"] = [tmpProductList copy];
        }
        NSDictionary *packageDict = [tmpDict copy];
        //attachCellClassName
        [self attachCellClassName:@"IBAGoodsLRCollectionTableViewCell" dataDict:packageDict];
        [mutDataList addObject:packageDict];
    }
    //末尾最佳noMoreCell
    UIImage *noMoreDataImage = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"goods_list_noMore_data.png"]];
    NSDictionary *noMoreDataImageDict = @{@"image":noMoreDataImage};
    [self attachCellClassName:@"IBAHomeBigImageCell" dataDict:noMoreDataImageDict];
    [mutDataList addObject:noMoreDataImageDict];
    self.dataList = [mutDataList copy];
}

- (NSDictionary *)packageBannerDataWithResultDict:(NSDictionary *)resultDict {
    NSArray *bannerArray = [resultDict objectForKey:@"bannerList"];
    NSMutableArray *imageUrlArray = [NSMutableArray array];
    for (NSDictionary *dict in bannerArray) {
        NSString *picUrlString = [IBAImageUtil ibaImageByUrl:[dict objectForKey:@"pic"]];
        NSString *skipUrlString = [dict objectForKey:@"redirectUrl"];
        [imageUrlArray addObject:@{@"imageUrl":picUrlString, @"redirectUrl":skipUrlString}];
    }
    return @{@"bannerArray":imageUrlArray};
}

- (void)attachCellClassName:(NSString *)className dataDict:(NSDictionary *)dataDict {
    objc_setAssociatedObject(dataDict, &kHomeTableViewCellName, className, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)analysisCellClassNameWithDataDict:(NSDictionary *)dataDict {
    return objc_getAssociatedObject(dataDict, &kHomeTableViewCellName);
}

- (void)scrollToTop {
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (void)tableViewEndLoad {
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}

- (void)canNotLoadMore {
    [_tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)canLoadMore {
    _tableView.mj_footer.hidden = NO;
    [_tableView.mj_footer resetNoMoreData];
}

#pragma mark - Delegate DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDict = [_dataList objectAtIndex:indexPath.row];
    Class clazz = NSClassFromString([self analysisCellClassNameWithDataDict:dataDict]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[clazz getCellIdentifier]];
    if (nil == cell) {
        cell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[clazz getCellIdentifier]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if ([cell respondsToSelector:@selector(updateCellWithDataDict:)]) {
        [cell updateCellWithDataDict:dataDict];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSDictionary *dataDict = [_dataList objectAtIndex:indexPath.row];
        Class clazz = NSClassFromString([self analysisCellClassNameWithDataDict:dataDict]);
        UITableViewCell *cell = [self.templateCellDict objectForKey:[clazz getCellIdentifier]];
        if (nil == cell) {
            cell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[clazz getCellIdentifier]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [self.templateCellDict setObject:cell forKey:[clazz getCellIdentifier]];
        }
        if ([cell respondsToSelector:@selector(updateCellWithDataDict:)]) {
            [cell updateCellWithDataDict:dataDict];
        }
        NSLayoutConstraint *calculateCellConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:Screen_Width];
        [cell.contentView addConstraint:calculateCellConstraint];
        CGSize cellSize = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [cell.contentView removeConstraint:calculateCellConstraint];
        return cellSize.height;
    }
}

#pragma mark - Get Set
- (void)setCatId:(NSString *)catId {
    _catId = [catId copy];
    if (!_haveLoadingData) {//缓存
        [self loadNewData];
    }
    //MJ
    [self setupMJRefresh];
}

- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = [NSArray array];
    }
    return _dataList;
}

- (IBAHomeCatContentManager *)catContentManager {
    if (!_catContentManager) {
        _catContentManager = [[IBAHomeCatContentManager alloc] init];
    }
    return _catContentManager;
}

- (IBAHomeRecommendPageManager *)recommendPageManager {
    if (!_recommendPageManager) {
        _recommendPageManager = [[IBAHomeRecommendPageManager alloc] init];
    }
    return _recommendPageManager;
}

- (IBAHomeBrandPageManager *)brandPageManager {
    if (!_brandPageManager) {
        _brandPageManager = [[IBAHomeBrandPageManager alloc] init];
    }
    return _brandPageManager;
}

- (IBAHomeCountryPageManager *)countryPageManager {
    if (!_countryPageManager) {
        _countryPageManager = [[IBAHomeCountryPageManager alloc] init];
    }
    return _countryPageManager;
}

- (IBAHomeBannerManager *)bannerManager {
    if (!_bannerManager) {
        _bannerManager = [[IBAHomeBannerManager alloc] init];
    }
    return _bannerManager;
}

- (NSMutableDictionary *)templateCellDict {
    if (!_templateCellDict) {
        _templateCellDict = [NSMutableDictionary dictionary];
    }
    return _templateCellDict;
}

@end
