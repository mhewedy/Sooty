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
#import "SPMediaKeyTap.h"
#import "SearchResultViewController.h"
#import "DBUtil.h"


@implementation SootyApp
- (void)sendEvent:(NSEvent *)theEvent
{
    // If event tap is not installed, handle events that reach the app instead
    BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    
    if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined
        && [theEvent subtype] == SPSystemDefinedEventMediaKeys)
    {
        [(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
    }
    [super sendEvent:theEvent];
}
@end


@interface AppDelegate ()

@property (weak) IBOutlet NSStackView *stackView;

@property (weak) IBOutlet NSView *playerView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) SoundApi* soundApi;

@property (strong) AudioPlayer* audioPlayer;
@property (strong) SearchResultViewController* searchResultVC;
@property (strong) NSString* currentPlaylist;

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
    [self.listVC selectDefaultPlaylist];
    
    [self.stackView addSubview:self.listVC.view];
    [self.stackView addSubview:self.searchResultVC.view];
    
    [[self.searchField cell] setPlaceholderString:[NSString stringWithFormat:@"Search %@", self.soundApi.name]];
    
    if([SPMediaKeyTap usesGlobalMediaKeyTap]) {
        [[[SPMediaKeyTap alloc] initWithDelegate:self] startWatchingMediaKeys];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
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
    
//    [self.audioPlayer resetPlayer];
    
    self.listVC.playlists[SearchResultsPlaylist] = results;
    [self.listVC selectDefaultPlaylist];

    [self setSearchResult:results playlistName:SearchResultsPlaylist];
}

- (void) setSearchResult:(NSArray*) results playlistName:(NSString*) playlistName{

    self.searchResultVC.tracks = results;
    self.searchResultVC.playlistName = playlistName;

    self.audioPlayer.tracks = results;
    self.currentPlaylist = playlistName;
    
    [self enableDisablePlayerView:results forceDisable:NO];
}

#pragma mark - UI Control actions

- (IBAction)playPauseAction:(id)sender {
    [self play:(int)[self.searchResultVC selectedTrackIndex] forcePlay:NO];
}

- (IBAction)playNextAction:(id)sender {
    int trackId = [self.audioPlayer playNext:sender?YES:NO];

    if (trackId != NoRecordsPlayedYet){
        [self.searchResultVC moveToTrackAt:trackId];
    }
}

- (IBAction)playPrevAction:(id)sender {
    int trackId = [self.audioPlayer playPrev:sender?YES:NO];
    
    if (trackId != NoRecordsPlayedYet){
        [self.searchResultVC moveToTrackAt:trackId];
    }
}

- (IBAction)volumeSliderAction:(id)sender {
    [self.audioPlayer adjustVolume:[[self.playerView viewWithTag:PlayerViewVolumeSlider] doubleValue]];
}

- (IBAction)timeSliderAction:(id)sender {
    [self.audioPlayer seekToTime:[[self.playerView viewWithTag:PlayerViewTimeSlider] doubleValue]];
}

- (void) play:(int) trackIndex forcePlay:(BOOL)forcePlay{
    self.audioPlayer.playlistName = self.currentPlaylist;
    [self.audioPlayer play:trackIndex forcePlay:forcePlay];
}

#pragma mark - Util

- (void) markPlayingTrack:(PlaybackStatus) playbackStatus{
    [self.searchResultVC markPlayingTrack:playbackStatus];
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

-(void) resetPlaylists{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PlaylistPersistenceKeyPlaylistDictionary];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PlaylistPersistenceKeyPlaylistKeys];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PlaylistPersistenceKeyPlaylistNumber];

}

#pragma mark - SPMediaKeyTap

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
    NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
    // here be dragons...
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    int keyRepeat = (keyFlags & 0x1);
    
    if (keyIsPressed) {
        NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                [self playPauseAction:nil];
                NSLog(@"NX_KEYTYPE_PLAY");
                break;
            case NX_KEYTYPE_FAST:
                [self playNextAction:nil];
                NSLog(@"NX_KEYTYPE_FAST");
                break;
            case NX_KEYTYPE_REWIND:
                [self playPrevAction:nil];
                NSLog(@"NX_KEYTYPE_REWIND");
                break;
            default:
                debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
                break;
                // More cases defined in hidsystem/ev_keymap.h
        }
        NSLog(@"%@", debugString);
    }
}

#pragma mark - NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
