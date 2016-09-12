//
//  AppGlobalDataManager.h
//  Sport
//
//  Created by haodong  on 14/11/24.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppGlobalDataManager : NSObject

@property (assign, nonatomic) BOOL isShowingBootPage;
@property (assign, nonatomic) BOOL isShowingCityListView;

@property (copy, nonatomic) NSString *recentSubmitReview;//最近上传的评论
@property (assign, nonatomic) double timeDifference; //服务器时间与本地时间的差值（即:服务器时间 - 本地时间）
@property (assign, nonatomic) BOOL isShowQuickBook;
@property (strong, nonatomic) NSString *qydToken;
@property (assign, atomic) BOOL isProcessingToken;
@property (strong, nonatomic) NSArray *tokenReqList;
//@property (assign, atomic) int32_t networkQueue;
+ (AppGlobalDataManager *)defaultManager;
- (BOOL) isTokenRequest:(NSString *)action;
@end
