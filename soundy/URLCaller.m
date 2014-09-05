//
//  URLCaller.m
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import "URLCaller.h"
#import "NSObject+Util.h"

@implementation URLCaller

-(id) initWithTarget:(NSObject*) target selector:(SEL)selector
{
    if (self = [super init])
    {
        self.target = target;
        self.selector = selector;
    }
    return self;
}

-(void) call:(NSString*) url
{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", url);
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
}

#pragma mark - NSURLConnection deleages

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    NSLog(@"didReceiveResponse");
    self.data = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    NSLog(@"didReceiveData");
    [self.data appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NSLog(@"didFailWithError");
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSLog(@"connectionDidFinishLoading");
    NSString* stringData = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
    [self.target performSelector:self.selector withObject:stringData afterDelay:0.0f];
    

}

@end
