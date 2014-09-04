//
//  SoundCloudApi.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "SoundCloudApi.h"

@implementation SoundCloudApi


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.searchRequestURL = @"https://api.soundcloud.com/tracks.json?q=${token}&client_id=85652ec093beadb4c647450f597b16ad";
        self.streamRequestURL = @"https://api.soundcloud.com/i1/tracks/${token}/streams?client_id=85652ec093beadb4c647450f597b16ad";
    }
    return self;
}

// each subclass should provids
-(void) searchTarget:(NSString*) response{
    NSLog(@"SoundCloudApi %@", response);
}

@end
