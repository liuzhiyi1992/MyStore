//
//  BookWithPhoneController.h
//  Sport
//
//  Created by liuzhiyi on 15/11/2.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportController.h"
#import "BusinessService.h"

@class Business;

@interface BookWithPhoneController : SportController <BusinessServiceDelegate, UIScrollViewDelegate, UITextFieldDelegate>

    //CallBookController *controller = [[CallBookController alloc] initWithBusiness:_business selectedCategoryId:_selectedCategoryId startTime:startTime duration:_callBookDuration] ;

- (instancetype)initWithBusiness:(Business *)business
                      categoryId:(NSString *)categoryId
                       startTime:(NSDate *)startTime
                        duration:(int)duration;

@end
