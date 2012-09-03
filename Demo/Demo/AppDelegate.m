//
//  AppDelegate.m
//  Demo
//
//  Created by Andrea Ottolina on 03/09/2012.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SideViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	
	FMRevealViewController *revealViewController = [[FMRevealViewController alloc] init];
	revealViewController.contentViewController = [[ViewController alloc] init];
	revealViewController.sideViewController = [[SideViewController alloc] init];
	revealViewController.delegate = self;
	
	self.window.rootViewController = revealViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma Delegates

- (void)revealViewControllerWillOpen:(FMRevealViewController *)revealViewController
{
	NSLog(@"revealViewControllerWillOpen");
}

- (void)revealViewControllerDidOpen:(FMRevealViewController *)revealViewController
{
	NSLog(@"revealViewControllerDidOpen");
}

- (void)revealViewControllerWillClose:(FMRevealViewController *)revealViewController
{
	NSLog(@"revealViewControllerWillClose");
}

- (void)revealViewControllerDidClose:(FMRevealViewController *)revealViewController
{
	NSLog(@"revealViewControllerDidClose");
}

@end
