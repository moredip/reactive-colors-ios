reactive-colors-ios
===================

A proof-of-concept for ReactiveUnion - an unholy union of ReactiveCocoa and Bacon.js.

RAC + JavaScriptCore + CoffeeScript + Bacon.js == an interesting idea.

All the "business logic" for this simple little app is implemented in coffeescript, running in a JavaScriptCore context insde a native iOS app. We bridge between native iOS UI elements and coffeescript via ReactiveCocoa signals which are wired to Bacon.js signals, and vice versa.

get started
===========

    cd Reactive\ Colors
    pod install
    open Reactive\ Colors.xcworkspace
    
points of interest
===========

All of the app-specific iOS wiring logic is done here:
https://github.com/moredip/reactive-colors-ios/blob/master/Reactive%20Colors/Reactive%20Colors/RXCRootViewController.m#L45

The coffeescript app logic is here:
https://github.com/moredip/reactive-colors-ios/blob/master/Reactive%20Colors/Reactive%20Colors/javascript/root.coffee

The plumbing to bridge between RAC and Bacon.js is here:
https://github.com/moredip/reactive-colors-ios/blob/master/Reactive%20Colors/Reactive%20Colors/RXCJavascriptBridge.m
https://github.com/moredip/reactive-colors-ios/blob/master/Reactive%20Colors/Reactive%20Colors/javascript/rxu_bridge.coffee


