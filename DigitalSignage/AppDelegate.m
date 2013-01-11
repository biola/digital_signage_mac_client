//
//  AppDelegate.m
//  DigitalSignage
//
//  Created by Ryan Hall on 1/9/13.
//  Copyright (c) 2013 Biola University. All rights reserved.
//

#import "AppDelegate.h"

#define LaunchUrl @"LaunchUrl"
#define HideMouse @"HideMouse"
#define FullScreenLaunch @"FullScreenLaunch"


static NSDictionary *defaultValues() {
    static NSDictionary *dict = nil;
    if (!dict) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"http://google.com", LaunchUrl,
                [NSNumber numberWithBool:NO], HideMouse,
                [NSNumber numberWithBool:NO], FullScreenLaunch,
                nil];
    }
    return dict;
}


@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Set up default values for preferences managed by NSUserDefaultsController
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues()];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues()];
    
    
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FullScreenLaunch]) {
        [self.window toggleFullScreen:self];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:HideMouse]) {
        [NSCursor hide];
    }
}

- (void)awakeFromNib {
    [self reloadSign:nil];
}

- (IBAction)openPreferences:(id)sender {
    prefs = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
    [[prefs window] display];
    [[prefs window] makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] arrangeInFront:nil];
}

- (IBAction)reloadSign:(id)sender {
    NSLog(@"Reloading Page");
    [[self.webView mainFrame] stopLoading];
    NSString *launchUrl = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:LaunchUrl];
    NSURL *url = [NSURL URLWithString:launchUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setFrameLoadDelegate:self];
    [[self.webView mainFrame] loadRequest:request];
}

- (IBAction)toggleMouse:(id)sender {
    if (CGCursorIsVisible()) {
        [NSCursor hide];
    } else {
        [NSCursor unhide];
    }
}

- (IBAction)togglePlay:(id)sender {
    [self.webView stringByEvaluatingJavaScriptFromString:@"togglePlay()"];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    NSLog(@"Page failed to load. Scheduling Reload Timer");
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(reloadSign:) userInfo:nil repeats:NO];
}


@end

