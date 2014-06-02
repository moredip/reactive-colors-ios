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
@end

@implementation RXCJavascriptBridge

- (id)init
{
    self = [super init];
    if (self) {
        self.jsContext = [self enhancedJSContext];
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
    
    [jsContext setExceptionHandler:^(JSContext *ctx, JSValue *val) {
        NSLog(@"!!! JAVASCRIPT EXCEPTION in %@ !!!.\n%@",ctx, val);
    }];
    
    jsContext[@"console"] = [JSValue valueWithNewObjectInContext:jsContext];
    jsContext[@"console"][@"log"] = ^(JSValue *msg) {
        NSLog(@"console.log from %@: %@",[JSContext currentContext], msg);
    };
    
    jsContext[@"rxu"] = [JSValue valueWithNewObjectInContext:jsContext];
    
    return jsContext;
}

- (void)bootJavascript
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"root" ofType:@"js"];
    NSString *javascript = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.jsContext evaluateScript:javascript];
}

@end
