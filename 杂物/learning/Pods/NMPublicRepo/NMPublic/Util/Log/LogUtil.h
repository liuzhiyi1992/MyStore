//
//  LogUtil.h
//  QueueUp
//
//  Created by haodong on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogUtil : NSObject

#ifdef DEBUG
#define HDLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define HDLog(format, ...)
#endif


#ifdef DEBUG
#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"\n%s x:%.4f, y:%.4f", #point, point.x, point.y)
#else
#define NSLogRect(rect)
#define NSLogSize(size)
#define NSLogPoint(point)
#endif

@end
