//
//  BusinessListHeaderView.m
//  Sport
//
//  Created by 冯俊霖 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "BusinessListHeaderView.h"

@interface BusinessListHeaderView()
@property (strong, nonatomic) IBOutlet UIView *addLabelView;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UILabel *areaLabal;
@property (strong, nonatomic) IBOutlet UILabel *sortLabel;
@property (strong, nonatomic) IBOutlet UILabel *filtrateLabel;

@end

@implementation BusinessListHeaderView

+ (BusinessListHeaderView *)createBusinessListHeaderView{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BusinessListHeaderView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BusinessListHeaderView *view = [topLevelObjects objectAtIndex:0];

    return view;
}

- (void)updateHeaderView:(NSString *)titleName
                areaName:(NSString *)areaName
                sortName:(NSString *)sortName
            filtrateName:(NSString *)filtrateName{
    self.headerLabel.text = titleName;
    self.areaLabal.text = areaName;
    if (filtrateName.length > 0) {
        self.filtrateLabel.text = sortName;
        self.sortLabel.text = filtrateName;
    }else{
        self.filtrateLabel.text = filtrateName;
        self.sortLabel.text = sortName;
    }
}

- (IBAction)clickHeaderViewButton:(UIButton *)sender {
    [MobClickUtils event:umeng_event_business_list_click_top_filter_button];
    if ([_delegate respondsToSelector:@selector(didClickHeaderViewButton)]) {
        [_delegate didClickHeaderViewButton];
    }
}

@end
