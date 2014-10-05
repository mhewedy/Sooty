//
//  NSObject+Util.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "NSObject+Util.h"
#import "AppDelegate.h"
#import "Track.h"

@implementation NSObject (Util)

-(void)alert:(NSWindow*) window withMessage: (NSString*) msg
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Sooty"];
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(void)alert:(NSString*) msg{
    NSWindow* window = [(AppDelegate *)[[NSApplication sharedApplication] delegate] window];
    [self alert:window withMessage:msg];
}

- (void) showNotification:(NSString*) playStatus aboutTrack:(Track*) track{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Sooty";
    notification.subtitle = track.title;
    notification.contentImage = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:track.artworkURL]];
    
//    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}


@end
