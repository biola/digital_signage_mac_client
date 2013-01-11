//
//  AppDelegate.h
//  DigitalSignage
//
//  Created by Ryan Hall on 1/9/13.
//  Copyright (c) 2013 Biola University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindowController* prefs;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet WebView *webView;

- (IBAction)openPreferences:(id)sender;
- (IBAction)reloadSign:(id)sender;
- (IBAction)toggleMouse:(id)sender;
- (IBAction)togglePlay:(id)sender;

@end
