//
//  SLDividerView.m
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/18.
//  Copyright © 2018年songlin. All rights reserved.
//

#import "SLDividerView.h"

@implementation SLDividerView

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    }
    return self;
}

@end
