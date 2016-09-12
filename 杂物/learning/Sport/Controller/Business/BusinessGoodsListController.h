//
//  BusinessGoodsListController.h
//  Sport
//
//  Created by 江彦聪 on 8/12/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import "SportController.h"
@protocol BusinessGoodsListControllerDelegate<NSObject>
-(void) refreshSelectedGoodsList:(NSArray *)list;
@end

@interface BusinessGoodsListController : SportController
@property (assign, nonatomic) id<BusinessGoodsListControllerDelegate> delegate;
-(id) initWithGoodsList:(NSArray *)list;

@end
