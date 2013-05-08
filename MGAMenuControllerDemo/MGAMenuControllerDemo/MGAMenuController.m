//
//  MGAMenuController.m
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import "MGAMenuController.h"
#import "MGADropShadowView.h"
#import <QuartzCore/QuartzCore.h>

//Anonymous Category
@interface MGAMenuController() {
@private
    //Hide to stop overriding of default navigationbar buttons
    BOOL hideNavigationBarButtons;

    //Gesture recognizer for a tap to dismiss the drawer
    UIGestureRecognizer *tapDismissGesture;
    
    BOOL changingRootView;
    
    //NavigationBar variables 
    UIBarButtonItem *leftBarButton;
    UIBarButtonItem *rightBarButton;
    BOOL leftBarButtonAdded;
    BOOL rightBarButtonAdded;
    
    //Drop shadow view
    MGADropShadowView *dropShadowView;
    
    //Reference to the currentRootViewController's view
    UIView *rootView;
    
    //Default drawers set on the menu (can be overridden by those in root view controllers)
    UIViewController<MGADrawerViewControllerProtocol> *displayedLeftDrawer;
    UIViewController<MGADrawerViewControllerProtocol> *displayedRightDrawer;
    
    UIViewController<MGADrawerViewControllerProtocol> *overriddenLeftDrawer;
    UIViewController<MGADrawerViewControllerProtocol> *overriddenRightDrawer;
    BOOL leftDrawerOverridden;
    BOOL rightDrawerOverridden;
    
    BOOL leftDrawerVisible;
    BOOL rightDrawerVisible;
    
}
/** Current view controller as root in the nav stack */
@property (nonatomic, strong) UIViewController *currentRootViewController;

/** Wrapper view for what is displayed by the MGAMenuController */
@property (nonatomic, strong) UIView *containerView;

/** Internal navigation controller */
@property (nonatomic, strong) UINavigationController *navigationController;


- (void) showDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerVC Direction:(SlideDirection)direction;

- (void) dismissDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerVC Direction:(SlideDirection)direction animated:(BOOL)animated;
- (void) dismissDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerVC Direction:(SlideDirection)direction animated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void) validateNavigationBarButtons;
- (void) validateDisplayedDrawer;

@end


//Implementation
@implementation MGAMenuController

@synthesize leftDrawer = _leftDrawer, rightDrawer = _rightDrawer;

@synthesize containerView = _containerView;
@synthesize navigationController = _navigationController, currentRootViewController = _currentRootViewController;


#pragma mark - Initializers

- (id) init {
    return [self initWithLeftDrawer:nil RightDrawer:nil andRootViewController:nil];
}

- (id)initWithLeftDrawer:(UIViewController<MGADrawerViewControllerProtocol> *) leftDrawer RightDrawer:(UIViewController<MGADrawerViewControllerProtocol> *) rightDrawer andRootViewController:(UIViewController *) viewController
{
    self = [super init];
    if (self) {
        tapDismissGesture = [[UITapGestureRecognizer alloc] init];
        
        leftDrawerVisible = NO;
        rightDrawerVisible = NO;
        
        changingRootView = NO;
        
        hideNavigationBarButtons = NO;
        
        leftDrawerOverridden = NO;
        rightDrawerOverridden = NO;
        
        //Initialize wrapper view
        _containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [_containerView setBackgroundColor:[UIColor blueColor]];
        
        //Create navigation controller
        _navigationController = [[UINavigationController alloc] init];
        [_navigationController setDelegate:self];
        
        //Add the nav controller as a child of the MenuController.
        //PS: The viewcontroller set on the nav stack will NOT have to be set as childs since this is handled by the navigationController
        [self addChildViewController:_navigationController];
        
        //Create navigation bar button
        rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuIcon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showRightDrawer)];
        leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuIcon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showLeftDrawer)];

        
        [self setLeftDrawer:leftDrawer];
        [self setRightDrawer:rightDrawer];
        
        //Don't set nil as rootView
        if (viewController)
            [self setCurrentRootViewController:viewController];
        else
            [self setCurrentRootViewController:[[UIViewController alloc] init]];
    }
    return self;
}


- (void)loadView 
{
    //Create container's view
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self setView:_containerView];
    
    //Navigation Controller
    [_navigationController.view setFrame:CGRectMake(_containerView.frame.origin.x, 
                                                    _containerView.frame.origin.y-20, 
                                                    _containerView.frame.size.width,
                                                    _containerView.frame.size.height)];    
}


#pragma mark - Property setter override

- (void) setCurrentRootViewController:(UIViewController *)rootViewController 
{
    if (rootViewController && rootViewController != _currentRootViewController) {
                
        //Remove previos rootVC's view if necessary
        if (rootView)
            [rootView removeFromSuperview];
        rootView = rootViewController.view;
        
        //Remove navigationController's view
        [_navigationController.view removeFromSuperview];
        
        //Set new rootVC
        _currentRootViewController = rootViewController;
        
        
        //Clean previous override (if any)
        if (leftDrawerOverridden) {
            [overriddenLeftDrawer willMoveToParentViewController:nil]; //Most likely not necessary, just to be safe
            [overriddenLeftDrawer removeFromParentViewController]; //Most likely not necessary, just to be safe
            overriddenLeftDrawer = nil;
            leftDrawerOverridden = NO;
        }
        if (rightDrawerOverridden) {
            [overriddenRightDrawer willMoveToParentViewController:nil]; //Most likely not necessary, just to be safe
            [overriddenLeftDrawer removeFromParentViewController]; //Most likely not necessary, just to be safe
            overriddenRightDrawer = nil;
            rightDrawerOverridden = NO;
        }
        
        //Check if vc overriding drawer
        if ([rootViewController conformsToProtocol:@protocol(MGARootViewControllerProtocol)]) 
        {
            //Check if overriding left drawer
            if ([rootViewController respondsToSelector:@selector(leftDrawerForMenuController:)]) 
            {
                UIViewController<MGADrawerViewControllerProtocol> * overridingDrawer = [(UIViewController<MGARootViewControllerProtocol> *) rootViewController leftDrawerForMenuController:self];
                overriddenLeftDrawer = overridingDrawer;
                [overriddenLeftDrawer setMenuController:self];
                leftDrawerOverridden = YES;
            }
            
            //Check if overriding right drawer
            if ([rootViewController respondsToSelector:@selector(rightDrawerForMenuController:)]) 
            {
                UIViewController<MGADrawerViewControllerProtocol> * overridingDrawer = [(UIViewController<MGARootViewControllerProtocol> *) rootViewController rightDrawerForMenuController:self];
                overriddenRightDrawer = overridingDrawer;
                [overriddenRightDrawer setMenuController:self];
                rightDrawerOverridden = YES;
            }
        }
        
        [self validateDisplayedDrawer];
        
        //Add new rootVC's view to stack
        [_navigationController setViewControllers:[NSArray arrayWithObject:_currentRootViewController]];
        [_containerView addSubview:_navigationController.view];
    }
}

- (void)setLeftDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerViewController 
{
    if (drawerViewController && drawerViewController != _leftDrawer) {
        
        if (_leftDrawer) {
            [_leftDrawer willMoveToParentViewController:nil];
            [_leftDrawer removeFromParentViewController];
        }
        
        //Set instance variable
        _leftDrawer = drawerViewController;
        
        //Set self as menu controller
        [_leftDrawer setMenuController:self];
        
        //Add navigation bar button
        [self validateDisplayedDrawer];
    }
}

- (void) setRightDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerViewController 
{
    if (drawerViewController && drawerViewController != _rightDrawer) {
        
        if (_rightDrawer) {
            [_rightDrawer willMoveToParentViewController:nil];
            [_rightDrawer removeFromParentViewController];
        }
        
        //Set instance variable
        _rightDrawer = drawerViewController;

        //Set self as menu controller
        [_rightDrawer setMenuController:self];
        
        //Add navigation bar button
        [self validateDisplayedDrawer]; 
    }    
}

- (void) validateDisplayedDrawer 
{
    if (!_currentRootViewController)
        return;
    
    //Check if left drawer needs to be set to overridden
    if (leftDrawerOverridden && displayedLeftDrawer != overriddenLeftDrawer) {
        displayedLeftDrawer = overriddenLeftDrawer;
        
    //Check if left drawer needs to be set to default. This includes setting to nil if _leftDrawer was not set.
    } else if (!leftDrawerOverridden && displayedLeftDrawer != _leftDrawer) {
        displayedLeftDrawer = _leftDrawer;
    }
    
    //Same for right
    if (rightDrawerOverridden && displayedRightDrawer != overriddenRightDrawer) {
        displayedRightDrawer = overriddenRightDrawer;
    } else if (!rightDrawerOverridden && displayedRightDrawer != _rightDrawer) {
        displayedRightDrawer = _rightDrawer;
    }
    
    //Ensure the correct buttons are shown
    [self validateNavigationBarButtons];
}

- (void) validateNavigationBarButtons {
    
    rightBarButtonAdded = NO;
    leftBarButtonAdded = NO;
    
    if (!_currentRootViewController)
        return;
    
    //CASE 1: Not hiding buttons
    if (!hideNavigationBarButtons) {
        
        //Check if right should be set (drawer set and not trampling existing button)
        if (displayedRightDrawer && !_currentRootViewController.navigationItem.rightBarButtonItem) {
            [_currentRootViewController.navigationItem setRightBarButtonItem:rightBarButton];
            rightBarButtonAdded = YES;
            //Check if right was removed and button had been set, then we remove the button
        } else if (!displayedRightDrawer && _currentRootViewController.navigationItem.rightBarButtonItem == rightBarButton) {
            [_currentRootViewController.navigationItem setRightBarButtonItem:nil];
            //If we get here, we need a button and we have already set it. So we don't add it again, but set the BOOL to YES
        } else if (_currentRootViewController.navigationItem.rightBarButtonItem == rightBarButton) {
            rightBarButtonAdded = YES;
        }
        
        //Check if left should be set (drawer set and not trampling existing button)
        if (displayedLeftDrawer && !_currentRootViewController.navigationItem.leftBarButtonItem) {
            [_currentRootViewController.navigationItem setLeftBarButtonItem:leftBarButton];
            leftBarButtonAdded = YES;
            //Check if right left removed and button had been set, then we remove the button
        } else if (!displayedLeftDrawer && _currentRootViewController.navigationItem.leftBarButtonItem == leftBarButton) {
            [_currentRootViewController.navigationItem setLeftBarButtonItem:nil];
            //If we get here, we need a button and we have already set it. So we don't add it again, but set the BOOL to YES
        } else if (_currentRootViewController.navigationItem.leftBarButtonItem == leftBarButton) {
            leftBarButtonAdded = YES;
        }
        
    //CASE 2: Hiding buttons
    } else {
        
        // Check if right button need to be removed
        if (_currentRootViewController.navigationItem.rightBarButtonItem == rightBarButton)
            [_currentRootViewController.navigationItem setRightBarButtonItem:nil];
        
        // Check if left button need to be removed
        if (_currentRootViewController.navigationItem.leftBarButtonItem == leftBarButton)
            [_currentRootViewController.navigationItem setLeftBarButtonItem:nil];
    }   
}


#pragma mark - MGAMenu Settings

- (void) hideDefaultNavigationBarButtons:(BOOL)hideNavButtons 
{
    if (hideNavButtons) {
        hideNavigationBarButtons = YES;
        [self validateNavigationBarButtons];
    } else {
        hideNavigationBarButtons = NO;
        [self validateNavigationBarButtons];
    }
}


#pragma mark - Drawer Management

//Public API - Show the left drawer if not visible
- (void) showLeftDrawer 
{
    if (!leftDrawerVisible) {
        [tapDismissGesture addTarget:self action:@selector(dismissLeftDrawer)];
        [self showDrawer:displayedLeftDrawer Direction:kSHOW_LEFT];
    }else{
        [self dismissLeftDrawer];
    }
}

//Public API - Show the right drawer if not visible
- (void) showRightDrawer 
{
    if (!rightDrawerVisible) {
        [tapDismissGesture addTarget:self action:@selector(dismissRightDrawer)];
        [self showDrawer:displayedRightDrawer Direction:kSHOW_RIGHT];
    }else{
        [self dismissRightDrawer];
    }
}

//Private method - Show given drawer at the indicated direction
- (void) showDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerVC Direction:(SlideDirection)direction  
{
    //Set up child viewcontroller relationship
    [self addChildViewController:drawerVC];
    [_containerView insertSubview:drawerVC.view atIndex:0];
    
    //Set drawer view frame
    int drawerWidth = drawerVC.drawerView.frame.size.width;
    int drawerX = (direction == kSHOW_LEFT) ? 0 : (_navigationController.view.frame.size.width-drawerWidth);
    [drawerVC.view setFrame:CGRectMake(0, 0, _navigationController.view.frame.size.width, _navigationController.view.frame.size.height)];
    drawerVC.drawerView.frame = CGRectMake(drawerX, 
                                           drawerVC.drawerView.frame.origin.y, 
                                           drawerWidth, 
                                           _navigationController.view.frame.size.height);
    
    //Add shadow view
    int shadowX = (direction == kSHOW_LEFT) ? -20 : 20;
    dropShadowView = [[MGADropShadowView alloc] init];
    [dropShadowView setFrame:CGRectMake(shadowX, 0, _navigationController.view.frame.size.width, _navigationController.view.frame.size.height)];
    [dropShadowView setShadowDirection:(direction == kSHOW_LEFT) ? kLEFT : kRIGHT];
    [_containerView insertSubview:dropShadowView atIndex:1];
    
    //Perform animation to show the drawer
    [UIView animateWithDuration:0.3
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         int newX = (direction == kSHOW_LEFT) ? drawerWidth : -drawerWidth;
                         [_navigationController.view setFrame:CGRectMake(newX, 
                                                       _navigationController.view.frame.origin.y, 
                                                       _navigationController.view.frame.size.width, 
                                                       _navigationController.view.frame.size.height)];
                         [dropShadowView setFrame:CGRectMake((direction == kSHOW_LEFT) ? newX-20 : newX+20, 
                                                             dropShadowView.frame.origin.y, 
                                                             dropShadowView.frame.size.width, 
                                                             dropShadowView.frame.size.height)];

                     } 
                     completion:^(BOOL finished) {
                         //Set flag
                         direction == kSHOW_LEFT ? (leftDrawerVisible = YES) : (rightDrawerVisible = YES);
                         //Add Gesture recognizer to dismiss the drawer
                         [rootView addGestureRecognizer:tapDismissGesture];
                     }
     ];
}

//Public API - Dismiss left drawer if showing
- (void) dismissLeftDrawer {
    if (leftDrawerVisible)
        [self dismissDrawer:displayedLeftDrawer Direction:kHIDE_LEFT animated:YES];
}

//Public API - Dismiss right drawer if showing
- (void) dismissRightDrawer {
    if (rightDrawerVisible)
        [self dismissDrawer:displayedRightDrawer Direction:kHIDE_RIGHT animated:YES];
}

//Public API - Dismiss whichever drawer is visible
- (void) dismissVisibleDrawer {
    if (leftDrawerVisible)
        [self dismissLeftDrawer];
    else if (rightDrawerVisible)
        [self dismissRightDrawer];
}

//Private method - Perform the dismissal action of the given drawer
- (void) dismissDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerVC Direction:(SlideDirection)direction animated:(BOOL)animated {
    [self dismissDrawer:drawerVC Direction:direction animated:animated duration:0.3 delay:0.0];
}

- (void) dismissDrawer:(UIViewController<MGADrawerViewControllerProtocol> *)drawerVC Direction:(SlideDirection)direction animated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    
    //Remove tap gesture recognizer    
    [rootView removeGestureRecognizer:tapDismissGesture];
    if (direction == kHIDE_LEFT)
        [tapDismissGesture removeTarget:self action:@selector(dismissLeftDrawer)];
    else
        [tapDismissGesture removeTarget:self action:@selector(dismissRightDrawer)];
    
    //The animation blocks are created here. This way, if the dismissal is not animated, they can just be run outside of the animation method.
    //Block to set new positions (animation if animated)
    void (^setNewPositionsBlock)() = ^{        
        [_navigationController.view setFrame:CGRectMake(0, 
                                      _navigationController.view.frame.origin.y, 
                                      _navigationController.view.frame.size.width, 
                                      _navigationController.view.frame.size.height)];
        [dropShadowView setFrame:CGRectMake((direction == kHIDE_LEFT) ? 0-20 : 0+20, 
                                            dropShadowView.frame.origin.y, 
                                            dropShadowView.frame.size.width, 
                                            dropShadowView.frame.size.height)];
    };
    
    //Block to remove drop shadow and drawer views (after animation if animated)
    void (^cleanupBlock)(BOOL finished) =  ^(BOOL finished){        
        //Remove view
        [drawerVC.view removeFromSuperview];
        
        //Remove ViewController
        [drawerVC willMoveToParentViewController:nil];
        [drawerVC removeFromParentViewController];
        
        //Remove DropShadowView
        [dropShadowView removeFromSuperview];
        dropShadowView = nil;
        
        changingRootView = NO;
        direction == kHIDE_LEFT ? (leftDrawerVisible = NO) : (rightDrawerVisible = NO);
    };
    
    //If dismiss is animated perform animation with block otherwise just execute them
    if (animated) {
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationCurveEaseInOut animations:setNewPositionsBlock completion:cleanupBlock];
    } else {
        setNewPositionsBlock();
        cleanupBlock(YES);
    }
}


#pragma mark - MGAMenuController API

- (UIViewController *) rootViewController 
{
    return _currentRootViewController;
}

- (void) setRootViewController:(UIViewController *) viewController 
{
    [self setRootViewController:viewController animated:NO];
}

- (void) setRootViewController:(UIViewController *) viewController animated:(BOOL)animated 
{    
    //Animate if rightDrawer is currently visible
    if ((rightDrawerVisible || leftDrawerVisible) && animated) {
        changingRootView = YES;
        [UIView animateWithDuration:0.2 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             int offsetX = 0;
                             if (leftDrawerVisible) {
                                 offsetX = _navigationController.view.frame.size.width-displayedLeftDrawer.drawerView.frame.size.width+20;
                             } else {
                                 offsetX = -(_navigationController.view.frame.size.width-displayedRightDrawer.drawerView.frame.size.width+20);
                             }
                             [_navigationController.view setFrame:CGRectMake(_navigationController.view.frame.origin.x+offsetX, 
                                                             _navigationController.view.frame.origin.y, 
                                                             _navigationController.view.frame.size.width, 
                                                             _navigationController.view.frame.size.height)];
                             [dropShadowView setFrame:CGRectMake(dropShadowView.frame.origin.x+offsetX, 
                                                                 dropShadowView.frame.origin.y, 
                                                                 dropShadowView.frame.size.width, 
                                                                 dropShadowView.frame.size.height)];
                         } completion:^(BOOL finished) {
                             UIViewController<MGADrawerViewControllerProtocol> *currentDrawer;
                             SlideDirection dismissDirection;
                             if (leftDrawerVisible) {
                                 currentDrawer = displayedLeftDrawer;
                                 dismissDirection = kHIDE_LEFT;
                             } else {
                                 currentDrawer = displayedRightDrawer;
                                 dismissDirection = kHIDE_RIGHT;
                             }
                             
                             [self setCurrentRootViewController:viewController];
                             [self dismissDrawer:currentDrawer Direction:dismissDirection animated:YES duration:0.4 delay:0.1];
                         }
         ];
    //Don't animate
    } else {
        [self setCurrentRootViewController:viewController];
        if (leftDrawerVisible)
            [self dismissDrawer:displayedLeftDrawer Direction:kHIDE_LEFT animated:NO];
        else if (rightDrawerVisible)
            [self dismissDrawer:displayedRightDrawer Direction:kHIDE_RIGHT animated:NO]; 
    }
}

- (void) pushViewController:(UIViewController *) viewController 
{
    //If should animate
    if (rightDrawerVisible || leftDrawerVisible) {
        //Set the drawer that will be used for the animation
        UIViewController<MGADrawerViewControllerProtocol> *drawerVC;
        if (leftDrawerVisible)
            drawerVC = displayedLeftDrawer;
        else
            drawerVC = displayedRightDrawer;
        
        UIGraphicsBeginImageContext(_navigationController.view.bounds.size);
        [_navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        __block UIImageView *rootViewImage = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
        
        int indexOfNavigationView = [[_containerView subviews] indexOfObject:_navigationController.view]; //Save index to insert of views in proper position
        CGRect currentRootFrame = _navigationController.view.frame; //Frame of the root view before animation
        [rootViewImage setFrame:currentRootFrame];
        //Move navigation controller to middle of screen (this moves the root view controller view also)
        [_navigationController.view setFrame:CGRectMake(_navigationController.view.frame.size.width, 
                                                        0, 
                                                        _navigationController.view.frame.size.width, 
                                                        _navigationController.view.frame.size.height)];
        
        [_containerView insertSubview:rootViewImage atIndex:indexOfNavigationView];
        [_navigationController pushViewController:viewController animated:NO];

        [UIView animateWithDuration:0.3 animations:^{
            [_navigationController.view setFrame:CGRectMake(0, 
                                                            0, 
                                                            _navigationController.view.frame.size.width, 
                                                            _navigationController.view.frame.size.height)];
            
            [dropShadowView setFrame:CGRectMake(dropShadowView.frame.origin.x-_navigationController.view.frame.size.width, 
                                                dropShadowView.frame.origin.y, 
                                                dropShadowView.frame.size.width, 
                                                dropShadowView.frame.size.height)];
            
            [drawerVC.view setFrame:CGRectMake(-_navigationController.view.frame.size.width, 
                                               0, 
                                               drawerVC.view.frame.size.width, 
                                               drawerVC.view.frame.size.height)];
            
            [rootViewImage setFrame:CGRectMake(rootViewImage.frame.origin.x-_navigationController.view.frame.size.width, 
                                               rootViewImage.frame.origin.y,  
                                               rootViewImage.frame.size.width,  
                                               rootViewImage.frame.size.height)];
        } completion:^(BOOL finished) {
            //Remove view
            [drawerVC.view removeFromSuperview];
            
            //Remove ViewController
            [drawerVC willMoveToParentViewController:nil];
            [drawerVC removeFromParentViewController];
            
            //Remove DropShadowView
            [dropShadowView removeFromSuperview];
            dropShadowView = nil;
            
            //Remove ImageView
            [rootViewImage removeFromSuperview];
            rootViewImage = nil;
        }];
    //Not animated
    } else {
        [_navigationController pushViewController:viewController animated:YES];
    }
}


#pragma mark - UINavigationController Delegate Methods

- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{    
    //Always hide defaut navigation bar on root
    if (viewController == _currentRootViewController) {
        rootView = _currentRootViewController.view;
        if (leftDrawerVisible && !changingRootView) {
            [self dismissDrawer:displayedLeftDrawer Direction:kHIDE_LEFT animated:NO];
        } else if (rightDrawerVisible && !changingRootView) {
            [self dismissDrawer:displayedRightDrawer Direction:kHIDE_RIGHT animated:NO];
        }
    }
}


#pragma mark - View Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)  willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
    //Check if animating to Portrait or Landscape
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //Move accordingly depending what drawer is visible
        if (leftDrawerVisible) {
            [dropShadowView setFrame:CGRectMake(dropShadowView.frame.origin.x, dropShadowView.frame.origin.y, dropShadowView.frame.size.width, 460)];
            [_rightDrawer.drawerView setFrame:CGRectMake(_rightDrawer.drawerView.frame.origin.x, _rightDrawer.drawerView.frame.origin.y , _rightDrawer.drawerView.frame.size.width, 460)];
        } else if (rightDrawerVisible) {
            [dropShadowView setFrame:CGRectMake(320-_rightDrawer.drawerView.frame.size.width-dropShadowView.frame.size.width+20, dropShadowView.frame.origin.y, dropShadowView.frame.size.width, 460)];
            [_rightDrawer.drawerView setFrame:CGRectMake(320-_rightDrawer.drawerView.frame.size.width, _rightDrawer.drawerView.frame.origin.y , _rightDrawer.drawerView.frame.size.width, 460)];
        }
    } else {
        if (leftDrawerVisible) {
            [dropShadowView setFrame:CGRectMake(dropShadowView.frame.origin.x, dropShadowView.frame.origin.y, dropShadowView.frame.size.width, 300)];
            [_rightDrawer.drawerView setFrame:CGRectMake(_rightDrawer.drawerView.frame.origin.x, _rightDrawer.drawerView.frame.origin.y , _rightDrawer.drawerView.frame.size.width, 300)];
        } else if (rightDrawerVisible) {
            [dropShadowView setFrame:CGRectMake(480-_rightDrawer.drawerView.frame.size.width-dropShadowView.frame.size.width+20, dropShadowView.frame.origin.y, dropShadowView.frame.size.width, 300)];
            [_rightDrawer.drawerView setFrame:CGRectMake(480-_rightDrawer.drawerView.frame.size.width, _rightDrawer.drawerView.frame.origin.y , _rightDrawer.drawerView.frame.size.width, 300)];
        }
    }
}

@end
