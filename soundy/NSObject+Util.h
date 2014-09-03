//
//  NSObject+Util.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AppKit.NSWindow;
@import AppKit.NSAlert;

@interface NSObject (Util)

-(void)alert:(NSWindow*) window withMessage: (NSString*) msg;

@end
