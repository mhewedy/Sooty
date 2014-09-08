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
#import "SootyServiceApi.h"

#import "SearchResultViewController.h"
#import "ListViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSView *playerView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) SoundApi* soundApi;

@property (strong) AudioPlayer* audioPlayer;
@property (strong) SearchResultViewController* searchResultVC;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self.window makeFirstResponder:self.searchField];

    self.audioPlayer = [[AudioPlayer alloc]init];
    self.audioPlayer.playerView = self.playerView;
    self.audioPlayer.progressIndicator = self.progressIndicator;
    
    self.soundApi = [[SootyServiceApi alloc]init];
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
    
    if ([self.searchField.stringValue isEqualTo:@""]){
        return;
    }
    
    [self.progressIndicator startAnimation:self];
    
    [self.searchResultVC resetView];
    [self.soundApi search:self.searchField.stringValue];
}

-(void) searchResultReturned:(NSArray*) results{
    [self.progressIndicator stopAnimation:self];
    
    self.searchResultVC.tracks = results;
    self.audioPlayer.tracks = results;
    [self enableDisablePlayerView:results];
}

#pragma mark - UI Control actions

- (IBAction)playPauseAction:(id)sender {
    [self.audioPlayer play:(int)[self.searchResultVC selectedTrackIndex] nextPrev:NO];
}

- (IBAction)playNextAction:(id)sender {
    [self.searchResultVC moveToNext];
    [self.audioPlayer play:(int)[self.searchResultVC selectedTrackIndex] nextPrev:YES];
}

- (IBAction)playPrevAction:(id)sender {
    [self.searchResultVC moveToPrev];
    [self.audioPlayer play:(int)[self.searchResultVC selectedTrackIndex] nextPrev:YES];
}

- (IBAction)volumeSliderAction:(id)sender {
    [self.audioPlayer adjustVolume:[[self.playerView viewWithTag:PlayerViewVolumeSlider] doubleValue]];
}

- (IBAction)timeSliderAction:(id)sender {
    [self.audioPlayer seekToTime:[[self.playerView viewWithTag:PlayerViewTimeSlider] doubleValue]];
}

#pragma mark - Util

-(void) enableDisablePlayerView:(NSArray*) tracks{

    BOOL playEnabled = NO, otherEnabled = NO;
    if (tracks.count > 0){
        playEnabled = YES;
        if (tracks.count > 1){
            otherEnabled = YES;
        }
    }
    [[self.playerView viewWithTag:PlayerViewPlayPauseButton] setEnabled:playEnabled];
    [[self.playerView viewWithTag:PlayerViewTimeSlider] setEnabled:playEnabled];
    [[self.playerView viewWithTag:PlayerViewVolumeSlider] setEnabled:playEnabled];
    [[self.playerView viewWithTag:PlayerViewPlayNextButton] setEnabled:otherEnabled];
    [[self.playerView viewWithTag:PlayerViewPlayPrevButton] setEnabled:otherEnabled];
}

@end
