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

// internal props
@property (strong) NSString* searchRequestURL;
@property (strong) NSString* streamRequestURL;
// ~
@property (weak) id searchCallbackTarget;
@property SEL searchCallbackSelector;


-(void) search:(NSString*) token;
-(NSString*) getStreamURL:(Track*) track;

@end
