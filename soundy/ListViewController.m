//
//  ListViewController.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "ListViewController.h"
#import "AppDelegate.h"
#import "DBUtil.h"


#define IndexOfSearchResultEntry (0)
#define DefaultPlaylistName (@"New Playlist")

@interface ListViewController ()

@property (weak) IBOutlet NSTableView *tableView;
Persist @property int currPlaylistNumber;

@end

@implementation ListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Loading playlists ...");
        self.list = [DBUtil loadPlaylistsKeys];
        self.playlists = [DBUtil loadPlaylists];
        self.currPlaylistNumber = [DBUtil loadPlaylistNumber];
        
        // set background for view
        CALayer *viewLayer = [CALayer layer];
        [viewLayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.1)];
        [self.view setWantsLayer:YES];
        [self.view setLayer:viewLayer];
        
    }
    return self;
}

#pragma - mark Interface

- (void) selectDefaultPlaylist{
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:IndexOfSearchResultEntry] byExtendingSelection:NO];
}

#pragma - mark NSTableViewDataSource

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView{
    return self.list.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return self.list[row];
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (row > IndexOfSearchResultEntry &&  ((NSString*)object).length > 0){
        if ([self.list containsObject:object]){
            [self alert:@"Playlist with same name exists."];
            return;
        }

        id tmpPlaylist = self.playlists[self.list[row]];
        [self.playlists removeObjectForKey:self.list[row]];
        
        self.list[row] = object;
        if (tmpPlaylist){
            self.playlists[self.list[row]] = tmpPlaylist;
        }
        
        [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

        [DBUtil savePlaylistKeys:self.list];
        [DBUtil savePlaylists:self.playlists];
    }
}

#pragma - mark NSTableViewDelegate

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [[notification object] selectedRow];
    if (row > -1){
        [SootyAppDelegate setSearchResult:self.playlists[self.list[row]] playlist:self.list[row] updatePlayer:NO];
    }
}

#pragma - mark NSMenuDelegate

- (void) menuWillOpen:(NSMenu *)menu{
    long row = self.tableView.clickedRow;
    [[menu itemAtIndex:0] setEnabled:row > IndexOfSearchResultEntry];
}

#pragma - mark Actions

- (IBAction) newPlaylist:(id)sender {
    [self addPlaylist:DefaultPlaylistName];
}

- (void) addPlaylist:(NSString*) playlist{
    
    if ([self.list containsObject:playlist]){
        [self addPlaylist:[NSString stringWithFormat:@"%@ (%i)", DefaultPlaylistName, self.currPlaylistNumber++]];
    }else{
        [self.list addObject:playlist];
        [self.tableView reloadData];
        NSInteger row = self.tableView.numberOfRows-1;
        [self.tableView editColumn:0 row:row withEvent:nil select:YES];
    }
    
    [DBUtil savePlaylistKeys:self.list];
}

- (IBAction)removeMenuAction:(id)sender {
    NSInteger row = self.tableView.clickedRow;
    if (row > IndexOfSearchResultEntry){
        // remove playlist for the entry
        [self.playlists removeObjectForKey:self.list[row]];
        // remove the entry itself
        [self.list removeObjectAtIndex:row];
        [self.tableView abortEditing];
        [self.tableView reloadData];
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row-1] byExtendingSelection:NO];
    }
    
    [DBUtil savePlaylistKeys:self.list];
}


@end
