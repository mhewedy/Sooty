//
//  AudioPlayer.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerViewHelper.h"

@import AppKit.NSSlider;
@import AppKit.NSButton;
@import AppKit.NSProgressIndicator;

@interface AudioPlayer : NSObject

@property (weak) NSView* playerView;
@property (weak) NSProgressIndicator *progressIndicator;

@property (strong) NSArray* tracks;
@property (readonly) int currentTrackIndex;


- (void) play:(int) trackIndex;
- (void) seekToTime:(double) time;

@end
