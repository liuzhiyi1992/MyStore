//
//  PayTypeView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayTypeView.h"
#import "PayMethod.h"
#import "PayTypeCell.h"
#import "UIView+Utils.h"

@interface PayTypeView()

@property (assign, nonatomic) id<PayTypeViewDelegate> delegate;
@property (strong, nonatomic) NSArray *methodList;
@property (strong, nonatomic) PayMethod *selectedPayMethod;

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation PayTypeView

+ (PayTypeView *)createViewWithMethodList:(NSArray *)methodList
                           selectedMethod:(PayMethod *)selectedMethod
                                 delegate:(id<PayTypeViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayTypeView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    PayTypeView *view = (PayTypeView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    view.methodList = methodList;
    view.selectedPayMethod = selectedMethod;
    view.delegate = delegate;
    CGFloat height = [PayTypeCell getCellHeight] * [methodList count];
    
    //不需要设置tableView高度
    //[view.dataTableView updateHeight:height];
    [view updateHeight:height];
    [view.dataTableView reloadData];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_methodList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [PayTypeCell getCellIdentifier];
    PayTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [PayTypeCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    PayMethod *method = [_methodList objectAtIndex:indexPath.row];
    BOOL isSelected = [self.selectedPayMethod.payKey isEqualToString:method.payKey];
    BOOL isLast = (indexPath.row == [_methodList count] - 1);
    
    [cell updateCellWithPayMethod:method
                     isSelected:isSelected
                      indexPath:indexPath
                         isLast:isLast];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PayTypeCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PayMethod *method = [_methodList objectAtIndex:indexPath.row];
    self.selectedPayMethod = method;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.selectedPayMethod.payKey forKey:KEY_LAST_SELECTED_PAY];
        [defaults synchronize];
    });
    
    if ([_delegate respondsToSelector:@selector(didClickPayTypeView:)]) {
        [_delegate didClickPayTypeView:method];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

@end
