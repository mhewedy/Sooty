//
//  ListViewController.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "ListViewController.h"
#define IndexOfSearchResultEntry (0)

@interface ListViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property NSMutableArray* list;

@end

@implementation ListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.list = [[NSMutableArray alloc]initWithObjects:@"Search Results", nil];
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
    if (row > IndexOfSearchResultEntry){
        self.list[row] = object;
    }
}

#pragma - mark NSMenuDelegate

- (void) menuWillOpen:(NSMenu *)menu{
    long row = self.tableView.clickedRow;
    [[menu itemAtIndex:0] setEnabled:row > IndexOfSearchResultEntry];
}

#pragma - mark Actions

- (IBAction)addPlaylist:(id)sender {
    [self.list addObject:@"New Playlist"];
    [self.tableView reloadData];
    [self.tableView editColumn:0 row:self.tableView.numberOfRows-1 withEvent:nil select:YES];
}

- (IBAction)removeMenuAction:(id)sender {
    NSInteger row = self.tableView.clickedRow;
    if (row > IndexOfSearchResultEntry){
        [self.list removeObjectAtIndex:row];
        [self.tableView abortEditing];
        [self.tableView reloadData];
    }
}


@end
