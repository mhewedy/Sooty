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

@interface SootyApp : NSApplication
@end


@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (strong) ListViewController* listVC;

- (IBAction)playNextAction:(id)sender;

- (void) play:(int) trackIndex forcePlay:(BOOL)forcePlay;
- (void) markPlayingTrack:(PlaybackStatus) playbackStatus;
- (void) setSearchResult:(NSArray*) results playlist:(NSString*) playlist updatePlayer:(BOOL)updatePlayer;
- (void) setAudioPlayerTracks:(NSArray*) tracks playlist:(NSString*) playlist;

- (void) startProgress;
- (void) stopProgress;

@end

