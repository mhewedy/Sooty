//
//  AppDelegate.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/3/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "AppDelegate.h"
#import "NSObject+Util.h"
#import "AudioPlayer.h"
#import "SoundCloudApi.h"

#import "SearchResultViewController.h"
#import "ListViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSView *playerView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) AudioPlayer* audioPlayer;
@property (strong) SoundApi* soundApi;

@property (strong) SearchResultViewController* searchResultVC;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self.window makeFirstResponder:self.searchField];

    self.audioPlayer = [[AudioPlayer alloc]init];
    self.audioPlayer.playerView = self.playerView;
    self.audioPlayer.progressIndicator = self.progressIndicator;
    
    self.soundApi = [[SoundCloudApi alloc]init];
    self.soundApi.searchCallbackTarget = self;
    self.soundApi.searchCallbackSelector = @selector(searchResultReturned:);
    
    self.searchResultVC = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
    self.window.contentView = self.searchResultVC.view;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Search Field
- (IBAction)searchAction:(id)sender {
    [self.progressIndicator startAnimation:self];
    [self.searchResultVC resetView];
    [self.soundApi search:self.searchField.stringValue];
}

-(void) searchResultReturned:(NSArray*) results{
    [self.progressIndicator stopAnimation:self];
    self.searchResultVC.tracks = results;
    self.audioPlayer.tracks = results;
}

#pragma mark - UI Control actions

- (IBAction)temp:(id)sender {
    [self.audioPlayer playPauseAction:sender];
}

@end
