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
const UIViewAnimationOptions kFMRevealViewUpdateTransitionType = UIViewAnimationOptionTransitionCrossDissolve;
const NSTimeInterval kFMRevealViewUpdateTransitionDuration = 0.1f;
const NSTimeInterval kFMRevealViewDefaultAnimationDuration = 0.3f;
const CGFloat kFMRevealViewOpenedWidth = 272.0f;
const CGFloat kFMRevealViewFlickVelocity = 500.0f;

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
		_contentView.layer.shadowOffset = CGSizeMake(1.0f, 0.0f);
		_contentView.layer.shadowOpacity = 0.75f;
		_contentView.layer.shadowRadius = 3.0f;
		_contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_contentView.bounds].CGPath;
		[self.view addSubview:_contentView];
		
		UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragContentView:)];
		panGesture.cancelsTouchesInView = YES;
		panGesture.delegate = self;
		[_contentView addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)setSideViewController:(UIViewController *)svc {
	if (_sideViewController == nil) {
		svc.view.frame = _sideView.bounds;
		_sideViewController = svc;
		[self addChildViewController:_sideViewController];
		[_sideView addSubview:_sideViewController.view];
		[_sideViewController didMoveToParentViewController:self];
	} else if (_sideViewController != svc) {
		svc.view.frame = _sideView.bounds;
		[_sideViewController willMoveToParentViewController:nil];
		[self addChildViewController:svc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_sideViewController
						  toViewController:svc
								  duration:kFMRevealViewUpdateTransitionDuration
								   options:kFMRevealViewUpdateTransitionType
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_sideViewController removeFromParentViewController];
									[svc didMoveToParentViewController:self];
									_sideViewController = svc;
								}
		 ];
	}
}

- (void)setContentViewController:(UIViewController *)cvc {
	if (_contentViewController == nil) {
		cvc.view.frame = _contentView.bounds;
		_contentViewController = cvc;
		[self addChildViewController:_contentViewController];
		[_contentView addSubview:_contentViewController.view];
		[_contentViewController didMoveToParentViewController:self];
	} else if (_contentViewController != cvc) {
		cvc.view.frame = _contentView.bounds;
		[_contentViewController willMoveToParentViewController:nil];
		[self addChildViewController:cvc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_contentViewController
						  toViewController:cvc
								  duration:kFMRevealViewUpdateTransitionDuration
								   options:kFMRevealViewUpdateTransitionType
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_contentViewController removeFromParentViewController];
									[cvc didMoveToParentViewController:self];
									_contentViewController = cvc;
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
	CGFloat xOffset = (_sideViewShowing) ? _revealSide * kFMRevealViewOpenedWidth : 0.0f;
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
		
		CGFloat xDelta = (xOrigin >= xMin && xOrigin <= xMax)
		? xOffset + translation
		: ((xOrigin > xMax) ? xMax : xMin);
		
		_contentView.frame = CGRectOffset(_contentView.bounds, xDelta, 0.0f);
		
	}
	else if (panGesture.state == UIGestureRecognizerStateEnded)
	{
		BOOL show = (fabs(velocity) > kFMRevealViewFlickVelocity)
		? _revealSide * velocity > 0.0f
		: _revealSide * xOrigin > (kFMRevealViewOpenedWidth / 2);
		
		[self toggleSideView:show animated:YES completion:^(BOOL finshed){}];
	}
}

- (void)toggleSideView:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finsihed))completion {
	void (^animations)(void) = ^{
		if (show) {
			_contentView.frame = CGRectOffset(_contentView.bounds, _revealSide * kFMRevealViewOpenedWidth, 0.0f);
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
		[UIView animateWithDuration:kFMRevealViewDefaultAnimationDuration
							  delay:0
							options:animationOption
						 animations:animations
						 completion:completionBlock];
	} else {
		animations();
		completionBlock(YES);
	}
}

#pragma mark Pan Gesture Delegates
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (_viewForPanGesture && touch.view != _viewForPanGesture)
	{
		return NO;
	}
	return YES;
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
