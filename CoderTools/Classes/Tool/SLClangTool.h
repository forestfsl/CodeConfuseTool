//
//  SLClangTool.h
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/17.
//  Copyright © 2018年songlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLClangTool : NSObject

/** 获得file中的所有字符串 */
+ (NSSet *)stringsWithFile:(NSString *)file
                searchPath:(NSString *)searchPath;

/** 获得file中的所有类名、方法名） */
+ (NSSet *)classesAndMethodsWithFile:(NSString *)file
                            prefixes:(NSArray *)prefixes
                          searchPath:(NSString *)searchPath;

@end
