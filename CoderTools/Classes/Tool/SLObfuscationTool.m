//
//  SLObfuscationTool.m
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/17.
//  Copyright © 2018年songlin. All rights reserved.
//

#import "SLObfuscationTool.h"
#import "NSString+Extension.h"
#import "NSFileManager+Extension.h"
#import "SLClangTool.h"

#define SLEncryptKeyVar @"#var#"
#define SLEncryptKeyComment @"#comment#"
#define SLEncryptKeyFactor @"#factor#"
#define SLEncryptKeyValue @"#value#"
#define SLEncryptKeyLength @"#length#"
#define SLEncryptKeyContent @"#content#"

@implementation SLObfuscationTool

+ (NSString *)_encryptStringDataHWithComment:(NSString *)comment
                                         var:(NSString *)var
{
    NSMutableString *content = [NSMutableString string];
    [content appendString:[NSString sl_stringWithFilename:@"SLEncryptStringDataHUnit" extension:@"tpl"]];
    [content replaceOccurrencesOfString:SLEncryptKeyComment
                             withString:comment
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:SLEncryptKeyVar
                             withString:var
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    return content;
}

+ (NSString *)_encryptStringDataMWithComment:(NSString *)comment
                                         var:(NSString *)var
                                      factor:(NSString *)factor
                                       value:(NSString *)value
                                      length:(NSString *)length
{
    NSMutableString *content = [NSMutableString sl_stringWithFilename:@"SLEncryptStringDataMUnit"
                                                            extension:@"tpl"];
    [content replaceOccurrencesOfString:SLEncryptKeyComment
                             withString:comment
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:SLEncryptKeyVar
                             withString:var
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:SLEncryptKeyFactor
                             withString:factor
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:SLEncryptKeyValue
                             withString:value
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:SLEncryptKeyLength
                             withString:length
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    return content;
}

+ (void)encryptString:(NSString *)string
                 completion:(void (^)(NSString *, NSString *))completion
{
    if (string.sl_stringByRemovingSpace.length == 0
        || !completion) return;
    
    // 拼接value
    NSMutableString *value = [NSMutableString string];
    char factor = arc4random_uniform(pow(2, sizeof(char) * 8) - 1);
    const char *cstring = string.UTF8String;
    int length = (int)strlen(cstring);
    for (int i = 0; i< length; i++) {
        [value appendFormat:@"%d,", factor ^ cstring[i]];
    }
    [value appendString:@"0"];
    
    // 变量
    NSString *var = [NSString stringWithFormat:@"_%@", string.sl_crc32];
    
    // 注释
    NSMutableString *comment = [NSMutableString string];
    [comment appendFormat:@"/* %@ */", string];
    
    // 头文件
    NSString *hStr = [self _encryptStringDataHWithComment:comment var:var];
    
    // 源文件
    NSString *mStr = [self _encryptStringDataMWithComment:comment
                                                      var:var
                                                   factor:[NSString stringWithFormat:@"%d", factor]
                                                    value:value
                                                   length:[NSString stringWithFormat:@"%d", length]];
    completion(hStr, mStr);
}

+ (void)encryptStringsAtDir:(NSString *)dir
                         progress:(void (^)(NSString *))progress
                       completion:(void (^)(NSString *, NSString *))completion
{
    if (dir.length == 0 || !completion) return;
    
    !progress ? : progress(@"正在扫描目录...");
    NSArray *subpaths = [NSFileManager sl_subpathsAtPath:dir
                                              extensions:@[@"c", @"cpp", @"m", @"mm"]];
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *subpath in subpaths) {
        !progress ? : progress([NSString stringWithFormat:@"分析：%@", subpath.lastPathComponent]);
        [set addObjectsFromArray:[SLClangTool stringsWithFile:subpath
                                                   searchPath:dir].allObjects];
    }
    
    !progress ? : progress(@"正在加密...");
    NSMutableString *hs = [NSMutableString string];
    NSMutableString *ms = [NSMutableString string];
    
    int index = 0;
    for (NSString *string in set) {
        index++;
        [self encryptString:string completion:^(NSString *h, NSString *m) {
            [hs appendFormat:@"%@", h];
            [ms appendFormat:@"%@", m];
            
            if (index != set.count) {
                [hs appendString:@"\n"];
                [ms appendString:@"\n"];
            }
        }];
    }
    
    !progress ? : progress(@"加密完毕!");
    
    NSMutableString *hFileContent = [NSMutableString sl_stringWithFilename:@"SLEncryptStringDataH" extension:@"tpl"];
    [hFileContent replaceOccurrencesOfString:SLEncryptKeyContent withString:hs options:NSCaseInsensitiveSearch range:NSMakeRange(0, hFileContent.length)];
    NSMutableString *mFileContent = [NSMutableString sl_stringWithFilename:@"SLEncryptStringDataM" extension:@"tpl"];
    [mFileContent replaceOccurrencesOfString:SLEncryptKeyContent withString:ms options:NSCaseInsensitiveSearch range:NSMakeRange(0, mFileContent.length)];
    completion(hFileContent, mFileContent);
}

+ (void)obfuscateAtDir:(NSString *)dir
                    prefixes:(NSArray *)prefixes
                    progress:(void (^)(NSString *))progress
                  completion:(void (^)(NSString *))completion
{
    if (dir.length == 0 || !completion) return;
    
    !progress ? : progress(@"正在扫描目录...");
    NSArray *subpaths = [NSFileManager sl_subpathsAtPath:dir extensions:@[@"m", @"mm"]];
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *subpath in subpaths) {
        !progress ? : progress([NSString stringWithFormat:@"分析：%@", subpath.lastPathComponent]);
        [set addObjectsFromArray:
         [SLClangTool classesAndMethodsWithFile:subpath
                                       prefixes:prefixes
                                     searchPath:dir].allObjects];
    }
    
    !progress ? : progress(@"正在混淆...");
    NSMutableString *fileContent = [NSMutableString string];
    [fileContent appendString:@"#ifndef SLCodeObfuscation_h\n"];
    [fileContent appendString:@"#define SLCodeObfuscation_h\n"];
    NSMutableArray *obfuscations = [NSMutableArray array];
    for (NSString *token in set) {
        NSString *obfuscation = nil;
        while (!obfuscation || [obfuscations containsObject:obfuscation]) {
            obfuscation = [NSString sl_randomStringWithoutDigitalWithLength:16];
        }
        
        [fileContent appendFormat:@"#define %@ %@\n", token, obfuscation];
    }
    [fileContent appendString:@"#endif"];
    
    !progress ? : progress(@"混淆完毕!");
    completion(fileContent);
}

@end
