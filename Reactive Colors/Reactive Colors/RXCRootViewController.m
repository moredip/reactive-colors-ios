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
@property (weak, nonatomic) IBOutlet UIView *rgbContainerView;

@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;

@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;

@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLabel;

@property (weak, nonatomic) IBOutlet UISlider *hueSlider;
@property (weak, nonatomic) IBOutlet UISlider *saturationSlider;
@property (weak, nonatomic) IBOutlet UISlider *lightnessSlider;

@property (weak, nonatomic) IBOutlet UILabel *hueLabel;
@property (weak, nonatomic) IBOutlet UILabel *saturationLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightnessLabel;


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
    
    [self wireUpReactiveUnion];
}

- (void)wireUpReactiveUnion
{
    [self.js registerSignal:[self.redSlider rac_newValueChannelWithNilValue:nil] named:@"red-slider"];
    [self.js registerSignal:[self.greenSlider rac_newValueChannelWithNilValue:nil] named:@"green-slider"];
    [self.js registerSignal:[self.blueSlider rac_newValueChannelWithNilValue:nil] named:@"blue-slider"];
    [self.js registerSignal:[self.alphaSlider rac_newValueChannelWithNilValue:nil] named:@"alpha-slider"];
    
    RAC(self.redSlider,value) = [self.js signalNamed:@"red-slider"];
    RAC(self.greenSlider,value) = [self.js signalNamed:@"green-slider"];
    RAC(self.blueSlider,value) = [self.js signalNamed:@"blue-slider"];
    
    RAC(self.redLabel,text) = [self.js signalNamed:@"red-label"];
    RAC(self.greenLabel,text) = [self.js signalNamed:@"green-label"];
    RAC(self.blueLabel,text) = [self.js signalNamed:@"blue-label"];
    
    [self.js registerSignal:[self.hueSlider rac_newValueChannelWithNilValue:nil] named:@"hue-slider"];
    [self.js registerSignal:[self.saturationSlider rac_newValueChannelWithNilValue:nil] named:@"saturation-slider"];
    [self.js registerSignal:[self.lightnessSlider rac_newValueChannelWithNilValue:nil] named:@"lightness-slider"];
    
    RAC(self.hueSlider,value) = [self.js signalNamed:@"hue-slider"];
    RAC(self.saturationSlider,value) = [self.js signalNamed:@"saturation-slider"];
    RAC(self.lightnessSlider,value) = [self.js signalNamed:@"lightness-slider"];
    
    RAC(self.hueLabel,text) = [self.js signalNamed:@"hue-label"];
    RAC(self.saturationLabel,text) = [self.js signalNamed:@"saturation-label"];
    RAC(self.lightnessLabel,text) = [self.js signalNamed:@"lightness-label"];
    
    RACSignal *color = [[self.js signalNamed:@"color-dict"] map:^id(NSDictionary *rgba) {
            return [UIColor colorWithRed:[(NSNumber *)rgba[@"r"] floatValue]
                                   green:[(NSNumber *)rgba[@"g"] floatValue]
                                    blue:[(NSNumber *)rgba[@"b"] floatValue]
                                   alpha:[(NSNumber *)rgba[@"a"] floatValue]];
        }];
    
    
    RAC(self.rgbContainerView,backgroundColor) = color;
}

@end
