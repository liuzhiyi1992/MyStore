//
//  NoDataView.h
//  Sport
//
//  Created by haodong  on 15/4/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoDataViewDelegate <NSObject>
@optional
- (void)didClickNoDataViewRefreshButton;
@end

typedef enum
{
    NoDataTypeDefault = 0,
    NoDataTypeNetworkError = 1,
    NoDataTypeLocationError = 2
} NoDataType;

@interface NoDataView : UIView

@property (assign, nonatomic) id<NoDataViewDelegate> delegate;

+ (NoDataView *)createNoDataViewWithFrame:(CGRect)frame
                                     type:(NoDataType)type
                                     tips:(NSString *)tips;

@end
