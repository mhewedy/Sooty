//
//  DBUtil.h
//  Sooty
//
//  Created by Muhammad Hewedy on 9/16/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Util.h"

#define PlaylistPersistenceKeyPlaylistDictionary            (@"PlaylistPersistenceKeyPlaylistDictionary")
#define PlaylistPersistenceKeyPlaylistKeys                 (@"PlaylistPersistenceKeyPlaylistKeys")
#define PlaylistPersistenceKeyPlaylistNumber                (@"PlaylistPersistenceKeyPlaylistNumber")

@interface DBUtil : NSObject

+ (NSMutableArray*) loadPlaylistsKeys;
+ (NSMutableDictionary*) loadPlaylists;
+ (int) loadPlaylistNumber;

+ (void) savePlaylistKeys:(NSArray*) playlistKeys;
+ (void) savePlaylists:(NSDictionary*) playlists;
+ (void) savePlaylistNumber:(int) num;

@end
