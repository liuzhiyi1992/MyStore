//
//  AMapSelecteAddressView.h
//  Sport
//
//  Created by 江彦聪 on 15/10/13.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMapSearchAddressViewDelegate <NSObject>

-(void) didClickAddress:(NSString *)address;
-(void) didCancelInput;
-(void) didScrollTableView;
@end

@interface AMapSearchAddressView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstrant;
@property (weak, nonatomic) id<AMapSearchAddressViewDelegate> delegate;
+ (AMapSearchAddressView *)createAMapSearchAddressView;
- (void)showWithFrame:(CGRect)frame;
- (void)refreshDataList:(NSMutableArray *)array height:(CGFloat)height;
- (void)refreshHeight:(CGFloat)height;

@end
