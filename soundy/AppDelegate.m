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
#import "AudioPlayer.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet NSSlider *timeSlider;
@property (weak) IBOutlet NSSlider *volumeSlider;
@property (weak) IBOutlet NSButton *prevButton;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSSearchField *searchField;

@property (strong) AudioPlayer* audioPlayer;
@property (strong) SoundApi* soundApi;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    Track* track1 = [[Track alloc]init];
    track1.streamURL = @"https://api.soundcloud.com/tracks/67451811/stream?client_id=85652ec093beadb4c647450f597b16ad";
//    track1.streamURL = @"/Users/mhewedy/Downloads/69y19mo9Tfzy.128.mp3";
    NSArray* tracks = @[track1];
    
    self.audioPlayer = [[AudioPlayer alloc]init];
    self.audioPlayer.playPauseButton = self.playPauseButton;
    self.audioPlayer.timeSlider = self.timeSlider;
    self.audioPlayer.tracks = tracks;
    [self.audioPlayer play:0];
    
    
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
    
    if (results.count > 0){
        
        SearchResultViewController* searchVC = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
        searchVC.results = results;
        self.window.contentView = searchVC.view;
//        [self enablePlayerContorls:YES nextAndPrevButtons:[results count] > 1];
        
//        [self dispatchURLForPlay:((Track*)results[0]).streamURL];
        
    }else{
//        [self enablePlayerContorls:NO nextAndPrevButtons:YES];
    }
}

#pragma mark - AVAudioPlayer and related controls and callbacks

//-(void) dispatchURLForPlay:(NSString*) URLString{
//    NSError* error = nil;
//    
//    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:URLString]];
//    
//    if (error != nil){
//        [self alert:self.window withMessage:error.localizedDescription];
//    }else{
////        self.audioPlayer.delegate = self;
//        self.timeSlider.minValue = 0;
//        self.timeSlider.maxValue = self.player.currentItem.duration.value;
//    }
//}
//
//- (IBAction)timeSliderAction:(id)sender {
////    self.audioPlayer.currentTime = self.timeSlider.doubleValue;
//}
//
//- (IBAction)volumeSliderAction:(id)sender {
//    self.player.volume = self.volumeSlider.floatValue;
//}


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

//- (void) enablePlayerContorls:(BOOL) enable nextAndPrevButtons:(BOOL) applyForNextAndPrev{
//    
//    [self.playPauseButton setEnabled:enable];
//    [self.timeSlider setEnabled:enable];
//    [self.volumeSlider setEnabled:enable];
//    
//    if (applyForNextAndPrev){
//        [self.prevButton setEnabled:enable];
//        [self.nextButton setEnabled:enable];
//    }
//}

- (IBAction)temp:(id)sender {
    [self.audioPlayer playPauseAction:sender];
}

@end
