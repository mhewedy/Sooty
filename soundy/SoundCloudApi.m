//
//  SoundCloudApi.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "SoundCloudApi.h"
#import "NSObject+Util.h"

@interface SoundCloudApi ()

@property (strong, readwrite) NSString* searchRequestURL;
@property (strong, readwrite) NSString* streamRequestURL;

@end

@implementation SoundCloudApi

@synthesize searchRequestURL;
@synthesize streamRequestURL;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.searchRequestURL = @"https://api.soundcloud.com/tracks.json?q=${token}&client_id=85652ec093beadb4c647450f597b16ad";
        self.streamRequestURL = @"https://api.soundcloud.com/i1/tracks/${token}/streams?client_id=85652ec093beadb4c647450f597b16ad";
    }
    return self;
}

-(void) searchResponseReceived:(NSString*) response{
    
    NSError* error = nil;
    NSArray* arr = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    
    if (error == nil){
        NSMutableArray* myResultArr = [NSMutableArray array];
        
        for (NSDictionary* dict in arr) {
            Track* track = [[Track alloc]init];
            track.id = dict[@"id"];
            track.title = dict[@"title"];
            // TODO set rest of props of track
            
            [myResultArr addObject:track];
        }
        [self.searchCallbackTarget performSelector:self.searchCallbackSelector withObject:myResultArr];
    }else{
        [self alert:error.localizedDescription];
    }
}

-(void) streamResponseReceived:(NSString*) response{
    [self.streamCallbackTarget performSelector:self.streamCallbackSelector withObject:nil];
}


@end
