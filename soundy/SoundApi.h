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

@property (strong, readonly) NSString* searchURL;

@property (weak) id searchCallbackTarget;
@property SEL searchCallbackSelector;

-(void) search:(NSString*) token;

@end
