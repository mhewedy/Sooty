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

@property (nonatomic, strong) NSArray* tracks;
@property (readonly) int currentTrackIndex;


- (void) seekToTime:(double) time;
- (void) adjustVolume:(double) volume;


- (void) play:(int) trackIndex forcePlay:(BOOL) forcePlay;
- (int) playNext:(BOOL) byUserClick;
- (int) playPrev:(BOOL) byUserClick;
- (void) resetPlayer;

@end
