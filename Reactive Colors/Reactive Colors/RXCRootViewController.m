//
//  RXCRootViewController.m
//  Reactive Colors
//
//  Created by Pete Hodgson on 6/1/14.
//  Copyright (c) 2014 Pete Hodgson. All rights reserved.
//

#import "RXCRootViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface RXCRootViewController ()
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;
@property (weak, nonatomic) IBOutlet UIView *rgbContainerView;

@property (strong) JSContext *jsContext;

@end

@implementation RXCRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.jsContext = [self enhancedJSContext];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RACSignal *alphaSignal = [self.alphaSlider rac_newValueChannelWithNilValue:nil];
    
    [alphaSignal subscribeNext:^(NSNumber *val) {
        NSLog( @"alpha slider is at %@", val);
    }];
    
    RAC(self.rgbContainerView,alpha) = alphaSignal;
    
    [self bootJavascriptInto:self.jsContext];
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
    
    return jsContext;
}

- (void)bootJavascriptInto:(JSContext *)jsContext
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"root" ofType:@"js"];
    NSString *javascript = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [jsContext evaluateScript:javascript];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
