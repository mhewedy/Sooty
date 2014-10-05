//
//  Track.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "Track.h"

@implementation Track


- (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@, duration %@, artwork %@", self.id, self.duration, self.artworkURL];
}

@end
