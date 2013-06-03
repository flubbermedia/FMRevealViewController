//
//  FMSlideViewController.h
//  FMSlideViewController
//
//  Created by Andrea Ottolina on 30/08/2012.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	RevealSideViewLeft = 1,
	RevealSideViewRight = -1
} RevealSideView;

@protocol FMRevealViewControllerDelegate;

@interface FMRevealViewController : UIViewController <UIGestureRecognizerDelegate> {
@private
	UIView *_sideView;
	UIView *_contentView;
}

@property (nonatomic, weak) id<FMRevealViewControllerDelegate> delegate;
@property (nonatomic, readonly, getter = isSideViewShowing) BOOL sideViewShowing;
@property (nonatomic, assign) RevealSideView revealSide;
@property (strong, nonatomic) UIViewController *sideViewController;
@property (strong, nonatomic) UIViewController *contentViewController;

- (void)toggleSideView:(BOOL)animated;
- (void)openSideView:(BOOL)animated;
- (void)closeSideView:(BOOL)animated;

@end

@protocol FMRevealViewControllerDelegate <NSObject>

@optional

- (void)revealViewControllerWillOpen:(FMRevealViewController*)revealViewController;
- (void)revealViewControllerDidOpen:(FMRevealViewController*)revealViewController;
- (void)revealViewControllerWillClose:(FMRevealViewController*)revealViewController;
- (void)revealViewControllerDidClose:(FMRevealViewController*)revealViewController;

- (BOOL)revealViewControllerShouldReceiveTouch:(UITouch *)touch;

@end
