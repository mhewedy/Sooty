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

- (void) play:(int) trackIndex forcePlay:(BOOL) forcePlay{
    if (self.tracks == nil){
        NSLog(@"tracks should be set before call play");
        return;
    }
    
    if (!forcePlay){
        if (self.currentTrackIndex == NoRecordsPlayedYet){
            [self prepareTrackAndPlay:trackIndex];
        }else{
            if (self.player.rate == AVPlayerPlayStatusPlaying){
                [self.player pause];
            }else{
                [self.player play];
            }
        }
    }else{
        [self stopPlayer];
        [self prepareTrackAndPlay:trackIndex];
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

- (void) resetPlayer{
    [self stopPlayer];
    self.currentTrackIndex = NoRecordsPlayedYet;
}

#pragma - mark Obeserver callback

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVPlayerRateContext) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];

        [SootyAppDelegate markPlayingTrack:(PlaybackStatus){self.currentTrackIndex, rate == AVPlayerPlayStatusPlaying,
            (__bridge CFStringRef) self.playlistName}];
        
        SootyAppDelegate.window.title = [NSString stringWithFormat:@"%@ [%@] - %@ - %@", @"Sooty", rate == AVPlayerPlayStatusPlaying ? @"Play" : @"Pause", self.playlistName, self.currentTrackIndex > NoRecordsPlayedYet && self.tracks.count > self.currentTrackIndex ?[self.tracks[self.currentTrackIndex] title] : @""];
        
        if (rate != AVPlayerPlayStatusPlaying){
            [[self.playerView viewWithTag:PlayerViewPlayPauseButton]setTitle: @"Play"];
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
    NSLog(@"%@", currentTrack.streamURL);
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
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaNotArriveAtTime:) name:AVPlayerItemPlaybackStalledNotification object:self.player.currentItem];
            [[NSNotificationCenter defaultCenter] addObserver:SootyAppDelegate selector:@selector(playNextAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
            
            [[self.playerView viewWithTag:PlayerViewTimeSlider] setMaxValue:CMTimeGetSeconds(asset.duration)];

            [self.player play];
            
            __weak AudioPlayer* weakSelf = self;
            [self setTimeObserverToken:[[self player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                [[weakSelf.playerView viewWithTag:PlayerViewTimeSlider] setDoubleValue:CMTimeGetSeconds(time)];
            }]];
        });
    }];
}

-(void)mediaNotArriveAtTime:(NSNotification *) notification {
    [self.player play];
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
    NSLog(@"playing track# %i of %@", self.currentTrackIndex, self.playlistName);
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
