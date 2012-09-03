//
//  ViewController.m
//  Demo
//
//  Created by Andrea Ottolina on 03/09/2012.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "ViewController.h"
#import "FMRevealViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)toggleSideView:(id)sender
{
	FMRevealViewController *revealViewController = (FMRevealViewController *)self.parentViewController;
	[revealViewController toggleSideView:YES];
}

@end
