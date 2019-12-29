//
//  NSString+Extension.h
//  CodeObfuscation
//
//  Created by songlin on 2018/8/16.
//  Copyright © 2018年songlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/** 生成length长度的随机字符串（不包含数字） */
+ (instancetype)sl_randomStringWithoutDigitalWithLength:(int)length;

/** 去除空格 */
- (instancetype)sl_stringByRemovingSpace;

/** 将字符串用空格分割成数组 */
- (NSArray *)sl_componentsSeparatedBySpace;

/** 从mainBundle中加载文件数据 */
+ (instancetype)sl_stringWithFilename:(NSString *)filename
                            extension:(NSString *)extension;

/** 生成MD5 */
- (NSString *)sl_MD5;

/** 生成crc32 */
- (NSString *)sl_crc32;

@end
