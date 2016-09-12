//
//  BusinessListController.h
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BusinessService.h"
#import "SportFilterListView.h"
#import "SportDropDownMenuView.h"

@class BusinessListPickerView;
@interface BusinessListController : SportController<UITableViewDataSource, UITableViewDelegate, BusinessServiceDelegate, SportFilterListViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *chooseTimeView;
@property (strong, nonatomic) IBOutlet UILabel *chooseTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *chooseTimeButton;
@property (strong, nonatomic) IBOutlet UIView *chooseTimeLine;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (id)initWithCategoryId:(NSString *)categoryId
       isFirstController:(BOOL)isFirstController
            categoryName:(NSString *)categoryName;

- (id)initWithCategoryId:(NSString *)categoryId
                regionId:(NSString *)regionId
                  sortId:(NSString *)sortId
                    page:(int)page
                   count:(int)count
                    from:(NSString *)from;

- (id)initWithCategoryId:(NSString *)categoryId
                    date:(NSDate *)date
               startHour:(NSInteger)startHour
            timeTnterval:(NSInteger)timeTnterval
            soccerNumber:(NSString *)soccerNumber
        selectedFilterId:(NSString *)selectedFilterId;

@end
