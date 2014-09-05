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

#import "SearchResultViewController.h"
#import "ListViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSView *playerView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) AudioPlayer* audioPlayer;
@property (strong) SoundApi* soundApi;


@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // BEGIN TEST
    Track* track1 = [[Track alloc]init];
    track1.streamURL = @"https://api.soundcloud.com/tracks/67451811/stream?client_id=85652ec093beadb4c647450f597b16ad";
    NSArray* tracks = @[track1];
    self.audioPlayer = [[AudioPlayer alloc]init];
    self.audioPlayer.playerView = self.playerView;
    self.audioPlayer.progressIndicator = self.progressIndicator;
    // END TEST
    
    self.audioPlayer.tracks = tracks;
    [self.audioPlayer play:0];
    
    self.soundApi = [[SoundCloudApi alloc]init];
    self.soundApi.searchCallbackTarget = self;
    self.soundApi.searchCallbackSelector = @selector(searchResultReturned:);
    //
    
    NSViewController* listVC = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
    NSViewController* searchResultVC = [[SearchResultViewController alloc]initWithNibName:@"SearchResultViewController" bundle:nil];
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
    }else{
        
    }
}

#pragma mark - UI Control actions

- (IBAction)temp:(id)sender {
    [self.audioPlayer playPauseAction:sender];
}

@end
