//
//  SLEncryptString.h
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/18.
//  Copyright © 2018年songlin. All rights reserved.
//

#ifndef SLEncryptString_h
#define SLEncryptString_h

typedef struct {
    char factor;
    char *value;
    int length;
    char decoded;
} SLEncryptStringData;

const char *sl_CString(const SLEncryptStringData *data);

#ifdef __OBJC__
#import <Foundation/Foundation.h>
NSString *sl_OCString(const SLEncryptStringData *data);
#endif

#endif
