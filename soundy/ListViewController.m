//
//  ListViewController.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "ListViewController.h"
#import "AppDelegate.h"

#define IndexOfSearchResultEntry (0)
#define DefaultPlaylistName (@"New Playlist")

Persist static int currPlaylistNumber = 1;

@interface ListViewController ()

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation ListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.list = [[NSMutableArray alloc]initWithObjects:SearchResultsPlaylist, nil];
        self.playlists = [[NSMutableDictionary alloc]initWithObjectsAndKeys:nil, SearchResultsPlaylist, nil];
    }
    return self;
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
    }
}

#pragma - mark NSTableViewDelegate
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [[notification object] selectedRow];
    [SootyAppDelegate setSearchResult:self.playlists[self.list[row]] playlistName:self.list[row]];
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

- (void) addPlaylist:(NSString*) playlistName{
    
    if ([self.list containsObject:playlistName]){
        [self addPlaylist:[NSString stringWithFormat:@"%@ (%i)", DefaultPlaylistName, currPlaylistNumber++]];
    }else{
        [self.list addObject:playlistName];
        [self.tableView reloadData];
        NSInteger row = self.tableView.numberOfRows-1;
        [self.tableView editColumn:0 row:row withEvent:nil select:YES];
    }
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
    }
}


@end
