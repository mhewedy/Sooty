//
//  URLCaller.h
//  soundy
//
//  Created by Muhammad Hewedy on 9/4/14.
//  Copyright (c) 2014 Muhammad Hewedy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLCaller : NSObject

@property (strong) NSMutableData* data;
@property (weak) id target;
@property SEL selector;

-(instancetype) initWithTarget:(id) target selector:(SEL)selector NS_DESIGNATED_INITIALIZER;
-(void) call:(NSString*) url;

@end