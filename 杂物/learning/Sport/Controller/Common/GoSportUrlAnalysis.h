//
//  GoSportUrlAnalysis.h
//  Sport
//
//  Created by haodong  on 15/4/1.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareContent.h"


@interface GoSportUrlAnalysis : NSObject

typedef NS_ENUM(NSInteger,GoSportUrlFormatType) {
    GoSportUrlFormatTypeCommon = 0,    // WebView和约练使用，微博／qq分享时，content形式为 [title]subTitle
    GoSportUrlFormatTypeSeperate = 1,  // 保险时使用，微博／qq分享时, content形式为 subTitle
};

+ (BOOL)isGoSportScheme:(NSURL *)url;

+ (void)pushControllerWithUrl:(NSURL *)url
         NavigationController:(UINavigationController *)navigationController;

+ (ShareContent *)shareContentWithUrlQuery:(NSString *)urlQuery;
+ (ShareContent *)shareContentWithUrlQuery:(NSString *)urlQuery formatType:(GoSportUrlFormatType)type;

@end
