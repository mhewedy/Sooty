//
//  SearchResultViewController.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "SearchResultViewController.h"
#import "Track.h"
#import "AppDelegate.h"

@interface SearchResultViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSScrollView *tableScrollView;
@property PlaybackStatus playbackStatus;

@end

@implementation SearchResultViewController


#pragma - mark Custome propreties
- (void)setTracks:(NSArray *) mytracks
{
    _tracks = mytracks;
    
    if (self.tracks){
        if (self.tracks.count != 0){
            self.tableScrollView.hidden = NO;
            self.message.hidden = YES;
            
            [self.tableView reloadData];
            [self.tableView scrollRowToVisible:0];
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }else{
            self.message.hidden = NO;
            self.tableScrollView.hidden = YES;
        }
    }
}

#pragma - mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.tracks.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    Track* track = self.tracks[row];
    if ([tableColumn.identifier isEqualToString:@"play"]){
        if (row == self.playbackStatus.playedTrackIndex){
            if (self.playbackStatus.isPlaying){
                return @"►";
            }else{
                return @"◼";
            }
        }
        return @"";
    }else{
        return [track valueForKey:tableColumn.identifier];
    }
}

#pragma - mark Utils

- (void) resetView {
    self.message.hidden = YES;
}

- (long) selectedTrackIndex{
    return self.tableView.selectedRow;
}

- (void) moveToTrackAt:(int) index{
    index = index%self.tracks.count;
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
}

- (void) markPlayingTrack:(PlaybackStatus) playbackStatus{
    self.playbackStatus = playbackStatus;
    [self.tableView reloadData];
}

#pragma - mark Actions

- (IBAction)playCotextMenuAction:(id)sender {
    [SootyAppDelegate play:(int)self.tableView.clickedRow forcePlay:YES];
}

- (IBAction)goToWebsiteContextMenuAction:(id)sender {
    Track* track = self.tracks[self.tableView.clickedRow];
    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:track.originalURL ]];
}

#pragma - make NSMenuDelegte

- (void)menuWillOpen:(NSMenu *)menu{
    long row = self.tableView.clickedRow;
    [[menu itemAtIndex:0] setEnabled:row >= 0];
    [[menu itemAtIndex:1] setEnabled:row >= 0];
    
    NSInteger itemsToRem = menu.numberOfItems - 2;
    for (int i=0; i < itemsToRem; i++) {
        [menu removeItemAtIndex:2];
    }
    
    if (menu.numberOfItems == 3){
        [menu removeItemAtIndex:2];// sparator
    }

    if (SootyAppDelegate.listVC.list.count > 1){
        [menu addItem:[NSMenuItem separatorItem]];
        
        for (int i=1; i < SootyAppDelegate.listVC.list.count; i++) {
            NSString* playListName = SootyAppDelegate.listVC.list[i];
            
            if ([self.myPlaylistName isNotEqualTo:playListName]){
                NSMenuItem* mi = [menu addItemWithTitle:[NSString stringWithFormat:@"Add to %@", playListName] action:@selector(addTrackToPlayList:) keyEquivalent:@""];
                [mi setEnabled:row >= 0];
                [mi setTarget:self];
            }
        }
    }
}

- (void) addTrackToPlayList:(NSMenuItem*) menuItem{
    NSLog(@"TODO");
}


@end
