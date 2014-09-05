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
    
    if ([self.tracks count] != 0){
        self.tableScrollView.hidden = NO;
        self.message.hidden = YES;
        
        [self.tableView reloadData];
    }else{
        self.message.hidden = NO;
        self.tableScrollView.hidden = YES;
    }
}

#pragma - mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.tracks.count;
}

#pragma - mark NSTableViewDelegate


#pragma - mark Utils

- (void) resetView {
    self.message.hidden = YES;
}

@end
