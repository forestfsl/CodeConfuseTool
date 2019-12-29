//
//  NSString+Extension.m
//  CodeObfuscation
//
//  Created by songlin on 2018/8/16.
//  Copyright © 2018年songlin. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>

@implementation NSString (Extension)

- (NSString *)sl_MD5
{
    if (self.length == 0) return nil;
    const char *string = self.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

+ (instancetype)sl_randomStringWithoutDigitalWithLength:(int)length
{
    if (length <= 0) return nil;
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
    NSMutableString *string = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        uint32_t index = arc4random_uniform((uint32_t)letters.length);
        unichar c = [letters characterAtIndex:index];
        [string appendFormat:@"%C", c];
    }
    return string;
}

- (instancetype)sl_stringByRemovingSpace
{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSArray *)sl_componentsSeparatedBySpace
{
    if (self.sl_stringByRemovingSpace.length == 0) return nil;
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (instancetype)sl_stringWithFilename:(NSString *)filename
                            extension:(NSString *)extension
{
    if (filename.sl_stringByRemovingSpace.length == 0) return nil;
    
    return [self stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:filename withExtension:extension] encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)sl_crc32
{
    if (self.length == 0) return nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uLong crc = crc32(0L, Z_NULL, 0);
    crc = crc32(crc, data.bytes, (uInt)data.length);
    return [NSString stringWithFormat:@"%lu", crc];
}
@end
