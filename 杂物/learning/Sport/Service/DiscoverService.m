//
//  DiscoverService.m
//  Sport
//
//  Created by xiaoyang on 16/6/25.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DiscoverService.h"
#import "GSNetwork.h"
#import "Discover.h"


@implementation DiscoverService
+ (void)queryDiscover:(id<DiscoverServiceDelegate>)delegate
               cityId:(NSString *)cityId{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_ENTRY_PROJECT_LIST forKey:PARA_ACTION];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSMutableArray *discoverList = [NSMutableArray array];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        
        NSMutableArray *groupNameList = [NSMutableArray array];
        for (NSDictionary *one in list) {
            Discover *discover = [[Discover alloc] init];
            discover.name = [one validStringValueForKey:PARA_NAME];
            discover.link = [one validStringValueForKey:PARA_LINK];
            discover.imageUrl = [one validStringValueForKey:PARA_IMAGE_URL];
            discover.group = [one validStringValueForKey:PARA_GROUP];
            [discoverList addObject:discover];
            
            if (discover.group) {
                BOOL found = NO;
                for (NSString *group in groupNameList) {
                    if ([discover.group isEqualToString:group]) {
                        found = YES;
                        break;
                    }
                }
                
                if (!found) {
                    [groupNameList addObject:discover.group];
                }
            }
        }
        
        NSMutableArray *resultList = [NSMutableArray array];
        for (NSString *groupName in groupNameList) {
            NSMutableArray *oneGroupArray = [NSMutableArray array];
            for (Discover *discover in discoverList) {
                if ([discover.group isEqualToString:groupName]) {
                    [oneGroupArray addObject:discover];
                }
            }
            [resultList addObject:oneGroupArray];
        }
        
//        int differentCourt = 0;
//        for (int i = 0 ;i<([aList count] - 1);i++) {
//            if ([aList[i] isEqualToString:aList[i+1]]){
//                continue;
//            }else {
//                differentCourt ++;
//            }
//        }
//        NSMutableArray * array = [NSMutableArray array];
//        for (int i = 0;i < differentCourt; i++) {
//            NSMutableArray *a = [NSMutableArray array];
//            for (int i = 0 ;i<([aList count] - 1);i++) {
//                if ([aList[i] isEqualToString:aList[i+1]]){
//                    [a addObject:discoverList[i]];
//                }else {
//                    differentCourt ++;
//                }
//            }
//            array = [NSMutableArray arrayWithObjects:a, nil];
//        }
//
//        for (Discover *discover in discoverList) {
////            NSString * currentGroup = [a objectForKey:discover.group];
//            if (discover.group)
//            
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(getDataWithDiscoverList:status:msg:)]){
                
                [delegate getDataWithDiscoverList:(NSArray *)resultList
                                                   status:(NSString *)status
                                                      msg:(NSString *)msg];
            }
        });
    }];
}
@end
