//
//  SportPullTableController.m
//  Sport
//
//  Created by haodong  on 13-8-3.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportPullTableController.h"
#import "DemoTableHeaderView.h"
#import "DemoTableFooterView.h"
#import "UIView+Utils.h"

@interface SportPullTableController ()
@end

@implementation SportPullTableController

//- (void)dealloc
//{
//    [super dealloc];
//}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // set the custom view for "pull to refresh". See DemoTableHeaderView.xib.
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView" owner:self options:nil];
    DemoTableHeaderView *headerView = (DemoTableHeaderView *)[nib objectAtIndex:0];
    self.headerView = headerView;
    
    // set the custom view for "load more". See DemoTableFooterView.xib.
    nib = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView" owner:self options:nil];
    DemoTableFooterView *footerView = (DemoTableFooterView *)[nib objectAtIndex:0];
    self.footerView = footerView;
    
    // Disable canLoadMore at the very first time, to hide pull table footerview
    self.canLoadMore = NO;
    //self.view.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1];
}

#pragma mark - Pull to Refresh
- (void) pinHeaderView
{
    [super pinHeaderView];
    // do custom handling for the header view
    DemoTableHeaderView *hv = (DemoTableHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = DDTF(@"kLoading");
}

- (void) unpinHeaderView
{
    [super unpinHeaderView];
    // do custom handling for the header view
    [[(DemoTableHeaderView *)self.headerView activityIndicator] stopAnimating];
}

// Update the header text while the user is dragging
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    DemoTableHeaderView *hv = (DemoTableHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = DDTF(@"KReleaseToRefresh");
    else
        hv.title.text = DDTF(@"kPullDownToRefresh");
}

// refresh the list. Do your async calls here.
- (BOOL)refresh
{
    if (![super refresh])
        return NO;
    [self refreshDataStart];
    return YES;
}

#pragma mark - Load More
// The method -loadMore was called and will begin fetching data for the next page (more).
// Do custom handling of -footerView if you need to.
- (void) willBeginLoadingMore
{
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
    fv.infoLabel.hidden = NO;
    [fv.infoLabel setText:DDTF(@"kLoading")];
}

// Do UI handling after the "load more" process was completed. In this example, -footerView will
// show a "No more items to load" text.
- (void)loadMoreCompleted
{
    [super loadMoreCompleted];
    
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        [self setFooterViewVisibility:NO];
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    } else {
        [self setFooterViewVisibility:YES];
    }
}

- (BOOL)loadMore
{
    if (![super loadMore])
        return NO;
    [self loadMorDataStart];
    return YES;
}

#pragma mark - Dummy data methods
- (void)refreshDataStart
{
}

- (void)loadMorDataStart
{
}

- (void)viewWillLayoutSubviews
{
    
}


- (void)viewDidLayoutSubviews
{
    
}

@end
