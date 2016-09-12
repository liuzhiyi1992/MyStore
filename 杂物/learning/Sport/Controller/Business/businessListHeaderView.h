//
//  BusinessListHeaderView.h
//  Sport
//
//  Created by 冯俊霖 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BusinessListHeaderViewDelegate <NSObject>
@optional
- (void)didClickHeaderViewButton;
@end

@interface BusinessListHeaderView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *expandableImage;
@property (assign, nonatomic) id<BusinessListHeaderViewDelegate> delegate;

+ (BusinessListHeaderView *)createBusinessListHeaderView;

- (void)updateHeaderView:(NSString *)titleName
                areaName:(NSString *)areaName
                sortName:(NSString *)sortName
            filtrateName:(NSString *)filtrateName;

@end
