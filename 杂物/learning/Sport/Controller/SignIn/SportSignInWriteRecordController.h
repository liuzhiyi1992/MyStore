//
//  SportSignInWriteRecordController.h
//  Sport
//
//  Created by 江彦聪 on 16/7/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "WritePostController.h"

@interface SportSignInWriteRecordController : WritePostController
-(id)initWithSignInId:(NSString *)signInId
              forumId:(NSString *)forumId
            forumName:(NSString *)forumName;
@end
