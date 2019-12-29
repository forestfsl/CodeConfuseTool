//
//  SLPerson.m
//  TestCodeConfuse
//
//  Created by songlin on 2019/12/27.
//  Copyright © 2019 toucu. All rights reserved.
//

#import "SLPerson.h"

@implementation SLPerson
- (void)sl_testCodeConfuse{
    NSLog(@"%s", __func__);
}
- (void)sl_setupName:(NSString *)name sl_no:(int)no sl_age:(int)age{
     NSLog(@"%s - %@ %d %d", __func__, name, no, age);
}

@end
