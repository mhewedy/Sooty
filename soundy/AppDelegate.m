//
//  AppDelegate.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/3/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioPlayer.h"
#import "SoundCloudApi.h"
#import "SootyServiceApi.h"

#import "SearchResultViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSStackView *stackView;

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
    
    self.soundApi = [[SoundCloudApi alloc]init];
    self.soundApi.searchCallbackTarget = self;
    self.soundApi.searchCallbackSelector = @selector(searchResultReturned:);
    
    self.searchResultVC = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
    self.listVC = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
    
    [self.stackView addSubview:self.listVC.view];
    [self.stackView addSubview:self.searchResultVC.view];
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
    [self.soundApi search:self.searchField.stringValue];

    [self enableDisablePlayerView:nil forceDisable:YES];
}

-(void) searchResultReturned:(NSArray*) results{
    [self.progressIndicator stopAnimation:self];
    self.listVC.playlists[SearchResultsPlaylist] = results;

    [self setSearchResult:results playlistName:SearchResultsPlaylist];
}

- (void) setSearchResult:(NSArray*) results playlistName:(NSString*) playlistName{
    self.searchResultVC.tracks = results;
    self.searchResultVC.myPlaylistName = playlistName;
    self.audioPlayer.tracks = results;
    
    [self enableDisablePlayerView:results forceDisable:NO];
}

#pragma mark - UI Control actions

- (IBAction)playPauseAction:(id)sender {
    [self play:(int)[self.searchResultVC selectedTrackIndex] forcePlay:NO];
}

- (IBAction)playNextAction:(id)sender {
    int trackId = [self.audioPlayer playNext:sender?YES:NO];
    [self.searchResultVC moveToTrackAt:trackId];
}

- (IBAction)playPrevAction:(id)sender {
    int trackId = [self.audioPlayer playPrev:sender?YES:NO];
    [self.searchResultVC moveToTrackAt:trackId];
}

- (IBAction)volumeSliderAction:(id)sender {
    [self.audioPlayer adjustVolume:[[self.playerView viewWithTag:PlayerViewVolumeSlider] doubleValue]];
}

- (IBAction)timeSliderAction:(id)sender {
    [self.audioPlayer seekToTime:[[self.playerView viewWithTag:PlayerViewTimeSlider] doubleValue]];
}

#pragma mark - Util

- (void) markPlayingTrack:(PlaybackStatus) playbackStatus{
    [self.searchResultVC markPlayingTrack:playbackStatus];
}

- (void) play:(int) trackIndex forcePlay:(BOOL)forcePlay{
    [self.audioPlayer play:trackIndex forcePlay:forcePlay];
}

- (void) enableDisablePlayerView:(NSArray*) tracks forceDisable:(BOOL) forceDisable{

    BOOL playEnabled = NO, otherEnabled = NO;
    if (tracks.count > 0){
        playEnabled = YES;
        if (tracks.count > 1){
            otherEnabled = YES;
        }
    }
    [[self.playerView viewWithTag:PlayerViewPlayPauseButton] setEnabled:!forceDisable && playEnabled];
    [[self.playerView viewWithTag:PlayerViewTimeSlider] setEnabled:!forceDisable && playEnabled];
    [[self.playerView viewWithTag:PlayerViewVolumeSlider] setEnabled:!forceDisable && playEnabled];
    [[self.playerView viewWithTag:PlayerViewPlayNextButton] setEnabled:!forceDisable && otherEnabled];
    [[self.playerView viewWithTag:PlayerViewPlayPrevButton] setEnabled:!forceDisable && otherEnabled];
}

@end
