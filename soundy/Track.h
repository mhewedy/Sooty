//
//  Track.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (strong) NSString* id;
@property (strong) NSString* title;
@property (strong) NSString* username;
@property (strong) NSString* genre;
@property (strong) NSString* streamURL;
@property (strong) NSString* originalURL;
@property (strong) NSString* duration;
@property (strong) NSString* artworkURL;

@end
