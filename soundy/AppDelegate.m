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

@interface AppDelegate ()

@property (weak) IBOutlet NSButton *playPauseButton;
@property (weak) IBOutlet NSSlider *timeSlider;
@property (weak) IBOutlet NSSlider *volumeSlider;

@property (strong) AVAudioPlayer *audioPlayer;
@property (strong) NSTimer *timeSliderTimer;

@property (strong) SoundApi* soundApi;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // TEST
    [self.playPauseButton setEnabled:YES];
    [self.timeSlider setEnabled:YES];
    [self.volumeSlider setEnabled:YES];
    [self playURL:@"/Users/mhewedy/Downloads/69y19mo9Tfzy.128.mp3"];
    //~
    
    // init SoundApi
    self.soundApi = [[SoundCloudApi alloc]init];
    
    // init slider timer
    self.timeSliderTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTimeSlider) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timeSliderTimer forMode:NSDefaultRunLoopMode];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


-(void) playURL:(NSString*) URLString{
    NSError* error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:URLString] error:&error];
    self.audioPlayer.delegate = self;
    
    self.timeSlider.minValue = 0;
    self.timeSlider.maxValue = self.audioPlayer.duration;
    
    if (error != nil){
        [self alert:self.window withMessage:error.localizedDescription];
    }
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
    [self stopPlayer];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [self alert:self.window withMessage:error.localizedDescription];
    [self stopPlayer];
}
- (void) stopPlayer{
    self.playPauseButton.title = @"Play";
    [self.audioPlayer stop];
}


@end
