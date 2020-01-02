//
//  SLEncryptString.m
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/18.
//  Copyright © 2018年songlin. All rights reserved.
//

#import "SLEncryptString.h"

const char *sl_CString(const SLEncryptStringData *data)
{
    if (data->decoded == 1) return data->value;
    for (int i = 0; i < data->length; i++) {
        data->value[i] ^= data->factor;
    }
    ((SLEncryptStringData *)data)->decoded = 1;
    return data->value;
}

NSString *sl_OCString(const SLEncryptStringData *data)
{
    return [NSString stringWithUTF8String:sl_CString(data)];
}
