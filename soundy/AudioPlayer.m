//
//  AudioPlayer.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "AudioPlayer.h"
#import "Track.h"
#import "NSObject+Util.h"
#import "AppDelegate.h"

#define AVPlayerPlayStatusStopped (0.f)
#define AVPlayerPlayStatusPlaying (1.f)
#define NoRecordsPlayedYet        (-1)


static void *AVPlayerRateContext = &AVPlayerRateContext;
static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface AudioPlayer ()
@property (strong) AVPlayer* player;
@property (strong) id timeObserverToken;

@property (assign) int currentTrackIndex;
@property (assign) double currentTime;
@property (readonly) double duration;

@end

@implementation AudioPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.player = [[AVPlayer alloc]init];
        [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:AVPlayerRateContext];
        [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
        self.currentTrackIndex = NoRecordsPlayedYet;
        [[self.playerView viewWithTag:PlayerViewVolumeSlider] setMaxValue:1.0];
    }
    return self;
}

#pragma - mark Public APIs

- (void) play:(int) trackIndex{
    if (self.tracks == nil){
        NSLog(@"tracks should be set before call play");
        return;
    }
    if (self.currentTrackIndex == NoRecordsPlayedYet){
        [self prepareTrackAndPlay:trackIndex];
    }else{
        if (self.player.rate == AVPlayerPlayStatusPlaying){
            [self.player pause];
        }else{
            [self.player play];
        }
    }
}

- (int) playNext:(BOOL) byUserClick{
    if (byUserClick){
        [self.player pause];
    }
    int nextTrack = self.currentTrackIndex + 1;
    [self prepareTrackAndPlay:nextTrack];
    return nextTrack;
}

- (int) playPrev:(BOOL) byUserClick{
    if (byUserClick){
        [self.player pause];
    }
    int prevTrack = self.currentTrackIndex - 1;
    [self prepareTrackAndPlay:prevTrack];
    return prevTrack;
}

- (void) seekToTime:(double) time{
    self.currentTime = time;
}
- (void) adjustVolume:(double) volume{
    self.player.volume = volume;
}

#pragma - mark Custom Properties

- (void) setTracks:(NSArray *)tracks{
    _tracks = tracks;
    self.currentTrackIndex = NoRecordsPlayedYet;
    [self stopPlayer];
}

#pragma - mark Obeserver callback

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVPlayerRateContext) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        
        if (rate != AVPlayerPlayStatusPlaying){
            
            if (CMTimeGetSeconds(self.player.currentTime) == CMTimeGetSeconds(self.player.currentItem.duration)){
                if (self.currentTrackIndex < self.tracks.count){
                    [SootyAppDelegate playNextAction:nil];
                }
            }else if (false /*player stopped bacause of buffering*/){
                [self play];
            }else{
                [[self.playerView viewWithTag:PlayerViewPlayPauseButton]setTitle: @"Play"];
            }
        }else{
            [[self.playerView viewWithTag:PlayerViewPlayPauseButton]setTitle: @"Pause"];
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

- (void) prepareTrackAndPlay:(int) trackIndex{
    
    [self.progressIndicator startAnimation:self];
    Track* currentTrack = [self trackAtIndex:trackIndex];
    AVURLAsset* asset = [AVAsset assetWithURL:[NSURL URLWithString:currentTrack.streamURL]];
    NSArray* assetKeys = @[@"playable", @"hasProtectedContent", @"tracks"];
    
    [asset loadValuesAsynchronouslyForKeys:assetKeys completionHandler:^(void){
        
        [self.progressIndicator stopAnimation:self];
        
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
            [[self.playerView viewWithTag:PlayerViewTimeSlider] setMaxValue:CMTimeGetSeconds(asset.duration)];

            [self.player play];
            
            __weak AudioPlayer* weakSelf = self;
            [self setTimeObserverToken:[[self player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                [[weakSelf.playerView viewWithTag:PlayerViewTimeSlider] setDoubleValue:CMTimeGetSeconds(time)];
            }]];
        });
    }];
}

- (void) play{
    if (self.player.rate != AVPlayerPlayStatusPlaying){
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
    [SootyAppDelegate playNextAction:nil];
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

- (void) stopPlayer{
    [self.player pause];
    [self setCurrentTime:0.f];
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
