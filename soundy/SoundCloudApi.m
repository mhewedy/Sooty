//
//  SoundCloudApi.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "SoundCloudApi.h"
#import "NSObject+Util.h"

static NSString* CLIENT_ID = @"85652ec093beadb4c647450f597b16ad";

@interface SoundCloudApi ()

@property (strong, readwrite) NSString* searchURL;

@end

@implementation SoundCloudApi

@synthesize searchURL;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.searchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks.json?q=${token}&client_id=%@", CLIENT_ID];
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
            track.streamURL = [NSString stringWithFormat:@"%@?client_id=%@", dict[@"stream_url"], CLIENT_ID];
            track.originalURL = dict[@"permalink_url"];
            
            [myResultArr addObject:track];
        }
        [self.searchCallbackTarget performSelector:self.searchCallbackSelector withObject:myResultArr afterDelay:0.0f];
    }else{
        [self alert:error.localizedDescription];
    }
}


@end