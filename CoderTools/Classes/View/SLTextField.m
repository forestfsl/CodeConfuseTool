//
//  SLTextField.m
//  SLCodeObfuscation
//
//  Created by songlin on 2018/8/17.
//  Copyright © 2018年songlin. All rights reserved.
//

#import "SLTextField.h"

@implementation SLTextField

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    if ((event.modifierFlags & NSEventModifierFlagDeviceIndependentFlagsMask) == NSEventModifierFlagCommand) {
        NSString *str = event.charactersIgnoringModifiers;
        SEL selector = nil;
        if ([str isEqualToString:@"x"]) {
            selector = @selector(cut:);
        } else if ([str isEqualToString:@"c"]) {
            selector = @selector(copy:);
        } else if ([str isEqualToString:@"v"]) {
            selector = @selector(paste:);
        } else if ([str isEqualToString:@"a"]) {
            selector = @selector(selectAll:);
        } else if ([str isEqualToString:@"z"]) {
            selector = @selector(keyDown:);
        }
        return [NSApp sendAction:selector to:self.window.firstResponder from:self];
    }
    return [super performKeyEquivalent:event];
}

@end
