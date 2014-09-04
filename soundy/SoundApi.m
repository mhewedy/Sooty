//
//  SoundApi.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "SoundApi.h"
#import "URLCaller.h"

@interface SoundApi ()

@property URLCaller* urlCaller;

@end

@implementation SoundApi

-(void) search:(NSString*) token{
    if (!self.searchRequestURL){
        NSLog(@"searchRequestURL is null, prehaps you need to use a subclass implementation.");
    }else{
        self.urlCaller = [[URLCaller alloc]initWithTarget:self selector:@selector(searchTarget:)];
        NSRange placeholderRange = [self.searchRequestURL rangeOfString:@"${token}"];
        [self.urlCaller call:[self.searchRequestURL stringByReplacingCharactersInRange:placeholderRange withString:token]];
    }
}

// each subclass should an implementation
-(void) searchTarget:(NSString*) response{
}

-(NSString*) getStreamURL:(Track*) track{
    // use self.streamRequestURL to get streaming URL for the track
    return nil;
}

@end
