TODO
- Test send data to current (or find something more elegant)
- Test ordering of drawers/root view w/ overridden drawers
- Create Drawer that can be subclassed? Or mb just stick with example.
- Unit tests...
- Finish commenting
- Finish doc

-----------------------------------------
markdown file begins here


# MGAMenuController
Created by: Mattieu Gamache-Asselin


## Overview 
The MGAMenuController allows you to easily implement a menu similar to the one seen in Path 2.0 and Facebook (though more strongly based on the sleek animations seen in Path's implementation). It is implemented as a iOS 5 "Container" View Controller, a new type of view controller APIs introduced in iOS 5. 

This control allows you to use sleek side menus to swap the displayed view controller (called "root" view controller), push view controllers on top of the roots as well as perform any action you bake into these side menus.

This Container View Controller consists of three parts; a RightDrawer, a LeftDrawer and a RootViewController. The RootViewController is added to a UINavigationController that handles all pushing and popping as you would expect it. You should not set another UINavigationController as the RootViewController; the MGAMenuController already adds one for you. If your ViewControllers use the "self.navigationController" property for navigation, this will still work perfectly fine. The right and left "Drawers" are the side menus. The Drawers are only accessible from the root. This means you can set any UIViewController as the RootViewController, and the drawers will be accessible. However, as soon as a view controller is pushed on the stack, the drawer menus are not accessible. 

You may set one or both drawers directly on the MGAMenuCotnroller. They will be displayed for all root view controllers. You may also display drawers only for individual UIViewControllers. You can accomplish this (as discussed below) by implementing a simple protocol on your view controller. 

There are currently two types of actions supported from the drawers: Pushing a viewController and changing the "Root" viewController. You may also have a cell run code (for something like a Logout button) by simply adding this code to the actual drawer class.

A great example of all this functionality is demonstrated in the MGAMenuControllerDemo project.


## Installation
Simply copy the classes into your project! Here is the list of files required:
	MGAMenuController.h
	MGAMenuController.m
	MGADropShadowView.h
	MGADropShadowView.m
	*MGADrawerViewController.h
	*MGADrawerViewController.m

*These are not strictly required, but may help you get started.

You can also take a look *MGAMenuControllerDemo* project to get a better feel for how this all works and how it might fit in to your application!


## Getting Started
To quickly get started with the MGAMenuController, I've included the MGADrawerViewController class. This is a ready made example of a drawer that should be pretty straight forward for anyone with a bit of experience in iOS. You can quickly change the content of the table as well as the style. 


## Customizing
To get the most out of this framework, you should create your own UIViewController to act as a drawer. This can be 


### Displaying Drawers

The MGAMenuController has three UIViewController properties; a RootViewController which is added to a navigation stack, and two Drawers (one left, one right). Drawers are simply sublasses of UIViewController that you can implement as you wish. However, they must implement the MGADrawerViewControllerProtocol protocol. This simple protocol simply ensures that you have a property called *drawerView*, which needs to represents the view you want your users to see when the drawer is shown. Your UIViewController' actual view should be a full 320x480 in size, drawerView needs to be added as a subview and preferably smaller in width. This smalled width is the value used to slide the root view side ways when the drawer is shown. The protocol also includes an optional method *setMenuController:*. This method will be called on your drawer by the MGAMenuController if you implement it. It allows to get a pointer to the MenuController if you are not able to set it yourself directly. 

Setting the Left and Right Drawers properties on the MGAMenuController will cause these drawers to be accessible for any root view controller set on the MenuController. You may want to display a certain drawer only for a particular root view controller. This can be accomplished by implementing the MGARootViewControllerProtocol protocol on your UIViewController that you are setting as root. This protocol has two simple methods, *leftDrawerForMenuController:* and *rightDrawerForMenuController:*. Implementing either of these allows you to return a Drawer that will take precedence over the "default" one set in the MGAMenuController properties.

For example, the way the Path app would work would be as follows:
There would be a left drawer set on MGAMenuController. This drawer would be able to cahnge the root view controller to "Home", "Path", "Activity" and "Settings". One cell of the drawer would also simply run a method to perform a log out action. No drawer would be set for the right drawer property on MGAMenuController. Both the "Home" and "Path" view controllers would implement the MGARootViewControllerProtocol and implement the method rightDrawerForMenuController:. This would return a drawer that has a single cell that performs a push action to display the "Add Friends" view controller. Note that the Path app can also display this right hand drawer from any view controller on the navigation stack, no just the root. This is not currently possible, but in the works!


### Adding Actions to a Drawer

These actions are messages sent *from* a drawer *to* the MGAMenuController instance. For this reason, it is important for the drawer to have a reference to the menuController. You can set this directly as a property of the drawer or use the setMenuController: method available as part of the MGADrawerViewControllerProtocol.

The main action is to change the root view controller. This is similar to changing tabs. It will change the view controller at the root of the UINavigationController. This can be done with the *setRootViewController:animated:* method. Calling the non-animated version of this method, or sending "NO" to the animation parameter of this method from a drawer will cause the transition to be very abrupt. To have the desired animation, you should call the animated version this method when calling from within a drawer. Conversely, if you are calling this from outside a drawer, you shouldn't call the animated version, since the animation is specifically to dismiss the drawer elegantly. 

The second action is to Push a UIViewController on the navigation stack form a drawer. Pushing a UIViewController can be done the "standard" way if you are pushing/popping from within your own view controllers (i.e using self.navigationController pushViewController:...). However, to push from a drawer, you need to use the *pushViewController:* method of MGAMenuController. This ensures that the animation is performed correctly. Pushing directly on the navigationController from a drawer will have undesired effects.

You can also run arbirary code to your drawer, like adding a Logout function. You can accomplish this by adding this code in your drawer class and linking it up to a cell in your table or adding a button to your drawer view.

While not an action type, the Drawers can also manually dismiss themselves. The MGAMenuController methods *dismissRightDrawer:*, *dismissLeftDrawer:* and *dismissVisibleDrawer:* can be used. The first two are fairly self-explanitory; they instruct the MenuController to dismiss the left or right drawer (if they are currently shown). Since your drawer may not know if it is the left or right drawer, it is recommended you use the dismissVisibleDrawer: method. This will dismiss the currently show drawer, wether it is the right or the left. 


### UINavigationBar

By default, the MGAMenuController will add UIBarButtonItems on either side of the navigation bar of the root view controller. These are used to show the drawer of that side. If the view controller already includes a UIBarButtonItem on a given side, none will be added (i.e. Your own UIBarButtonItems will not be trampled).

You can also decide to hide the added UIBarButtonItems using the "hideDefaultNavigationBarButtons:" method on MGAMenuController. Make sure you have other controls to show your drawers! You can accomplish this by calling the "showRightDrawer" and "showLeftDrawer" methods.


### Orientation Support

All orientations are supported.


## Licensing 

Copyright 2012 Mattieu Gamache-Asselin. Released under MIT License.

The icon used is not free for commercial use so you will have to switch it out for your own (simply replace the icon files and CLEAN YOUR PROJECT for the change to take effect).
Icon from: http://gentleface.com/free_icon_set.html