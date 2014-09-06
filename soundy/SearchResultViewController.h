//
//  SearchResultViewController.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SearchResultViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSArray* tracks;

- (void) resetView;
- (long) selectedTrackIndex;
- (void) moveToNext;
- (void) moveToPrev;

@end
