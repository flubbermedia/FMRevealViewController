//
//  FMSlideViewController.m
//  FMSlideViewController
//
//  Created by Andrea Ottolina on 30/08/2012.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "FMRevealViewController.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark -
#pragma mark Constants
const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration = 0.3f;
const CGFloat kGHRevealSidebarWidth = 272.0f;
const CGFloat kGHRevealSidebarFlickVelocity = 500.0f;

typedef enum {
	ViewControllerTypeContent = 0,
	ViewControllerTypeSide
} ViewControllerType;

#pragma mark -
#pragma mark Private Interface
@interface FMRevealViewController ()

@end

#pragma mark -
#pragma mark Implementation
@implementation FMRevealViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_sideViewShowing = NO;
		_revealSide = RevealSideViewLeft;
		
		self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		_sideView = [[UIView alloc] initWithFrame:self.view.bounds];
		_sideView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_sideView.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_sideView];
		
		_contentView = [[UIView alloc] initWithFrame:self.view.bounds];
		_contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_contentView.backgroundColor = [UIColor clearColor];
		_contentView.layer.masksToBounds = NO;
		_contentView.layer.shadowColor = [UIColor blackColor].CGColor;
		_contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		_contentView.layer.shadowOpacity = 1.0f;
		_contentView.layer.shadowRadius = 2.5f;
		_contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_contentView.bounds].CGPath;
		[self.view addSubview:_contentView];
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragContentView:)];
		panGesture.cancelsTouchesInView = YES;
		[_contentView addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)setContentViewController:(UIViewController *)vc {
	[self updateViewController:vc ofType:ViewControllerTypeContent];
}

- (void)setSideViewController:(UIViewController *)vc {
	[self updateViewController:vc ofType:ViewControllerTypeSide];
}

- (void)updateViewController:(UIViewController *)vc ofType:(ViewControllerType)type
{
	__block UIViewController *targetViewController = nil;
	__block UIView *targetView = nil;
	if (type == 0)
	{
		targetViewController = _contentViewController;
		targetView = _contentView;
	}
	else if (type == 1)
	{
		targetViewController = _sideViewController;
		targetView = _sideView;
	}
	else
	{
		return;
	}
	
	
	if (targetViewController == nil) {
		vc.view.frame = targetView.bounds;
		targetViewController = vc;
		[self addChildViewController:targetViewController];
		[targetView addSubview:targetViewController.view];
		[targetViewController didMoveToParentViewController:self];
	} else if (targetViewController != vc) {
		vc.view.frame = targetView.bounds;
		[targetViewController willMoveToParentViewController:nil];
		[self addChildViewController:vc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:targetViewController
						  toViewController:vc
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[targetViewController removeFromParentViewController];
									[vc didMoveToParentViewController:self];
									targetViewController = vc;
								}
		 ];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Private Methods
- (void)dragContentView:(UIPanGestureRecognizer *)panGesture
{
	CGFloat translation = [panGesture translationInView:self.view].x;
	CGFloat velocity = [panGesture velocityInView:self.view].x;
	CGFloat xOffset = (_sideViewShowing) ? _revealSide * kGHRevealSidebarWidth : 0.0f;
	CGFloat xReference = (_revealSide == RevealSideViewLeft) ? CGRectGetMinX(_contentView.bounds) : CGRectGetMinX(_contentView.bounds);
	CGFloat xOrigin = xReference + xOffset + translation;
	
	if (panGesture.state == UIGestureRecognizerStateBegan)
	{
		[self callWillChangeDelegate];
	}
	else if (panGesture.state == UIGestureRecognizerStateChanged)
	{
		CGFloat xMin = 0.0f;
		CGFloat xMax = CGRectGetMaxX(self.view.bounds);
		
		if (_revealSide == RevealSideViewRight)
		{
			xMin = -CGRectGetMaxX(self.view.bounds);
			xMax = 0.0f;
		}
		
		CGFloat xDelta = (xOrigin > xMin && xOrigin < xMax)
		? xOffset + translation
		: ((xOrigin > xMax) ? xMax : xMin);
		
		_contentView.frame = CGRectOffset(_contentView.bounds, xDelta, 0.0f);
		
	}
	else if (panGesture.state == UIGestureRecognizerStateEnded)
	{
		BOOL show = (fabs(velocity) > kGHRevealSidebarFlickVelocity)
		? _revealSide * velocity > 0.0f
		: _revealSide * xOrigin > (kGHRevealSidebarWidth / 2);
		
		[self toggleSideView:show animated:YES completion:^(BOOL finshed){}];
	}
}

- (void)toggleSideView:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finsihed))completion {
	void (^animations)(void) = ^{
		if (show) {
			_contentView.frame = CGRectOffset(_contentView.bounds, _revealSide * kGHRevealSidebarWidth, 0.0f);
		} else {
			_contentView.frame = _contentView.bounds;
		}
		_sideViewShowing = show;
	};
	void (^completionBlock)(BOOL finished) = ^(BOOL finished){
		completion(finished);
		[self callDidChangeDelegate];
	};
	UIViewAnimationOptions animationOption = (show) ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseInOut;
	if (animated) {
		[UIView animateWithDuration:kGHRevealSidebarDefaultAnimationDuration
							  delay:0
							options:animationOption
						 animations:animations
						 completion:completionBlock];
	} else {
		animations();
		completionBlock(YES);
	}
}

#pragma mark Public Methods
- (void)toggleSideView:(BOOL)animated;
{
	[self callWillChangeDelegate];
	[self toggleSideView:!_sideViewShowing animated:animated completion:^(BOOL finshed){}];
}

- (void)openSideView:(BOOL)animated;
{
	[self callWillChangeDelegate];
	[self toggleSideView:YES animated:animated completion:^(BOOL finshed){}];
}

- (void)closeSideView:(BOOL)animated;
{
	[self callWillChangeDelegate];
	[self toggleSideView:NO animated:animated completion:^(BOOL finshed){}];
}

#pragma mark Delegate Calls
- (void)callWillChangeDelegate
{
	if (_sideViewShowing == NO)
	{
		if ([_delegate respondsToSelector:@selector(revealViewControllerWillOpen:)])
		{
			[_delegate revealViewControllerWillOpen:self];
		}
	}
	else
	{
		if ([_delegate respondsToSelector:@selector(revealViewControllerWillClose:)])
		{
			[_delegate revealViewControllerWillClose:self];
		}
	}
}

- (void)callDidChangeDelegate
{
	if (_sideViewShowing == YES)
	{
		if ([_delegate respondsToSelector:@selector(revealViewControllerDidOpen:)])
		{
			[_delegate revealViewControllerDidOpen:self];
		}
	}
	else
	{
		if ([_delegate respondsToSelector:@selector(revealViewControllerDidClose:)])
		{
			[_delegate revealViewControllerDidClose:self];
		}
	}
}

@end
