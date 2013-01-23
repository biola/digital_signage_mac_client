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
    [[NSUserDefaultsController sharedUserDefaultsController] setAppliesImmediately:YES];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues()];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues()];
    
    // Add fullscreen support if supported (> 10.7)
    if ([self.window respondsToSelector:@selector(toggleFullScreen:)]) {
        [self.window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    }
    
    [self toggleFullScreen:nil];
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
    if (launchUrl == nil) { launchUrl = @"http://www.biola.edu"; }
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

- (IBAction)toggleFullScreen:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FullScreenLaunch]) {
        // Use lion's built in full screen API if available
        if ([self.window respondsToSelector:@selector(toggleFullScreen:)]) {
            [self.window toggleFullScreen:self];
        }
        else {  // Add support for snow leapard
            if ([self.webView isInFullScreenMode]) {
                [self.webView exitFullScreenModeWithOptions:nil];
            } else {
                [self.webView enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
            }
        }
    }
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    NSLog(@"Page failed to load. Scheduling Reload Timer");
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(reloadSign:) userInfo:nil repeats:NO];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end

