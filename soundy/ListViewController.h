//
//  ListViewController.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/5/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Util.h"

@interface ListViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate>

@property NSMutableArray* list;
Persist @property NSMutableDictionary *playLists;

@end
