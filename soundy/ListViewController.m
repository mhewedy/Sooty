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
#define DefaultPlayListName (@"New PlayList")

Persist static int currPlayListNumber = 1;

@interface ListViewController ()

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation ListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.list = [[NSMutableArray alloc]initWithObjects:SearchResults, nil];
        self.playLists = [[NSMutableDictionary alloc]initWithObjectsAndKeys:nil, SearchResults, nil];
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

        id tmpPlayList = self.playLists[self.list[row]];
        [self.playLists removeObjectForKey:self.list[row]];
        
        self.list[row] = object;
        if (tmpPlayList){
            self.playLists[self.list[row]] = tmpPlayList;
        }
    }
}

#pragma - mark NSTableViewDelegate
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [[notification object] selectedRow];
    if (row >= 0){
        [SootyAppDelegate setSearchResult:self.playLists[self.list[row]] playListName:self.list[row]];
    }
}

#pragma - mark NSMenuDelegate

- (void) menuWillOpen:(NSMenu *)menu{
    long row = self.tableView.clickedRow;
    [[menu itemAtIndex:0] setEnabled:row > IndexOfSearchResultEntry];
}

#pragma - mark Actions

- (IBAction)addPlaylist:(id)sender {
    [self addPlayList:DefaultPlayListName];
}

- (void) addPlayList:(NSString*) playListName{
    
    if ([self.list containsObject:playListName]){
        [self addPlayList:[NSString stringWithFormat:@"%@ (%i)", DefaultPlayListName, currPlayListNumber++]];
    }else{
        [self.list addObject:playListName];
        [self.tableView reloadData];
        NSInteger row = self.tableView.numberOfRows-1;
        [self.tableView editColumn:0 row:row withEvent:nil select:YES];
    }
}

- (IBAction)removeMenuAction:(id)sender {
    NSInteger row = self.tableView.clickedRow;
    if (row > IndexOfSearchResultEntry){
        // remove playlist for the entry
        [self.playLists removeObjectForKey:self.list[row]];
        // remove the entry itself
        [self.list removeObjectAtIndex:row];
        [self.tableView abortEditing];
        [self.tableView reloadData];
    }
}


@end
