//
//  ShareWithSinaController.h
//  Sport
//
//  Created by qiuhaodong on 15/5/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "SNSService.h"

@interface ShareWithSinaController : SportController<SNSServiceDelegate>

- (instancetype)initWithContent:(NSString *)content
                          image:(UIImage *)image
                       imageUrl:(NSString *)imageUrl;

@end
