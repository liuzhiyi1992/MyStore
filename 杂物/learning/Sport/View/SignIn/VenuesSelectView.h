//
//  VenuesSelectView.h
//  Sport
//
//  Created by lzy on 16/6/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

extern const char kVenuesId;


@protocol VenuesSelectViewDelegate <NSObject>
- (void)venuesSelectViewDidSelectedVenuesId:(NSString *)venuesId;
@end


@interface VenuesSelectView : UIView
@property (weak, nonatomic) id<VenuesSelectViewDelegate> delegate;
- (void)dismiss;
+ (VenuesSelectView *)showViewWithVenuesNameArray:(NSArray *)array delegate:(id<VenuesSelectViewDelegate>)delegate;
@end
