//
//  RXCRootViewController.m
//  Reactive Colors
//
//  Created by Pete Hodgson on 6/1/14.
//  Copyright (c) 2014 Pete Hodgson. All rights reserved.
//

#import "RXCRootViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "RXCJavascriptBridge.h"

@interface RXCRootViewController ()
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;
@property (weak, nonatomic) IBOutlet UIView *rgbContainerView;

@property (strong) RXCJavascriptBridge *js;

@end

@implementation RXCRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.js = [[RXCJavascriptBridge alloc] init];
        [self.js bootJavascript];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self wireUpToJavascript];
    
    //RACSignal *alphaSignal = [self.alphaSlider rac_newValueChannelWithNilValue:nil];

    //RAC(self.rgbContainerView,alpha) = alphaSignal;
}

- (void)wireUpToJavascript
{
    [self.js registerSignal:[self.redSlider rac_newValueChannelWithNilValue:nil] named:@"red-slider"];
    [self.js registerSignal:[self.greenSlider rac_newValueChannelWithNilValue:nil] named:@"green-slider"];
    [self.js registerSignal:[self.blueSlider rac_newValueChannelWithNilValue:nil] named:@"blue-slider"];
    [self.js registerSignal:[self.alphaSlider rac_newValueChannelWithNilValue:nil] named:@"alpha-slider"];
    
    RACSignal *color = [[self.js signalNamed:@"color-dict"] map:^id(NSDictionary *rgba) {
            return [UIColor colorWithRed:[(NSNumber *)rgba[@"r"] floatValue]
                                   green:[(NSNumber *)rgba[@"g"] floatValue]
                                    blue:[(NSNumber *)rgba[@"b"] floatValue]
                                   alpha:[(NSNumber *)rgba[@"a"] floatValue]];
        }];
    
    [color logAll];
    
    RAC(self.rgbContainerView,backgroundColor) = color;
    
    [color subscribeNext:^(id value) {
        NSLog(@"COLORRRRRRR: %@", value);
        self.rgbContainerView.backgroundColor = (UIColor *)value;
    }];
    
    
//    RAC(self.rgbContainerView,alpha) = [self.js signalNamed:@"alpha-channel"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
