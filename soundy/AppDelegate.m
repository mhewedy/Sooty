//
//  AppDelegate.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/3/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "AppDelegate.h"
#import "NSObject+Util.h"
#import "SoundCloudApi.h"
#import "SearchResultViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet NSSlider *timeSlider;
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSButton *prevButton;
@property (weak) IBOutlet NSButton *nextButton;

@property (weak) IBOutlet NSSearchField *searchField;

@property (strong) AVPlayer *player;

@property (strong) SoundApi* soundApi;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.soundApi = [[SoundCloudApi alloc]init];
    self.soundApi.searchCallbackTarget = self;
    self.soundApi.searchCallbackSelector = @selector(searchResultReturned:);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


#pragma mark - Search Field
- (IBAction)searchAction:(id)sender {
    

    [self.soundApi search:self.searchField.stringValue];
}

-(void) searchResultReturned:(NSArray*) results{
    
    if (results && [results count] > 0){
        SearchResultViewController* searchVC = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
        searchVC.results = results;
        self.window.contentView = searchVC.view;
        [self enablePlayerContorls:YES nextAndPrevButtons:[results count] > 1];
        
        [self dispatchURLForPlay:((Track*)results[0]).streamURL];
        
    }else{
        [self alert:@"no resutls found"];
        [self enablePlayerContorls:NO nextAndPrevButtons:YES];
    }
}

#pragma mark - AVAudioPlayer and related controls and callbacks

-(void) dispatchURLForPlay:(NSString*) URLString{
    NSError* error = nil;
    
    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:URLString]];
    
    if (error != nil){
        [self alert:self.window withMessage:error.localizedDescription];
    }else{
//        self.audioPlayer.delegate = self;
        self.timeSlider.minValue = 0;
        self.timeSlider.maxValue = self.player.currentItem.duration.value;
    }
}

- (IBAction)timeSliderAction:(id)sender {
//    self.audioPlayer.currentTime = self.timeSlider.doubleValue;
}

- (IBAction)volumeSliderAction:(id)sender {
//    self.audioPlayer.volume = self.volumeSlider.floatValue;
}

- (void) updateTimeSlider{
//    self.timeSlider.doubleValue = self.audioPlayer.currentTime;
}

- (IBAction)play:(id)sender {
    [self.player play];
//    if (!self.player.status){
//        [self.player play];
//        self.playPauseButton.title = @"Pause";
//    }else{
//        [self.audioPlayer pause];
//        self.playPauseButton.title = @"Play";
//    }
}

//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    [self stopPlayer];
//}
//
//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
//    [self alert:self.window withMessage:error.localizedDescription];
//    [self stopPlayer];
//}
//- (void) stopPlayer{
//    self.playPauseButton.title = @"Play";
//    [self.audioPlayer stop];
//}

- (void) enablePlayerContorls:(BOOL) enable nextAndPrevButtons:(BOOL) applyForNextAndPrev{
    
    [self.playPauseButton setEnabled:enable];
    [self.timeSlider setEnabled:enable];
    [self.volumeSlider setEnabled:enable];
    
    if (applyForNextAndPrev){
        [self.prevButton setEnabled:enable];
        [self.nextButton setEnabled:enable];
    }
}


@end
