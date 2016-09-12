//
//  SportPhotoCaptionView.h
//  Sport
//
//  Created by 江彦聪 on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MWCaptionView.h"

@interface SportPhotoCaptionView : MWCaptionView
// Init
- (id)initWithPhoto:(id<MWPhoto>)photo
       currentIndex:(unsigned long) currentIndex
          totalPage:(unsigned long) totalPage;
@end
