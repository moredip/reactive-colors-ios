//
//  RXCJavascriptBridge.m
//  Reactive Colors
//
//  Created by Pete Hodgson on 6/1/14.
//  Copyright (c) 2014 Pete Hodgson. All rights reserved.
//

#import "RXCJavascriptBridge.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RXCJavascriptBridge()
@property (strong) JSContext *jsContext;
@property (strong) NSMutableArray *loadedCallbacks;
@end

@implementation RXCJavascriptBridge

- (id)init
{
    self = [super init];
    if (self) {
        self.jsContext = [self enhancedJSContext];
        self.loadedCallbacks = [NSMutableArray array];
    }
    return self;
}

- (void)registerSignal:(RACSignal *)signal named:(NSString *)name
{
    JSValue *jsSignalHandler = self.jsContext[@"rxu"][@"onObjcSignal"];
    
    [signal subscribeNext:^(id val) {
        [jsSignalHandler callWithArguments:@[name,val]];
    }];
}

- (JSContext *)enhancedJSContext
{
    JSContext *jsContext = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    [self addExceptionLoggingTo:jsContext];
    [self addConsoleLogTo:jsContext];
    return jsContext;
}

- (void)addExceptionLoggingTo:(JSContext *)jsContext{
    [jsContext setExceptionHandler:^(JSContext *ctx, JSValue *val) {
        NSLog(@"!!! JAVASCRIPT EXCEPTION in %@ !!!.\n%@",ctx, val);
    }];
}

- (void)addConsoleLogTo:(JSContext *)jsContext{
    jsContext[@"console"] = [JSValue valueWithNewObjectInContext:jsContext];
    jsContext[@"console"][@"log"] = ^(JSValue *msg) {
        NSLog(@"console.log from %@: %@",[JSContext currentContext], msg);
    };
}

- (void)bootJavascript
{
    self.jsContext[@"rxu"] = [JSValue valueWithNewObjectInContext:self.jsContext];
    self.jsContext[@"rxu"][@"loaded"] = ^(JSValue *callback) {
        [self.loadedCallbacks addObject:callback];
    };
    
    NSArray *javascripts = [[NSBundle mainBundle] pathsForResourcesOfType:@"js" inDirectory:@"javascript"];
    
    for (NSString *jsPath in javascripts) {
        NSLog(@"loading javascript from %@",jsPath);
        NSString *javascript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
        [self.jsContext evaluateScript:javascript];
    }
    
    for (JSValue *callback in self.loadedCallbacks) {
        [callback callWithArguments:@[]];
    }
}

@end
