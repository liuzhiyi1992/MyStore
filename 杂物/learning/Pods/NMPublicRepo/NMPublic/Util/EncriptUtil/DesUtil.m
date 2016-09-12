//
//  DesUtil.m
//  Sport
//
//  Created by haodong  on 14-4-28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DesUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "DDBase64.h"

@implementation DesUtil


//const NSString *key = @"20140401";
//const NSString *iv = @"12345678";

+ (NSString *)encryptUseDES:(NSString *)plainText
                       key:(NSString *)key
                        iv:(NSString *)iv
{
    NSData* ivData = [iv dataUsingEncoding: NSUTF8StringEncoding];
    Byte *ivBytes = (Byte *)[ivData bytes];
    NSString *ciphertext = nil;
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          ivBytes,
                                          [textData bytes], dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [DDBase64 encodeBase64Data:data];
    }
    return ciphertext;
}

+ (NSString *)decryptUseDES:(NSString *)cipherText
                        key:(NSString *)key
                         iv:(NSString *)iv
{
    NSData* ivData = [iv dataUsingEncoding: NSUTF8StringEncoding];
    Byte *ivBytes = (Byte *)[ivData bytes];
    NSString *plaintext = nil;
    NSData *cipherdata = [DDBase64 toDataDecodeBase64String:cipherText];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          ivBytes,
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, 1024,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding] ;
    }
    return plaintext;
}


@end
