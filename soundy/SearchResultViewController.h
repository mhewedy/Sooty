//
//  SearchResultViewController.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Util.h"

@interface SearchResultViewController : NSViewController <NSTableViewDataSource, NSMenuDelegate>

@property (nonatomic, strong) NSArray* tracks;
@property (nonatomic, strong) NSString* playlist;

- (long) selectedTrackIndex;
- (void) markPlayingTrack:(PlaybackStatus) playbackStatus;

@end
