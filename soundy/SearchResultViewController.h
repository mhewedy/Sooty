//
//  SearchResultViewController.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Util.h"

@interface SearchResultViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate>

@property (nonatomic, strong) NSArray* tracks;

- (void) resetView;
- (long) selectedTrackIndex;
- (void) moveToTrackAt:(int) index;
- (void) markPlayingTrack:(PlaybackStatus) playbackStatus;

@end
