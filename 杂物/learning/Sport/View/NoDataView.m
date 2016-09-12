//
//  NoDataView.m
//  Sport
//
//  Created by haodong  on 15/4/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "NoDataView.h"
#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>

@interface NoDataView()

@property (weak, nonatomic) IBOutlet UIView *networkErrorHolderView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *networkErrorLabel;

@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@end

@implementation NoDataView


+ (NoDataView *)createNoDataViewWithFrame:(CGRect)frame
                                     type:(NoDataType)type
                                     tips:(NSString *)tips
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NoDataView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    NoDataView *view = (NoDataView *)[topLevelObjects objectAtIndex:0];
    
    view.backgroundColor = [SportColor defaultPageBackgroundColor];
    //view.backgroundColor = [UIColor blueColor];
    //HDLog(@"NoDataView frame:%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    view.frame = frame;
    
    if (type == NoDataTypeDefault) {
        view.noDataLabel.hidden = NO;
        view.networkErrorHolderView.hidden = YES;
        view.noDataLabel.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height /2);
        view.noDataLabel.text = tips;
    } else if (type == NoDataTypeNetworkError) {
        view.noDataLabel.hidden = YES;
        view.networkErrorHolderView.hidden = NO;
        view.networkErrorHolderView.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height /2);
        view.networkErrorLabel.text = tips;
        
        view.refreshButton.layer.cornerRadius = 2;
        view.refreshButton.layer.masksToBounds = YES;
        [view.refreshButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1]] forState:UIControlStateNormal];
    } else if(type == NoDataTypeLocationError) {
        view.noDataLabel.hidden = NO;
        view.networkErrorHolderView.hidden = YES;
        view.noDataLabel.center = CGPointMake(view.frame.size.width / 2, view.frame.size.height /2);
        view.noDataLabel.text = tips;
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    
    return view;
}

- (IBAction)clickRefreshButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickNoDataViewRefreshButton)]) {
        self.refreshButton.hidden = YES;
        [_delegate didClickNoDataViewRefreshButton];
    }
}

@end
