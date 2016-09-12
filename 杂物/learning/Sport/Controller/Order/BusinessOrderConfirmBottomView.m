//
//  BusinessOrderConfirmBottomView.m
//  Sport
//
//  Created by 江彦聪 on 8/9/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import "BusinessOrderConfirmBottomView.h"
#import "BusinessPriceDetailCell.h"
#import "OrderConfirmPriceDetailView.h"
@interface BusinessOrderConfirmBottomView()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *priceDetailArray;
@property (strong, nonatomic) NSMutableArray *courtDetailArray;

@property (strong, nonatomic) UIControl *backgroundMaskView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitHolderViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (strong, nonatomic) OrderConfirmPriceDetailView *detailView;
@end
@implementation BusinessOrderConfirmBottomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (BusinessOrderConfirmBottomView *)createBusinessOrderConfirmBottomView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BusinessOrderConfirmBottomView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    BusinessOrderConfirmBottomView *view = [topLevelObjects objectAtIndex:0];
    
    return view;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.priceDetailArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [BusinessPriceDetailCell getCellIdentifier];
    BusinessPriceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    [cell updateWithNameContendArray:self.priceDetailArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BusinessPriceDetailCell getCellHeight];
}

- (IBAction)clickExpandPriceDetail:(id)sender {
    if (self.detailView == nil || self.detailView.superview == nil) {
        [UIView animateWithDuration:0.2 animations:^{
            if (self.arrowImageView) {
                self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        }];
        
        // 如果没有数据源，不做展示详情
        if ([_delegate respondsToSelector:@selector(prepareForPriceDetailView:)]){
            self.priceDetailArray = [NSMutableArray array];
            [_delegate prepareForPriceDetailView:self.priceDetailArray];
            if (self.detailView == nil) {
                self.detailView = [OrderConfirmPriceDetailView createOrderConfirmPriceDetailView];
                self.detailView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.submitHolderViewHeight.constant);

            }
            
            [self.detailView updateDataList:self.priceDetailArray bottomViewHeight:self.submitHolderViewHeight.constant];
            
            [[UIApplication sharedApplication].keyWindow addSubview:self.detailView];

        } else {
            HDLog(@"%s:%d should have delegate here!",__func__,__LINE__);
        }
        
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            if (self.arrowImageView) {
                self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
            }
        }];
        [self removeBackgroundMask];
    }
}

-(void) removeBackgroundMask {
    [self.detailView removeFromSuperview];
}

-(void) isShowPriceDetail:(BOOL)isShow {
    for (UIView *view in self.detailPriceHolderView) {
        view.hidden = !isShow;
        self.submitHolderViewHeight.constant = isShow?105:75;
    }
}

- (IBAction)clickSubmitButton:(id)sender {
    [self removeBackgroundMask];
    if ([_delegate respondsToSelector:@selector(didClickSubmitButton)]) {
        [_delegate didClickSubmitButton];
    }
}

@end
