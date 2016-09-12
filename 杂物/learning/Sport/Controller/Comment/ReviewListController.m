//
//  ReviewListController.m
//  Sport
//
//  Created by haodong  on 14/11/5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ReviewListController.h"
#import "SportProgressView.h"
#import "UserInfoController.h"
#import "BrowsePhotoView.h"
#import "Review.h"
#import "BusinessPhoto.h"
#import "UIScrollView+SportRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import "SportNetwork.h"

#define CATEGORY_BUTTON_COLOR_UNSELECTED [UIColor hexColor:@"666666"]
#define CATEGORY_BUTTON_COLOR_SELECTED   [UIColor hexColor:@"222222"]

#define CATEGORY_ID_DEFAULT         @"0"
#define CATEGORY_ID_USEFUL          @"1"
#define CATEGORY_ID_HAVE_SIGHT      @"2"
#define CATEGORY_ID_UNIMPROVE       @"3"

#define TAG_RATING_BASE 100

#define HEIGHT_TABLEVIEW_HEADVIEW 45

@interface ReviewListController () <UITableViewDataSource>
{
    NSString *_categoryId;
}
@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) int page;
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *businessId;
@property (assign, nonatomic) double totalRank;
@property (strong, nonatomic) NSArray *categoryArray;
@property (strong, nonatomic) IBOutlet UIView *mainRankView;
@property (weak, nonatomic) IBOutlet UIView *vernierView;
@property (weak, nonatomic) IBOutlet UILabel *mainGradeLabel;
@property (weak, nonatomic) IBOutlet UIButton *mainCategoryButton;
@property (strong, nonatomic) ReviewCell *toolReviewCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIButton *selectedCategoryButton;//lazy
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vernierViewLeadingConstraint;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *categoryButtons;
@property (weak, nonatomic) IBOutlet UIView *networkMaskView;

@end

@implementation ReviewListController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithBusinessId:(NSString *)businessId {
    self = [super init];
    if (self) {
        _businessId = businessId;
    }
    return self;
}

#define PAGE_START          1
#define COUNT_ONE_PAGE      20
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"评论列表";
    self.dataList = [NSMutableArray array];
    self.page = PAGE_START;
    [self queryData];
    self.toolReviewCell = [ReviewCell createCell];
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    [_tableView registerNib:[UINib nibWithNibName:[ReviewCell getCellIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[ReviewCell getCellIdentifier]];
    [self setupSwipeGestureTecognizer];
    [_networkMaskView setHidden:NO];
}

- (void)setCategoryArray:(NSArray *)categoryArray {
    _categoryArray = [categoryArray copy];
    [self configureCategoryBar];
}

- (UIButton *)selectedCategoryButton {
    if (nil == _selectedCategoryButton) {
        _selectedCategoryButton = _mainCategoryButton;
    }
    return _selectedCategoryButton;
}

- (void)configureCategoryBar {
    if (_categoryArray.count != _categoryButtons.count) {
        return;
    }
    for (int i = 0; i < _categoryButtons.count; i ++) {
        UIButton *button = [_categoryButtons objectAtIndex:i];
        NSDictionary *categoryDict = [_categoryArray objectAtIndex:i];
        NSString *title = [categoryDict validStringValueForKey:PARA_TITLE];
        NSString *num = [categoryDict validStringValueForKey:PARA_NUM];
        [button setTitle:[NSString stringWithFormat:@"%@(%@)", title, num] forState:UIControlStateNormal];
    }
}

- (void)updateMainRankView {
    if ([_categoryId isEqualToString:CATEGORY_ID_DEFAULT]) {
        [self updateTabelHeaderViewHeight:HEIGHT_TABLEVIEW_HEADVIEW];
        for (int i = 0 ; i < 5 ; i ++) {
            UIImageView *imageView = (UIImageView *)[self.mainRankView viewWithTag:TAG_RATING_BASE + i];
            if (i < _totalRank) {
                [imageView setImage:[SportImage star1Image]];
            } else {
                [imageView setImage:[SportImage star3Image]];
            }
        }
        _mainGradeLabel.text = [NSString stringWithFormat:@"%.1f分", _totalRank];
    } else {
        //隐藏
        [self updateTabelHeaderViewHeight:0.f];
    }
}

- (void)updateTabelHeaderViewHeight:(CGFloat)height {
    UIView *headerView = _tableView.tableHeaderView;
    [headerView updateHeight:height];
    [_tableView setTableHeaderView:headerView];
    if (0 == height) {
        [headerView setHidden:YES];
    } else {
        [headerView setHidden:NO];
    }
}

- (void)setupSwipeGestureTecognizer {
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:leftSwipeGesture];
    [self.view addGestureRecognizer:rightSwipeGesture];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer {
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            [self swipeToNextCategory];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self swipeToPreviousCategory];
            break;
        default:
            break;
    }
}

- (void)swipeToNextCategory {
    NSInteger currentIndex = [_categoryButtons indexOfObject:self.selectedCategoryButton];
    if (++currentIndex < _categoryButtons.count) {
        [self clickCategoryButton:[_categoryButtons objectAtIndex:currentIndex]];
    }
}

- (void)swipeToPreviousCategory {
    NSInteger currentIndex = [_categoryButtons indexOfObject:self.selectedCategoryButton];
    if (--currentIndex >= 0) {
        [self clickCategoryButton:[_categoryButtons objectAtIndex:currentIndex]];
    }
}

- (void)queryData
{
    [SportProgressView showWithStatus:DDTF(@"kLoading")];
    [BusinessService queryComments:self
                        businessId:_businessId
                            userId:[[UserManager defaultManager] readCurrentUser].userId
                             navId:self.categoryId
                             count:40
                              page:_page];
}

- (void)didQueryComments:(NSArray *)commentList
            categoryList:(NSArray *)categoryList
              totalCount:(int)totalCount
               totalRank:(double)totalRank
                  status:(NSString *)status
                     msg:(NSString *)msg
{
    [SportProgressView dismiss];
    [_networkMaskView removeFromSuperview];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.totalRank = totalRank;
        if (_page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:commentList];
        } else {
            [self.dataList addObjectsFromArray:commentList];
        }
        self.categoryArray = categoryList;
    }
    
    [self updateMainRankView];
    [self.tableView reloadData];
    
    if ([commentList count] < COUNT_ONE_PAGE) {
        [self.tableView canNotLoadMore];
    } else {
        [self.tableView canLoadMore];
    }
    
    [self.tableView endLoad];
    
    //无数据时的提示
    if ([_dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:_tableView.frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
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

- (NSString *)categoryId {
    if (nil == _categoryId) {
        _categoryId = CATEGORY_ID_DEFAULT;
    }
    return _categoryId;
}

- (void)setCategoryId:(NSString *)categoryId {
    _categoryId = [categoryId copy];
    if ([_categoryId isEqualToString:CATEGORY_ID_DEFAULT]) {
        [_tableView setSectionHeaderHeight:CGRectGetHeight(_mainRankView.frame)];
    } else {
        [_tableView setSectionHeaderHeight:0.f];
    }
    [self.tableView beginReload];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    [_tableView setSectionHeaderHeight:CGRectGetHeight(_mainRankView.frame)];
    return _mainRankView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ReviewCell getCellIdentifier];
    ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [ReviewCell createCell];
    }
    
    Review *review = [_dataList objectAtIndex:indexPath.row];
    [cell updateCellWithReview:review
                     index:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [tableView fd_heightForCellWithIdentifier:[ReviewCell getCellIdentifier] configuration:^(ReviewCell *cell) {
        [cell updateCellWithReview:[_dataList objectAtIndex:indexPath.row] index:indexPath.row];
    }];
    return height;
//    Review *review = [_dataList objectAtIndex:indexPath.row];
//    [_toolReviewCell updateCellWithReview:review index:indexPath.row];
//    return [_toolReviewCell heightWithReview:review];
}

- (void)didClickReviewCellAvatarButton:(NSString *)userId
{
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:userId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickReviewCellImageButton:(NSUInteger)row
                            openIndex:(NSUInteger)openIndex
{
    BrowsePhotoView *view = [BrowsePhotoView createBrowsePhotoView];
    
    Review *review = [_dataList objectAtIndex:row];
    
    NSMutableArray *list = [NSMutableArray array];
    
    for (BusinessPhoto *photo in review.photoList) {
        [list addObject:photo.photoImageUrl];
    }
    
    [view showImageList:list openIndex:openIndex];
}

- (IBAction)clickCategoryButton:(UIButton *)sender {
    if (sender == _selectedCategoryButton) {
        return;
    }
    //style
    [self.selectedCategoryButton setTitleColor:CATEGORY_BUTTON_COLOR_UNSELECTED forState:UIControlStateNormal];
    self.selectedCategoryButton = sender;
    [self.selectedCategoryButton setTitleColor:CATEGORY_BUTTON_COLOR_SELECTED forState:UIControlStateNormal];
    
    //local
    _vernierViewLeadingConstraint.constant = CGRectGetMidX(sender.frame) - 0.5 * CGRectGetWidth(_vernierView.frame);
    [UIView animateWithDuration:0.1 animations:^{
        [_vernierView updateCenterX:CGRectGetMidX(sender.frame)];
    }];
    
    //data
    switch (sender.tag) {
        case 10:
            self.categoryId = CATEGORY_ID_DEFAULT;
            break;
        case 11:
            self.categoryId = CATEGORY_ID_USEFUL;
            break;
        case 12:
            self.categoryId = CATEGORY_ID_HAVE_SIGHT;
            break;
        case 13:
            self.categoryId = CATEGORY_ID_UNIMPROVE;
            break;
        default:
            break;
    }
}
@end
