//
//  SearchResultViewController.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "SearchResultViewController.h"
#import "Track.h"

@interface SearchResultViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSScrollView *tableScrollView;

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


#pragma - mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSTableCellView* result = nil;
    NSString* valueToDisplay = nil;
    
    Track* track = [self.tracks objectAtIndex:row];
    
    if ([tableColumn.identifier isEqual: @"titleColumn"]){
        result = [tableView makeViewWithIdentifier:@"titleColumn" owner:self];
        valueToDisplay = track.title;
    }else if ([tableColumn.identifier isEqual: @"userColumn"]){
        result = [tableView makeViewWithIdentifier:@"userColumn" owner:self];
        valueToDisplay = track.username;
    }else if ([tableColumn.identifier isEqual: @"genreColumn"]){
        result = [tableView makeViewWithIdentifier:@"genreColumn" owner:self];
        valueToDisplay = track.genre;
    }else if ([tableColumn.identifier isEqual: @"durationColumn"]){
        result = [tableView makeViewWithIdentifier:@"durationColumn" owner:self];
        valueToDisplay = track.duration;
    }
    
    result.textField.stringValue = valueToDisplay;
    return result;
}


#pragma - mark Utils

- (void) resetView {
    self.message.hidden = YES;
}

- (long) selectedTrackIndex{
    return self.tableView.selectedRow;
}

- (void) moveToNext{
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.tableView.selectedRow + 1] byExtendingSelection:NO];
}

- (void) moveToPrev{
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.tableView.selectedRow - 1] byExtendingSelection:NO];
}

@end
