//
//  BusinessPhotoBrowser.m
//  Sport
//
//  Created by 江彦聪 on 15/5/20.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "BusinessPhotoBrowser.h"
#import "Business.h"
#import "BusinessPhoto.h"
#import "SportPhotoCaptionView.h"
#import "SportProgressView.h"
#import "BusinessDetailIntroduceView.h"
#import "Facility.h"
#import "UIView+Utils.h"

@interface BusinessPhotoBrowser ()<BusinessDetailIntroduceViewDelegate>
@property (assign, nonatomic) int startPage;
@property (assign, nonatomic) NSUInteger relativeIndex;
@property (assign, nonatomic) NSUInteger previousIndex;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *selectedCategoryId;
@property (assign, nonatomic) BOOL canLoadMore;
@property (assign, nonatomic) BOOL isLoading;

@property (strong,nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) Business *business;
@property (strong, nonatomic) NSArray *photoCategoryList;
@property (assign, nonatomic) CGRect pagingScrollViewFrame;
@property (strong, nonatomic) UIView *introduceCategoryHolderView;

@property (assign, nonatomic) NSUInteger indexForUse;

@end

@implementation BusinessPhotoBrowser

#define PRE_LOAD_PAGE 3
#define COUNT_ONE_PAGE  20
#define PAGE_START      1

-(NSMutableArray *)dataList
{
    if (_dataList == nil) {
        _dataList = [[NSMutableArray alloc]init];
    }
    
    return _dataList;
}

-(id)initWithOpenIndex:(NSUInteger)index
            businessId:(NSString *)businessId
            categoryId:(NSString *)categoryId
            totalCount:(NSUInteger)totalCount
              business:(Business *)business
{
    self = [super initMWPhotoBrowserWithDelegate:self];
    if (self) {
        self.businessId = businessId;
        
        self.startPage = 1;
//        if (index > COUNT_ONE_PAGE) {
//            self.startPage = (int)(index / COUNT_ONE_PAGE + 1);
//            index -= ((index / COUNT_ONE_PAGE)* COUNT_ONE_PAGE);
//        }
        self.relativeIndex = index;
        self.previousIndex = self.relativeIndex;
        self.totalNumber = totalCount;
        
        self.selectedCategoryId = categoryId;
        
        self.business = business;        
        //一张图片的时候默认隐藏
        if (totalCount > 1) {
            self.alwaysShowControls = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Setup introduceCategoryHolderView
    CGFloat introduceCategoryHolderViewHeight = [UIScreen mainScreen].bounds.size.height - _pagingScrollViewFrame.size.height;
    
    _introduceCategoryHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, _pagingScrollViewFrame.size.height, [UIScreen mainScreen].bounds.size.width, introduceCategoryHolderViewHeight)];
    _introduceCategoryHolderView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.1];
    [self.view addSubview:_introduceCategoryHolderView];
    // Do any additional setup after loading the view.
    
//    [self queryDataWithPage:self.startPage];
    self.indexForUse = 0;
    
    [self queryData];
}

#define firstBusinessDetailIntroduceViewOriginX   30
- (void)initIntroduceCategoryHolderView {
    
    for(UIView *subView in self.introduceCategoryHolderView.subviews){
        if([subView isKindOfClass:[BusinessDetailIntroduceView class]]){
            [subView removeFromSuperview];
        }
    }
    
    int index = 0;
    CGFloat space = 2;
    
    for ( GalleryCategory * galleryCategory in self.photoCategoryList) {
            
        CGFloat businessDetailIntroduceViewWidth = ([UIScreen mainScreen].bounds.size.width - firstBusinessDetailIntroduceViewOriginX * 2) / ([self.photoCategoryList count]) - space;
        
        BusinessDetailIntroduceView *businessDetailIntroduceView = [BusinessDetailIntroduceView createBusinessDetailIntroduceViewWithHoldViewWidth:businessDetailIntroduceViewWidth];
        [businessDetailIntroduceView updateWidth:businessDetailIntroduceViewWidth];
        businessDetailIntroduceView.delegate = self;
    
        if (index ==0) {
            [businessDetailIntroduceView updateView:galleryCategory isSelected:YES index:index];
            [businessDetailIntroduceView updateOriginX:firstBusinessDetailIntroduceViewOriginX + index * ( space + businessDetailIntroduceView.frame.size.width)];
        }else {
            [businessDetailIntroduceView updateView:galleryCategory isSelected:NO index:index];
               [businessDetailIntroduceView updateOriginX: space + firstBusinessDetailIntroduceViewOriginX + index * ( space + businessDetailIntroduceView.frame.size.width)];
        }
            
        [self.introduceCategoryHolderView addSubview:businessDetailIntroduceView];
        
        index ++;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryData {
    
    [SportProgressView showWithStatus:@"加载中"];
    self.isLoading = YES;
    [BusinessService getBusinesseAllPhoto:self
                              businessId:_businessId
                              categoryId:_selectedCategoryId];
}

- (void)didGetBusinesseAllPhoto:(NSArray *)list
              photoCategoryList:(NSArray *)photoCategoryList
                         status:(NSString *)status
                            msg:(NSString *)msg
{
    [SportProgressView dismiss];
    self.isLoading = NO;
    if ([status isEqualToString:STATUS_SUCCESS]) {
        NSMutableArray *tempMwPhotoList = [NSMutableArray array];
        for (BusinessPhoto *photo in list) {
            SportMWPhoto *mwPhoto = [SportMWPhoto photoWithURL:[NSURL URLWithString:photo.photoImageUrl]];
            mwPhoto.caption = photo.imageDescription;
            mwPhoto.title = photo.imageTitle;
            mwPhoto.index = photo.photoIndex;
            [tempMwPhotoList addObject:mwPhoto];
        }
        
        SportMWPhoto *lastPhoto = [self.photoList lastObject];
        SportMWPhoto *firstPhoto =[self.photoList firstObject];
        SportMWPhoto *lastNewPhoto = [tempMwPhotoList lastObject];
        SportMWPhoto *firstNewPhoto =[tempMwPhotoList firstObject];
        
        self.relativeIndex = self.previousIndex;
        
        if (self.photoList == nil) {
            self.photoList = [NSMutableArray arrayWithArray:tempMwPhotoList];
        } else if(lastPhoto.index < firstNewPhoto.index) {
            [self.photoList addObjectsFromArray:tempMwPhotoList];
            
        } else if(firstPhoto.index > lastNewPhoto.index) {
            [tempMwPhotoList addObjectsFromArray:self.photoList];
            self.photoList = tempMwPhotoList;
            
            self.relativeIndex = self.previousIndex + COUNT_ONE_PAGE;
        }
        else {
            HDLog(@"data no change, index = %lu",(unsigned long)self.relativeIndex);
            
            // data no change, return here
            return;
        }
        
        [self reloadData];
        
        if (self.relativeIndex < [self.photoList count]) {
            [self checkLoadMorePageWithIndex:self.relativeIndex];
            [self setCurrentPhotoIndex:self.relativeIndex];
        }
    }    
    self.photoCategoryList = photoCategoryList;

    [self initIntroduceCategoryHolderView];
    
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index
{
    if (index >= [self.photoList count]) {
        return nil;
    }
    
    SportMWPhoto *photo = [self.photoList objectAtIndex:index];
    if (photo) {
        SportPhotoCaptionView *view = [[SportPhotoCaptionView alloc]initWithPhoto:photo currentIndex:photo.index totalPage:self.totalNumber];
        
        return view;
    }
    else {
        return nil;
    }
}

-(void) checkLoadMorePageWithIndex:(NSUInteger) referIndex
{
    int currentPage;
    int willLoadPage;
    BOOL canLoadMore = NO;
    SportMWPhoto *photo = [self.photoList objectAtIndex:referIndex];
    currentPage = photo.index/COUNT_ONE_PAGE + 1;
    
    if (self.isLoading == YES) {
        return;
    }
    
    if (referIndex >= self.previousIndex &&
        referIndex > [self.photoList count] - PRE_LOAD_PAGE) {
        
        if (currentPage < (self.totalNumber/COUNT_ONE_PAGE) + 1) {
            willLoadPage = currentPage + 1;
            canLoadMore = YES;
        }
        
    } else if (referIndex <= self.previousIndex &&
               referIndex < PRE_LOAD_PAGE &&
               currentPage > 1) {
        
        if (currentPage > 1) {
            willLoadPage = currentPage - 1;
            canLoadMore = YES;
        }
        
    }
    
    if (canLoadMore == YES &&
        _isLoading == NO &&
        [self.photoList count] < self.totalNumber) {
//        [self queryDataWithPage:willLoadPage];
        [self queryData];
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    
    NSUInteger referIndex = index;
    
    [self checkLoadMorePageWithIndex:referIndex];
    
    self.previousIndex = index;
}

#pragma mark - BusinessDetailIntroduceViewDelegate

- (void)didClickBusinessDetailIntroduceViewWithIndex:(NSUInteger)index{
    
    int clickNeedJumpIndex = 0;
    for (int i = 0; i < index; i ++) {
        GalleryCategory *galleryCategory = [[GalleryCategory alloc] init];
        galleryCategory = [_photoCategoryList objectAtIndex:i];
        clickNeedJumpIndex += galleryCategory.galleryCategoryCount;
    }
    [self setCurrentPhotoIndex:clickNeedJumpIndex];
    
    [self updateIntroduceCategoryHolderView:index];
    
}

- (void)updateIntroduceCategoryHolderView:(NSUInteger)index{
    
    NSArray *subViewList = [self.introduceCategoryHolderView subviews];
    for (UIView *view in subViewList) {
        if ([view isKindOfClass:[BusinessDetailIntroduceView class]]) {
            BusinessDetailIntroduceView *bdiv = (BusinessDetailIntroduceView *)view;
            if (bdiv.index == index) {
                [bdiv updateSelected:YES];
            }else {
                [bdiv updateSelected:NO];
            }
        }
    }
    
}

-(void) setPageViewAtIndex:(NSUInteger)index{
    [super setPageViewAtIndex:index];
    
    //因为这个方法即使index的值相同都会触发很多次，这样的话，会影响性能，所以，index相同的时候，进行拦截，提升性能
    NSUInteger scrollCurrentPageIndex = index + 1;
    if (_indexForUse != scrollCurrentPageIndex) {
       
        self.indexForUse = scrollCurrentPageIndex;
        
    }else {
        
        return;        
    }
    
    NSUInteger scrollButtonIndex = 0;
    
    int previousPhotoCount = 0;
    
    
    for (int i = 0; i <[_photoCategoryList count]; i++) {
        
        GalleryCategory * galleryCategory = [[GalleryCategory alloc] init];
        
        galleryCategory = [_photoCategoryList objectAtIndex:i];
        
        previousPhotoCount += galleryCategory.galleryCategoryCount;
        
        if ((_indexForUse) > previousPhotoCount) {
            
            scrollButtonIndex ++;
        }
    }
    
    [self updateIntroduceCategoryHolderView:scrollButtonIndex];
}

- (CGRect)frameForPagingScrollView {
    
    self.pagingScrollViewFrame =  [super frameForPagingScrollView];
    _pagingScrollViewFrame.size.height -= 60;
    return _pagingScrollViewFrame;
    
}

@end
