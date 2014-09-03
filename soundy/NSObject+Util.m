//
//  NSObject+Util.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "NSObject+Util.h"


@implementation NSObject (Util)

-(void)alert:(NSWindow*) window withMessage: (NSString*) msg
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Alert"];
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
