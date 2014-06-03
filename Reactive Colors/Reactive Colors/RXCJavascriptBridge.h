//
//  RXCJavascriptBridge.h
//  Reactive Colors
//
//  Created by Pete Hodgson on 6/1/14.
//  Copyright (c) 2014 Pete Hodgson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface RXCJavascriptBridge : NSObject

- (void)bootJavascript;

- (void)registerSignal:(RACSignal *)signal named:(NSString *)name;
- (RACSignal *)signalNamed:(NSString *)signalName;

@end
