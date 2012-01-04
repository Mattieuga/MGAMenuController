//
//  AppDelegate.m
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import "AppDelegate.h"
#import "MainViewController.h"
#import "RedViewController.h"
#import "BlueViewController.h"
#import "MGAMenuController.h"
#import "MGADrawerViewController.h"

@implementation AppDelegate

@synthesize window = _window;- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MainViewController *mainVC = [[MainViewController alloc]init];
    
    MGADrawerViewController *leftDrawer = [[MGADrawerViewController alloc] init];
    MGADrawerViewController *rightDrawer = [[MGADrawerViewController alloc] init];
   
    MGAMenuController *menuController = [[MGAMenuController alloc] init];
    [menuController setRootViewController:mainVC];
    [menuController setLeftDrawer:leftDrawer];
    
    //Uncommenting this will add a default RightDrawer
    //[menuController setRightDrawer:rightDrawer];


    //Uncommenting this will cause cause the default navigation buttons to be hidden
    //[menuController hideDefaultNavigationBarButtons:YES];
    
    self.window.rootViewController = menuController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
