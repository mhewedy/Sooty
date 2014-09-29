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
#import "URLCaller.h"

#define AddToMenuItem (@"Add to %@")
#define RemoveMenuItem (@"Remove")

@interface SearchResultViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property PlaybackStatus playbackStatus;

@end

@implementation SearchResultViewController

- (void)awakeFromNib {
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(doubleClick:)];
}

#pragma - mark Custome propreties
- (void)setTracks:(NSArray *) mytracks
{
    _tracks = mytracks;
    
    if (self.tracks){
        if (self.tracks.count != 0){
            [self.tableView scrollRowToVisible:0];
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
            [self.playlist isEqualToString:(__bridge NSString *)self.playbackStatus.playlist]){
            
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

- (void) markPlayingTrack:(PlaybackStatus) playbackStatus{
    self.playbackStatus = playbackStatus;
    [self.tableView reloadData];
}

#pragma - mark Actions

-(void)doubleClick:(id) sender{
    [SootyAppDelegate setAudioPlayerTracks:self.tracks playlist:self.playlist];
    [SootyAppDelegate play:(int)self.tableView.clickedRow forcePlay:YES];
}


- (IBAction)playCotextMenuAction:(id)sender {
    [self doubleClick:nil];
}

- (IBAction)goToWebsiteContextMenuAction:(id)sender {
    Track* track = self.tracks[self.tableView.clickedRow];
    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:track.originalURL ]];
}

static long downloadedTrackIndex = 0;
- (IBAction)downloadContextMenuAction:(id)sender {
    
    Track* track = self.tracks[downloadedTrackIndex = self.tableView.clickedRow];

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    alert.messageText = @"Downloading Track";
    alert.informativeText = [NSString stringWithFormat:@"Downlaoding Track \"%@\"?", track.title];
    alert.alertStyle = NSInformationalAlertStyle;
    [alert beginSheetModalForWindow:SootyAppDelegate.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [SootyAppDelegate startProgress];
        Track* track = self.tracks[downloadedTrackIndex];
        URLCaller* caller = [[URLCaller alloc]initWithTarget:self selector:@selector(saveTrack:)];
        caller.raw = YES;
        [caller call:track.streamURL];
    }
}

- (void) saveTrack:(NSData*) data{
    [SootyAppDelegate stopProgress];
    
    Track* track = self.tracks[downloadedTrackIndex];
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    savePanel.nameFieldStringValue = [NSString stringWithFormat:@"%@.mp3", track.title];
    
    if ([savePanel runModal] == NSModalResponseOK){
        NSString* path = savePanel.URL.path;
        [data writeToFile:path atomically:YES];
    }
}

#pragma - make NSMenuDelegte

- (void)menuWillOpen:(NSMenu *)menu{
    const int numOfItems = 3;
    
    long row = self.tableView.clickedRow;
    [[menu itemAtIndex:0] setEnabled:row >= 0];
    [[menu itemAtIndex:1] setEnabled:row >= 0];
    [[menu itemAtIndex:2] setEnabled:row >= 0];
    
    NSInteger itemsToRem = menu.numberOfItems - numOfItems;
    for (int i=0; i < itemsToRem; i++) {
        [menu removeItemAtIndex:numOfItems];
    }
    
    if (menu.numberOfItems == numOfItems + 1){
        [menu removeItemAtIndex:numOfItems];// sparator
    }
    
    if (![self.playlist isEqualToString:SearchResultsPlaylist]){
        [menu addItem:[NSMenuItem separatorItem]];
        NSMenuItem* mi = [menu addItemWithTitle:RemoveMenuItem action:@selector(removeTrackFromPlaylist:) keyEquivalent:@""];
        [mi setEnabled:row >= 0];
        [mi setTarget:self];
        
    }else if (SootyAppDelegate.listVC.list.count > 1){
        [menu addItem:[NSMenuItem separatorItem]];
        
        for (int i=1; i < SootyAppDelegate.listVC.list.count; i++) {
            NSString* playlist = SootyAppDelegate.listVC.list[i];
            
            if (![self.playlist isEqualToString:playlist]){
                NSMenuItem* mi = [menu addItemWithTitle:[NSString stringWithFormat:AddToMenuItem, playlist] action:@selector(addTrackToPlaylist:) keyEquivalent:@""];
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
    [SootyAppDelegate.listVC.playlists[self.playlist] removeObjectsInRange:selectedRange];
    
    [DBUtil savePlaylistKeys:SootyAppDelegate.listVC.list];
    [DBUtil savePlaylists:SootyAppDelegate.listVC.playlists];
 
    [self.tableView reloadData];

}


@end
