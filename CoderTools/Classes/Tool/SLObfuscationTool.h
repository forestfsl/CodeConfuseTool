//
//  SLObfuscationTool.h
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/17.
//  Copyright © 2018年songlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLObfuscationTool : NSObject

/** 加密字符串 */
+ (void)encryptString:(NSString *)string
           completion:(void (^)(NSString *h, NSString *m))completion;

/** 加密dir下的所有字符串 */
+ (void)encryptStringsAtDir:(NSString *)dir
                   progress:(void (^)(NSString *detail))progress
                 completion:(void (^)(NSString *h, NSString *m))completion;

/** 混淆dir下的所有类名、方法名 */
+ (void)obfuscateAtDir:(NSString *)dir
              prefixes:(NSArray *)prefixes
              progress:(void (^)(NSString *detail))progress
            completion:(void (^)(NSString *fileContent))completion;

@end
