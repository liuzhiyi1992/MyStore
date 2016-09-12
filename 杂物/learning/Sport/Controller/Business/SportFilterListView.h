//
//  SportFilterListView.h
//  Sport
//
//  Created by haodong  on 14-7-22.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class SportFilterListView;

@protocol SportFilterListViewDelegate <NSObject>
@optional
- (void)didSelectSportFilterListView:(SportFilterListView *)sportFilterListView indexPath:(NSIndexPath *)indexPath;

- (void)didHideSportFilterListView;


@end

@interface SportFilterListView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;


@property (assign, nonatomic) CGFloat tableHeight;
@property (strong, nonatomic) UIButton *holderButton;

@property (assign, nonatomic) id<SportFilterListViewDelegate> delegate;


+ (SportFilterListView *)createSportFilterListView;

+ (SportFilterListView *)createSportFilterListViewWithDataList:(NSArray *)dataList selectedRow:(NSUInteger)selectedRow;

- (void)showInView:(UIView *)view y:(CGFloat)y;

- (void)hide;

//以下是新的方法
+ (void)showInView:(UIView *)view
                 y:(CGFloat)y
               tag:(NSInteger)tag
          dataList:(NSArray *)dataList
       selectedRow:(NSUInteger)selectedRow
          delegate:(id<SportFilterListViewDelegate>)delegate
      holderButton:(UIButton *)holderButton
      imageUrlList:(NSArray *)imageUrlList
selectedImageUrlList:(NSArray *)selectedImageUrlList;

+ (BOOL)hideInView:(UIView *)view
               tag:(NSInteger)tag;

@end
