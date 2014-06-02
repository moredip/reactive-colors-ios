//
//  RXCRootViewController.m
//  Reactive Colors
//
//  Created by Pete Hodgson on 6/1/14.
//  Copyright (c) 2014 Pete Hodgson. All rights reserved.
//

#import "RXCRootViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RXCRootViewController ()
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;
@property (weak, nonatomic) IBOutlet UIView *rgbContainerView;

@end

@implementation RXCRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
