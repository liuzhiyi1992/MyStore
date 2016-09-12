//
//  SportFilterListView.m
//  Sport
//
//  Created by haodong  on 14-7-22.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportFilterListView.h"
#import "UIView+Utils.h"
#import "UIImageView+WebCache.h"
#import "SportFilterCell.h"

@interface SportFilterListView()
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) NSArray *imageUrlList;
@property (strong, nonatomic) NSArray *selectedImageUrlList;
@property (assign, nonatomic) NSUInteger selectedRow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableH;
@end

@implementation SportFilterListView

+ (SportFilterListView *)createSportFilterListView
  {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportFilterListView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    return [topLevelObjects objectAtIndex:0];
}

+ (SportFilterListView *)createSportFilterListViewWithDataList:(NSArray *)dataList selectedRow:(NSUInteger)selectedRow
{
    SportFilterListView *view = [self createSportFilterListView];
    view.dataTableView.separatorStyle = NO;
    view.dataList = dataList;
    view.selectedRow = selectedRow;
    if (dataList.count<=4) {
        view.tableH.constant = dataList.count*44;
    }else {
        if ([UIScreen mainScreen].bounds.size.height==480) {
            view.tableH.constant = 4*44;
        }else if([UIScreen mainScreen].bounds.size.height==568){
            
            if (dataList.count<=6) {
                view.tableH.constant = dataList.count*44;
                
            }else{
                
                view.tableH.constant = 6*44;
            }
            
        }else if([UIScreen mainScreen].bounds.size.height==667){
            
            if (dataList.count<=7) {
                view.tableH.constant = dataList.count*44;
                
            }else{
                
                view.tableH.constant = 7*44;
            }
            
            
        }else if([UIScreen mainScreen].bounds.size.height==736){
            
            if (dataList.count<=8) {
                view.tableH.constant = dataList.count*44;
                
            }else{
                
                view.tableH.constant = 8*44;
            }
            
            
        }
        
        
        
    }
    
            UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, dataList.count*44-1, [UIScreen mainScreen].bounds.size.width, 2)];
    [img setBackgroundColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0]];
      [view.dataTableView addSubview:img];
    
     view.frame = [UIScreen mainScreen].bounds;
    [view.dataTableView reloadData];
    return view;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [SportFilterCell getCellIdentifier];
    SportFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        BOOL hasImage = [_imageUrlList count] > 0;
        cell = [SportFilterCell createCellWithHasImage:hasImage];
    }
    NSString *title = [_dataList objectAtIndex:indexPath.row];
    
    NSString *imageUrl = nil;
    BOOL isSelected = (_selectedRow == indexPath.row);
    if (isSelected) {
        if (indexPath.row < [_selectedImageUrlList count]) {
            imageUrl = [_selectedImageUrlList objectAtIndex:indexPath.row];
        }
    } else {
        if (indexPath.row < [_imageUrlList count]) {
            imageUrl = [_imageUrlList objectAtIndex:indexPath.row];
        }
    }
    
    [cell updateCellWithImageUrl:imageUrl content:title isSelected:isSelected];
//    if (indexPath.row==_dataList.count-1) {
//        
////        
////        UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, 2)];
////        
////        img.backgroundColor=[UIColor redColor];
//        
//       // tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
//        
//        self.dataTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
//        //[cell.contentView addSubview:img];
//    }
//    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if (indexPath.row==_dataList.count-1) {
//        return 100;
//    }else{
//        return [SportFilterCell getCellHeight];}
     return [SportFilterCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(didSelectSportFilterListView:indexPath:)]) {
        [_delegate didSelectSportFilterListView:self indexPath:indexPath];
    }
    [self hide];
}

- (IBAction)touchDownBackgroundView:(id)sender {
    [self hide];
}

- (void)showInView:(UIView *)view y:(CGFloat)y
{
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[SportFilterListView class]]) {
            [(SportFilterListView *)subView hide];
        }
    }
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
    [self.dataTableView reloadData];
    [self updateOriginY:y];
    [self.dataTableView updateHeight:0];
    self.backgroundView.alpha = 0.1;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat height = (_tableHeight > 0 ? _tableHeight : 300);
        [self.dataTableView updateHeight:height];
        self.backgroundView.alpha = 0.5;
    } completion:^(BOOL finished) {
        self.bottomImageView.hidden = NO;
        [self.bottomImageView updateWidth:[UIScreen mainScreen].bounds.size.width];
    
    
    }];
    
    CGFloat height = (_tableHeight > 0 ? _tableHeight : 300);
    [self.dataTableView updateHeight:height];
}

- (void)hide
{
    if (_holderButton) {
        _holderButton.selected = NO;
        self.holderButton = nil;
    }
    
     [self.bottomImageView updateWidth:[UIScreen mainScreen].bounds.size.width];
    self.bottomImageView.hidden = YES;
   
    [UIView animateWithDuration:0.26 animations:^{
        self.backgroundView.alpha = 0.0;
        [self.dataTableView updateHeight:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    if ([_delegate respondsToSelector:@selector(didHideSportFilterListView)]) {
        [_delegate didHideSportFilterListView];
    }
}


+ (void)showInView:(UIView *)view
                 y:(CGFloat)y
               tag:(NSInteger)tag
          dataList:(NSArray *)dataList
       selectedRow:(NSUInteger)selectedRow
          delegate:(id<SportFilterListViewDelegate>)delegate
      holderButton:(UIButton *)holderButton
      imageUrlList:(NSArray *)imageUrlList
selectedImageUrlList:(NSArray *)selectedImageUrlList
{
    
    SportFilterListView *filterListView = [SportFilterListView createSportFilterListViewWithDataList:dataList selectedRow:selectedRow];
    filterListView.tag = tag;
    filterListView.delegate = delegate;
    filterListView.holderButton = holderButton;
    filterListView.imageUrlList = imageUrlList;
    filterListView.selectedImageUrlList = selectedImageUrlList;
    [filterListView showInView:view y:y];
    holderButton.selected = YES;
}

+ (BOOL)hideInView:(UIView *)view
               tag:(NSInteger)tag
{
    SportFilterListView *filterListView = (SportFilterListView *)[view viewWithTag:tag];
    if (filterListView) {
        [filterListView hide];
        return YES;
    } else {
        return NO;
    }
}

@end
