//
//  UUIDManager.h
//  
//
//  Created by 江彦聪 on 16/1/11.
//
//

#import <Foundation/Foundation.h>

@interface UUIDManager : NSObject
+ (UUIDManager *)defaultManager;
- (NSString *)readUUID;

@end
