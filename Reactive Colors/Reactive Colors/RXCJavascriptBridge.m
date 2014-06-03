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
#import <ReactiveCocoa/RACEXTScope.h>

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

- (RACSignal *)signalNamed:(NSString *)signalName
{
    @weakify(self);
    
    return [RACSignal
             createSignal:^(id<RACSubscriber> subscriber) {
                 @strongify(self);
                 
                 JSValue *jsSignalHandler = ^(JSValue *value) {
                     [subscriber sendNext:[value toObject]];
                 };
                 [self.jsContext[@"rxu"][@"registerSinkSignalHandler"] callWithArguments:@[signalName,jsSignalHandler]];
                 
                 [self.rac_deallocDisposable addDisposable:[RACDisposable disposableWithBlock:^{
                     [subscriber sendCompleted];
                 }]];
                 
                 return [RACDisposable disposableWithBlock:^{
                     //@strongify(self);
                     // TODO: remove js function from rxu.sinkSignalHandlers ?
                 }];
             }];
}

- (JSContext *)enhancedJSContext
{
    JSContext *jsContext = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    [self addDummyWindowRootObjectTo:jsContext];
    [self addExceptionLoggingTo:jsContext];
    [self addConsoleLogTo:jsContext];
    return jsContext;
}

// some JS libraries bomb if there isn't a root window object
- (void)addDummyWindowRootObjectTo:(JSContext *)jsContext{
    jsContext[@"window"] = [JSValue valueWithNewObjectInContext:jsContext];
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
        [self loadJavaScriptFileAt:jsPath intoContext:self.jsContext];
    }
    
    JSValue *coffeescriptCompiler = [self getCoffeeScriptCompilationFunction];
    NSArray *coffeescripts = [[NSBundle mainBundle] pathsForResourcesOfType:@"coffee" inDirectory:@"javascript"];
    for (NSString *coffeePath in coffeescripts) {
        NSLog(@"loading coffescript from %@",coffeePath);
        NSString *coffeescript = [NSString stringWithContentsOfFile:coffeePath encoding:NSUTF8StringEncoding error:nil];
        NSString *compiledJavascript = [[coffeescriptCompiler callWithArguments:@[coffeescript]] toString];
        // TODO: check for null javascript - indicates coffescript syntax error
        [self.jsContext evaluateScript:compiledJavascript];
    }
    
    
    // TODO? copy everything from window into root context? helps with compatibility with libraries that assume window === global === root
    
    for (JSValue *callback in self.loadedCallbacks) {
        [callback callWithArguments:@[]];
    }
}

- (JSValue *)getCoffeeScriptCompilationFunction {
    JSContext *coffeescriptCompilationContext = [[JSContext alloc] init];
    [self loadJavaScriptFileAt:[[NSBundle mainBundle] pathForResource:@"coffee-script" ofType:@"js" inDirectory:@"javascript"]
                   intoContext:coffeescriptCompilationContext];
    return coffeescriptCompilationContext[@"CoffeeScript"][@"compile"];
}

- (void)loadJavaScriptFileAt:(NSString *)jsPath intoContext:(JSContext *)jsContext {
    NSLog(@"loading javascript from %@",jsPath);
    NSString *javascript = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    [jsContext evaluateScript:javascript];
}

@end
