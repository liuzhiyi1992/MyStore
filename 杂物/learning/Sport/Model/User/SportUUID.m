//
//  SportUUID.m
//  Sport
//
//  Created by haodong  on 14-9-22.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportUUID.h"
#import "KeychainItemWrapper.h"

#define KEY_DEVICE_ID @"key_di"

@implementation SportUUID

+ (NSString *)uuid
{
    //从1.991版本开始不用Keychain，改用NSUserDefaults保存deviceid。但如果之前Keychain里有值的仍然用Keychain里的值。
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            
    NSString *uniqueIdentifier = [defaults objectForKey:KEY_DEVICE_ID];
    
    //如果是空，先从旧版本中的存储(Keychain)中看能否取到值
    if (uniqueIdentifier.length == 0) {
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.qiuhaodong.sport" accessGroup:nil];
        uniqueIdentifier = [wrapper objectForKey:(id)kSecAttrAccount];
        [wrapper release];
    }
    
    if (uniqueIdentifier.length == 0) {
        uniqueIdentifier = getOpenUUID();
        [defaults setObject:uniqueIdentifier forKey:KEY_DEVICE_ID];
        [defaults synchronize];
    }
    
    return uniqueIdentifier;
}

NSString *getOpenUUID()
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end
