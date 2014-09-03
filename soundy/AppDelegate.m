//
//  AppDelegate.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/3/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet NSSlider *timeSlider;
@property (weak) IBOutlet NSSlider *volumeSlider;

@property (strong) AVAudioPlayer *audioPlayer;
@property (strong) NSTimer *timeSliderTimer;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // TEST
    [self.playPauseButton setEnabled:YES];
    [self.timeSlider setEnabled:YES];
    [self.volumeSlider setEnabled:YES];
    //~
    
    NSError* error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:@"/Users/mhewedy/Downloads/69y19mo9Tfzy.128.mp3"] error:&error];
    self.audioPlayer.delegate = self;
    
    self.timeSlider.minValue = 0;
    self.timeSlider.maxValue = self.audioPlayer.duration;
    
    self.timeSliderTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTimeSlider) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timeSliderTimer forMode:NSDefaultRunLoopMode];
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)timeSliderAction:(id)sender {
    self.audioPlayer.currentTime = self.timeSlider.doubleValue;
}

- (IBAction)volumeSliderAction:(id)sender {
    self.audioPlayer.volume = self.volumeSlider.floatValue;
}

- (void) updateTimeSlider{
    self.timeSlider.doubleValue = self.audioPlayer.currentTime;
}

- (IBAction)play:(id)sender {
    
    if (!self.audioPlayer.playing){
        [self.audioPlayer play];
        self.playPauseButton.title = @"Pause";
    }else{
        [self.audioPlayer pause];
        self.playPauseButton.title = @"Play";
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.playPauseButton.title = @"Play";
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    self.playPauseButton.title = @"Play";
}

@end
