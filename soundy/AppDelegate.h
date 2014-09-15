//
//  AppDelegate.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/3/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "ListViewController.h"
#import "NSObject+Util.h"



#define SootyAppDelegate ((AppDelegate*)[NSApplication sharedApplication].delegate)

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (strong) ListViewController* listVC;

- (IBAction)playNextAction:(id)sender;

- (void) play:(int) trackIndex forcePlay:(BOOL)forcePlay;
- (void) markPlayingTrack:(PlaybackStatus) playbackStatus;
- (void) setSearchResult:(NSArray*) results playlistName:(NSString*) playlistName;

@end

