//
//  GoSportUrlAnalysis.m
//  Sport
//
//  Created by haodong  on 15/4/1.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "GoSportUrlAnalysis.h"
#import "XQueryComponents.h"
#import "BusinessDetailController.h"
#import "RegisterController.h"
#import "OrderListController.h"
#import "PrizeShareController.h"
#import "MyVouchersController.h"
#import "BusinessListController.h"
#import "LoginController.h"
#import "SportPopupView.h"
#import "UserManager.h"
#import "ShareView.h"
#import "SDWebImageDownloader.h"
#import "UIImage+normalized.h"
#import "BusinessMapController.h"
#import "UIUtils.h"
#import "MonthCardBusinessDetailController.h"
#import "Post.h"
#import "PostDetailController.h"
//#import "CourtPoolDetailController.h"
#import "Business.h"
//#import "CourtPoolListController.h"
#import "DiscoverHomeController.h"
#import "CoachListController.h"
#import "ForumHomeController.h"
#import "CourtJoinListController.h"
#import "PackageDetailController.h"

@implementation GoSportUrlAnalysis

+ (BOOL)isGoSportScheme:(NSURL *)url
{
    return [[url scheme] isEqualToString:@"gosport"];
}

+ (void)pushControllerWithUrl:(NSURL *)url
         NavigationController:(UINavigationController *)navigationController
{
    if ([GoSportUrlAnalysis isGoSportScheme:url] == NO) {
        return;
    }
    
    if ([[url host] isEqualToString:@"business_detail"]) {
        NSMutableDictionary *dic = [url queryComponents];
        NSString *businessId = [dic valueForKey:@"business_id"];
        NSString *categoryId = [dic valueForKey:@"category_id"];
        
        BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:businessId categoryId:categoryId];
        [navigationController pushViewController:controller animated:YES];
        
        HDLog(@"push BusinessDetailController");
    }
    
    else if ([[url host] isEqualToString:@"register"]) {
        if ([UserManager isLogin]) {
            [SportPopupView popupWithMessage:@"你已是注册用户"];
        } else {
            RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeRegiser];
            [navigationController pushViewController:controller animated:YES];
        }
    }
    
    else if ([[url host] isEqualToString:@"order_info"]) {
        if ([self isLoginAndShowLoginIfNot:navigationController]) {
            OrderListController *controller = [[OrderListController alloc] init];
            [navigationController pushViewController:controller animated:YES];
        }
    }
    
    else if ([[url host] isEqualToString:@"invite"]) {
        if ([self isLoginAndShowLoginIfNot:navigationController]) {
            PrizeShareController *controller = [[PrizeShareController alloc] init];
            [navigationController pushViewController:controller animated:YES];
        }
    }
    
    else if ([[url host] isEqualToString:@"coupon"]) {
        if ([self isLoginAndShowLoginIfNot:navigationController]) {
            MyVouchersController *controller = [[MyVouchersController alloc] init];
            [navigationController pushViewController:controller animated:YES];
        }
    }
    
    else if ([[url host] isEqualToString:@"sale_detail"]) {
        NSMutableDictionary *dic = [url queryComponents];
        NSString *packageId = [dic valueForKey:@"goods_id"];
        PackageDetailController *controller = [[PackageDetailController alloc] initWithPackageId:packageId isSpecialSale:YES];
        [navigationController pushViewController:controller animated:YES];
    }
    
    else if ([[url host] isEqualToString:@"business_list"]) {
        NSMutableDictionary *dic = [url queryComponents];
        NSString *categoryId = [dic valueForKey:@"category_id"];
        NSString *regionId = [dic valueForKey:@"region_id"];
        NSString *sortId = [dic valueForKey:@"sort"];
        NSString *pageString = [dic valueForKey:@"page"];
        NSString *countString = [dic valueForKey:@"count"];
        NSString *from = [dic valueForKey:@"from"];
       
        //NSString *subRegion = [dic valueForKey:@"sub_region"];
        
        int page = [pageString intValue];
        int count = [countString intValue];
        
        BusinessListController *controller = [[BusinessListController alloc] initWithCategoryId:categoryId
                                                                                       regionId:regionId
                                                                                         sortId:sortId
                                                                                           page:page
                                                                                          count:count
                                                                                           from:from];
        [navigationController pushViewController:controller animated:YES];
    }
    
    else if ([[url host] isEqualToString:@"sale_list"]) {
        //已去掉特惠模块
    }
    
    else if ([[url host] isEqualToString:@"share_info"]) {
        
        ShareContent *shareContent = [self shareContentWithUrlQuery:url.query];
        
        [ShareView popUpViewWithContent:shareContent
                            channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatTimeline),@(ShareChannelWeChatSession), @(ShareChannelSina), @(ShareChannelCopy), nil]
                         viewController:navigationController delegate:nil];
    }
    else if ([[url host] isEqualToString:@"moncard_detail"]) {
        [MobClickUtils event:umeng_event_month_course_detail_click_business];
        
        NSMutableDictionary *dic = [url queryComponents];
        NSString *businessId = [dic valueForKey:@"business_id"];
        NSString *categoryId = [dic valueForKey:@"category_id"];
        BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:businessId categoryId:categoryId];
        [navigationController pushViewController:controller animated:YES];
    }
    else if ([[url host] isEqualToString:@"location"]) {
        [MobClickUtils event:umeng_event_month_course_detail_click_address];
        
        NSMutableDictionary *dic = [url queryComponents];
        double longitude = [[dic valueForKey:@"longitude"] doubleValue];
        double latitude = [[dic valueForKey:@"latitude"] doubleValue];
        NSString *name = [dic valueForKey:@"name"];
        NSString *address = [dic valueForKey:@"address"];
        NSString *categoryId = [dic valueForKey:@"category_id"];
        
        BusinessMapController *controller = [[BusinessMapController alloc] initWithLatitude:latitude longitude:longitude businessName:name      businessAddress:address parkingLotList:nil businessId:nil categoryId:categoryId type:0];
        [navigationController pushViewController:controller animated:YES];
    }
    else if ([[url host] isEqualToString:@"phone"]) {
        [MobClickUtils event:umeng_event_month_course_detail_click_phone];
        
        NSMutableDictionary *dic = [url queryComponents];
        NSString *phone = [dic valueForKey:@"phone"];
        BOOL result = [UIUtils makePromptCall:phone];
        if (result == NO) {
            [SportPopupView popupWithMessage:@"此设备不支持打电话"];
        }
    }
    else if ([[url host] isEqualToString:@"post_detail"]) {//运动圈帖子详情
        
        NSMutableDictionary *dic = [url queryComponents];
        Post *post = [[Post alloc] init];
        post.postId = [dic objectForKey:@"post_id"];
        PostDetailController *controller = [[PostDetailController alloc] initWithPost:post isShowTitle:YES];
        [navigationController pushViewController:controller animated:YES];
    }else if ([[url host] isEqualToString:@"go_back"]) {
        if([navigationController.childViewControllers count] > 1) {
            [navigationController popViewControllerAnimated:YES];
        }
//    }else if ([[url host] isEqualToString:@"courtpool_detail"]) {//拼场详情
//        
//        NSMutableDictionary *dic = [url queryComponents];
//        
//        NSString *poolId = [dic objectForKey:@"court_pool_id"];
//        CourtPoolDetailController *controller = [[CourtPoolDetailController alloc] initWithCourtPoolId:poolId];
//        [navigationController pushViewController:controller animated:YES];
//    }else if ([[url host] isEqualToString:@"court_pool_list"]){//拼场列表
//        NSMutableDictionary *dic = [url queryComponents];
//        NSString *catId = [dic objectForKey:@"court_pool_list"];
//        
//     
//        CourtPoolListController *controller = [[CourtPoolListController alloc]initWithCourtCatId:catId businessId:nil categoryId:nil date:nil];
//        [navigationController pushViewController:controller animated:YES];
    } else if ([[url host] isEqualToString:@"forum"]) {
        ForumHomeController *fhc = [[ForumHomeController alloc] init];
        [navigationController pushViewController:fhc animated:YES];
        
    }else if ([[url host] isEqualToString:@"coach"]) {
        CoachListController *clc = [[CoachListController alloc] init];
        [navigationController pushViewController:clc animated:YES];
        
    }else if ([[url host] isEqualToString:@"courtjoin"] ) {
        CourtJoinListController *cjlc = [[CourtJoinListController alloc] initWithCourtJoinListControllerWithDate:nil];
        [navigationController pushViewController:cjlc animated:YES];
    }
}

+ (BOOL)isLoginAndShowLoginIfNot:(UINavigationController *)navigationController
{
    if ([UserManager isLogin]) {
        return YES;
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [navigationController pushViewController:controller animated:YES];
        return NO;
    }
}

+ (ShareContent *)shareContentWithUrlQuery:(NSString *)urlQuery formatType:(GoSportUrlFormatType)type {
    NSDictionary *infoDic = [urlQuery dictionaryFromQueryComponents];
    ShareContent *shareContent = [[ShareContent alloc] init] ;
    shareContent.linkUrl = [infoDic valueForKey:@"url"];
    shareContent.title = [infoDic valueForKey:@"title"];
    shareContent.subTitle = [infoDic valueForKey:@"description"];
    
    if (type == GoSportUrlFormatTypeCommon) {
        shareContent.content = [NSString stringWithFormat:@"【%@】%@", shareContent.title, shareContent.subTitle];
    } else if (type == GoSportUrlFormatTypeSeperate) {
        shareContent.content = shareContent.subTitle;
    }
    
    shareContent.imageUrL = [infoDic valueForKey:@"img_url"];
    NSString *thumbUrl = [infoDic valueForKey:@"thumb_url"];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:thumbUrl]
                                                          options:SDWebImageDownloaderUseNSURLCache
                                                         progress:nil
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            
                                                            if (finished && image) {
                                                                shareContent.thumbImage = [image compressWithMaxLenth:80];
                                                            }
                                                        }];
    return shareContent;

}

+ (ShareContent *)shareContentWithUrlQuery:(NSString *)urlQuery
{
    return [self shareContentWithUrlQuery:urlQuery formatType:GoSportUrlFormatTypeCommon];;
}

@end
