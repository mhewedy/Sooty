//
//  SoundApi.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

@interface SoundApi : NSObject

@property (strong) NSArray* searchResult;

// should be accessed only by subclass
@property (strong) NSString* searchRequestURL;
@property (strong) NSString* streamRequestURL;
//

-(void) search:(NSString*) token;
-(NSString*) getStreamURL:(Track*) track;

@end
