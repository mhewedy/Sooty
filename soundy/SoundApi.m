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
    if (!self.searchURL){
        NSLog(@"searchURL is null, prehaps you need to use a subclass implementation to set the value of searchURL ");
    }else{
        if (token.length > 0){
            self.urlCaller = [[URLCaller alloc]initWithTarget:self selector:@selector(searchResponseReceived:)];
            NSRange placeholderRange = [self.searchURL rangeOfString:@"${token}"];
            [self.urlCaller call:[self.searchURL stringByReplacingCharactersInRange:placeholderRange withString:token]];
        }else{
            [self.searchCallbackTarget performSelector:self.searchCallbackSelector withObject:nil afterDelay:0.0f];
        }
        
    }
}

// each subclass should an implementation
-(void) searchResponseReceived:(NSString*) response{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString*) name{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}



@end
