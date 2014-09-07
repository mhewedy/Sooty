//
//  SootyServiceApi.m
//  Sooty
//
//  Created by Muhammad Hewedy on 9/8/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "SootyServiceApi.h"
#import "NSObject+Util.h"

@interface SootyServiceApi ()

@property (strong, readwrite) NSString* searchURL;

@end

@implementation SootyServiceApi

@synthesize searchURL;


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.searchURL = @"http://localhost:4567/list?${token}";
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
            track.genre = @"";
            track.username = @"";
            track.streamURL = dict[@"streamURL"];
            track.originalURL = @"";
            track.duration = @"";
            
            [myResultArr addObject:track];
        }
        [self.searchCallbackTarget performSelector:self.searchCallbackSelector withObject:myResultArr afterDelay:0.0f];
    }else{
        [self alert:error.localizedDescription];
    }
}

@end
