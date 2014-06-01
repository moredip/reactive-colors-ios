//
//  RXCAppDelegate.h
//  Reactive Colors
//
//  Created by Pete Hodgson on 5/31/14.
//  Copyright (c) 2014 Pete Hodgson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RXCRootViewController;

@interface RXCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RXCRootViewController *viewController;

@end
