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
#import "DBUtil.h"

#define AddToMenuItem (@"Add to %@")
#define RemoveMenuItem (@"Remove")

@interface SearchResultViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property PlaybackStatus playbackStatus;

@end

@implementation SearchResultViewController


#pragma - mark Custome propreties
- (void)setTracks:(NSArray *) mytracks
{
    _tracks = mytracks;
    
    if (self.tracks){
        if (self.tracks.count != 0){
            [self.tableView scrollRowToVisible:0];
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }else{
            [self alert:@"No results found!"];
        }
    }
    [self.tableView reloadData];
}

#pragma - mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.tracks.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    Track* track = self.tracks[row];
    if ([tableColumn.identifier isEqualToString:@"play"]){
        
        if (row == self.playbackStatus.playedTrackIndex &&
            [self.playlistName isEqualToString:(__bridge NSString *)self.playbackStatus.playlist]){
            
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
    
    if (![self.playlistName isEqualToString:SearchResultsPlaylist]){
        [menu addItem:[NSMenuItem separatorItem]];
        NSMenuItem* mi = [menu addItemWithTitle:RemoveMenuItem action:@selector(removeTrackFromPlaylist:) keyEquivalent:@""];
        [mi setTarget:self];
        
    }else if (SootyAppDelegate.listVC.list.count > 1){
        [menu addItem:[NSMenuItem separatorItem]];
        
        for (int i=1; i < SootyAppDelegate.listVC.list.count; i++) {
            NSString* playlistName = SootyAppDelegate.listVC.list[i];
            
            if (![self.playlistName isEqualToString:playlistName]){
                NSMenuItem* mi = [menu addItemWithTitle:[NSString stringWithFormat:AddToMenuItem, playlistName] action:@selector(addTrackToPlaylist:) keyEquivalent:@""];
                [mi setEnabled:row >= 0];
                [mi setTarget:self];
            }
        }
    }
}

- (void) addTrackToPlaylist:(NSMenuItem*) menuItem{
    NSString* playlist = [menuItem.title substringFromIndex:AddToMenuItem.length-2];
    
    if (!SootyAppDelegate.listVC.playlists[playlist]){
        SootyAppDelegate.listVC.playlists[playlist] = [[NSMutableArray alloc]init];
    }
    
    [self.tableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Track* track = self.tracks[idx];
        [SootyAppDelegate.listVC.playlists[playlist] addObject:track];
    }];
    
    [DBUtil savePlaylistKeys:SootyAppDelegate.listVC.list];
    [DBUtil savePlaylists:SootyAppDelegate.listVC.playlists];
}

- (void) removeTrackFromPlaylist:(NSMenuItem*) menuItem{
    
    NSRange selectedRange = NSMakeRange(self.tableView.selectedRowIndexes.firstIndex, self.tableView.selectedRowIndexes.count);
    [SootyAppDelegate.listVC.playlists[self.playlistName] removeObjectsInRange:selectedRange];
    
    [DBUtil savePlaylistKeys:SootyAppDelegate.listVC.list];
    [DBUtil savePlaylists:SootyAppDelegate.listVC.playlists];
 
    [self.tableView reloadData];

}


@end
