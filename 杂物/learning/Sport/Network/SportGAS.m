//
//  SportGAS.m
//  Sport
//
//  Created by qiuhaodong on 16/5/26.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportGAS.h"

@implementation SportGAS

#define REVERSAL_STR(str)                                                \
({                                                                       \
    NSUInteger length = [str length];                                    \
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:length];   \
    for(long i=length-1; i>=0; i--) {                                    \
        unichar c = [str characterAtIndex:i];                            \
        [array addObject:[NSString stringWithFormat:@"%c",c]];           \
    }                                                                    \
    NSMutableString *rs = [NSMutableString stringWithCapacity:length];   \
    for(int i=0; i<=length-1; i++)                                       \
    {                                                                    \
        [rs appendString:array[i]];                                      \
    }                                                                    \
    rs;                                                                  \
})

/*
 交替拼接
 */
NSString *__f00__(char *first, char *second) {
    char str[33] = {0};
    int f_len = (int)strlen(first);
    int s_len = (int)strlen(second);
    int max_len = MAX(f_len, s_len);
    for (int i = 0, c = 0; i < max_len; i ++) {
        if (i < f_len) {
            str[c] = first[i];
            c++;
        }
        if (i < s_len) {
            str[c] = second[i];
            c++;
        }
    }
    return [NSString stringWithUTF8String:str];
}


/*
 反转再拼接
 */
NSString *__f01__(char *first, char *second) {
    char str[33] = {0};
    int c = 0;
    for (int i = (int)strlen(first) - 1; i >= 0; i--) {
        str[c] = first[i];
        c++;
    }
    for (int i = (int)strlen(second) - 1; i >= 0; i--) {
        str[c] = second[i];
        c++;
    }
    return [NSString stringWithUTF8String:str];
}

/*
 @return @"d6759"
 */
+ (NSString *)__0x00__
{
    char a[] = "d6";
    char b[] = "759fa4b";
    char c[6] = {0};
    strcat(c, a);
    strncat(c, b, 3);
    return [NSString stringWithUTF8String:c];
}

/*
 @return @"40bfafddd7"
 */
+ (NSString *)__0x00___
{
    const char *start = [REVERSAL_STR([NSString stringWithUTF8String:"afb04"]) cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSString *n = NSStringFromClass([NSNotification class]);
    NSString *fanzhuan = REVERSAL_STR(n);
    NSString *sub = [fanzhuan substringWithRange:NSMakeRange(7, 1)];
    const char *sub_c = [sub cStringUsingEncoding:NSUTF8StringEncoding];
    
    char result[11] = {0};
    strcat(result, start);
    strcat(result, sub_c);
    strcat(result, "ddd7");
    
    return [NSString stringWithUTF8String:result];
}

/*
 @return @"7dc08d"
 */
+ (NSString *)___0x00__
{
    char a[] = "7c8";
    char b[] = "d0d";
    NSString * (*pf)(char * p1, char * p2);
    pf = &__f00__;
    NSString *result = (*pf)(a, b);
    return result;
}

/*
 @return @"da1fe530bfc"
 */
+ (NSString *)___0x00___
{
    char a[] = "ef1ad";
    char b[] = "cfb035";
    NSString * (*pf)(char * p1, char * p2);
    pf = &__f01__;
    NSString *result = (*pf)(a, b);
    return result;
}

/*
 @return @"d67597dddfafb04d80cd7da1fe530bfc" 2.1.0
 */
+ (NSString *)mogui
{
    char m[] = "injo7bg6b91vgybtas5h1p2n6x9bza2m"; //前4位代表拼接顺序，5,10,6,11，偶反奇不反
    NSMutableArray *g = [NSMutableArray arrayWithObjects:[self ___0x00__], nil];
    [g addObject:@"aes"];      //干扰
    [g addObject:[self ___0x00___]];
    [g addObject:@"rsa"];      //干扰
    [g addObject:[self __0x00__]];
    [g addObject:@"md5"];      //干扰
    [g addObject:[self __0x00___]];
    NSMutableString *ms = [[NSMutableString alloc] init];
    for (int i = 0 ; i < strlen(m)/(g.count + 1); i ++) {
        char o = m[i];
        int r = o - 'd';
        for (NSString * a in g) {
            if (a.length == r) {
                NSString *t = nil;
                if (r % 2 == 0) {
                    t = REVERSAL_STR(a);
                } else {
                    t = a;
                }
                [ms appendString:t];
                break;
            }
        }
    }
    return ms;
}

@end
