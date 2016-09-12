//
//  BusinessListPickerView.h
//  Sport
//
//  Created by 冯俊霖 on 15/10/20.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessPickerData.h"

@interface BusinessListPickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *dataPickerView;

@property (readonly, strong, nonatomic) NSArray *firstShowList;
@property (readonly, strong, nonatomic) NSArray *secondShowList;
@property (readonly, strong, nonatomic) NSArray *thirdShowList;

+ (BusinessListPickerView *)showWithCategoryId:(NSString *)categoryId
                                  selectedDate:(NSDate *)selectedDate
                             selectedStartHour:(NSString *)selectedStartHour
                          selectedTimeTnterval:(NSString *)selectedTimeTnterval
                          selectedSoccerNumber:(NSString *)selectedSoccerNumber
                                     OKHandler:(void (^)(NSDate *date, NSString *startHour, NSString *timeTnterval, NSString *soccerNumber))OKHandler;

@end
