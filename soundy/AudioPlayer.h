//
//  AudioPlayer.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@import AppKit.NSSlider;
@import AppKit.NSButton;
@import AppKit.NSProgressIndicator;

/**
 todo implement :
    1. user change the play location through timeSlider
    2. user change the volume through volumnSlider
 */
@interface AudioPlayer : NSObject


@property (weak) NSSlider* timeSlider;
@property (weak) NSButton* playPauseButton;
@property (weak) NSButton* playNextButton;
@property (weak) NSButton* playPrevButton;
@property (weak) NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) NSArray* tracks;
@property (readonly) int currentTrackIndex;


- (void) play:(int) trackIndex;
- (void) playPauseAction:(id)sender;
- (void) playNextAction:(id) sender;
- (void) playPrevAction:(id) sender;

@end
