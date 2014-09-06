//
//  AudioPlayer.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "AudioPlayer.h"
#import "Track.h"

static void *AVPlayerRateContext = &AVPlayerRateContext;
static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface AudioPlayer ()

@property (weak) NSButton* playPauseButton;
@property (weak) NSButton* playNextButton;
@property (weak) NSButton* playPrevButton;
@property (weak) NSSlider* timeSlider;
@property (weak) NSSlider* volumeSlider;

@property (strong) AVPlayer* player;
@property (strong) id timeObserverToken;

@property (assign) int currentTrackIndex;
@property (assign) double currentTime;
@property (readonly) double duration;
@property (assign) float volume;

@end

@implementation AudioPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.player = [[AVPlayer alloc]init];
        [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:AVPlayerRateContext];
        [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    }
    return self;
}

#pragma - mark Public APIs

- (void) play:(int) trackIndex{
    if (self.tracks == nil){
        NSLog(@"tracks should be set before call play");
        return;
    }
    
    [self prepareTrack:trackIndex];
    [self play];
}

- (void) playNext{
    [self play:++self.currentTrackIndex];
}

- (void) playPrev{
    [self play:--self.currentTrackIndex];
}

#pragma - mark Custome propreties

- (void) setPlayerView:(NSView *)myPlayerView{
    _playerView = myPlayerView;
    
    self.playPauseButton    = [self.playerView viewWithTag:1];
    self.playNextButton     = [self.playerView viewWithTag:2];
    self.playPrevButton     = [self.playerView viewWithTag:3];
    self.timeSlider         = [self.playerView viewWithTag:6];
    self.volumeSlider       = [self.playerView viewWithTag:4];
}

#pragma - mark Obeserver callback

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVPlayerRateContext) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate != 1.f){
            self.playPauseButton.title = @"Play";
        }else{
            self.playPauseButton.title = @"Pause";
        }
    } else if (context == AVPlayerItemStatusContext) {
        
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusFailed){
            [self handelPlaybackError:[[[self player] currentItem] error]];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma - mark Play methods

- (void) prepareTrack:(int) trackIndex{
    
    [self.progressIndicator startAnimation:self];
    Track* currentTrack = [self trackAtIndex:trackIndex];
    AVURLAsset* asset = [AVAsset assetWithURL:[NSURL URLWithString:currentTrack.streamURL]];
    NSArray* assetKeys = @[@"playable", @"hasProtectedContent", @"tracks"];
    
    [asset loadValuesAsynchronouslyForKeys:assetKeys completionHandler:^(void){
        
        [self.progressIndicator stopAnimation:self];
        [self enableDisableControls];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            for (NSString *key in assetKeys){
                NSError *error = nil;
                if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed){
                    [self handelPlaybackError:error];
                    return;
                }
            }
            if (![asset isPlayable] || [asset hasProtectedContent]){
                [self handelPlaybackError:nil];
                return;
            }
            
            [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
            
            __weak AudioPlayer* weakSelf = self;
            [self setTimeObserverToken:[[self player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                weakSelf.timeSlider.doubleValue = CMTimeGetSeconds(time);
            }]];
            
        });
    }];
}

- (void) play{
    if (self.player.rate != 1.f){
        if (self.currentTime == [self duration]){
            [self setCurrentTime:0.f];
        }
        [self.player play];
    }else{
        [self.player pause];
    }
}

#pragma - mark Utils

- (void) handelPlaybackError:(NSError*) error{
    NSLog(@"error '%@' for track at %i, playing next track...", error.localizedDescription, self.currentTrackIndex);
    [self playNext];
}

- (Track*) trackAtIndex:(int) trackIndex{
    
    if (trackIndex >= self.tracks.count){
        self.currentTrackIndex = trackIndex%self.tracks.count;
    }else{
        self.currentTrackIndex = trackIndex;
    }
    NSLog(@"playing track# %i", self.currentTrackIndex);
    return self.tracks[self.currentTrackIndex];
}

- (double)duration
{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
        return CMTimeGetSeconds(playerItem.asset.duration);
    else
        return 0.f;
}

- (double)currentTime
{
    return CMTimeGetSeconds(self.player.currentTime);
}

- (void)setCurrentTime:(double)time
{
    [self.player seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void) enableDisableControls{
    BOOL playEnabled, otherEnabled = NO;
    if (self.tracks.count > 0){
        playEnabled = YES;
        if (self.tracks.count > 1){
            otherEnabled = YES;
        }
    }
    self.playPauseButton.enabled = playEnabled;
    self.playNextButton.enabled = otherEnabled;
    self.playPrevButton.enabled = otherEnabled;
}

- (void)dealloc
{
    [self.player pause];
    [self.player removeTimeObserver:[self timeObserverToken]];
    self.timeObserverToken = nil;
    [self removeObserver:self forKeyPath:@"player.rate"];
    [self removeObserver:self forKeyPath:@"player.currentItem.status"];
}

@end
