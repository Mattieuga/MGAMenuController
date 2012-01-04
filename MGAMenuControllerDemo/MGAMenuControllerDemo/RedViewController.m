//
//  RedViewController.m
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import "RedViewController.h"

@implementation RedViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:[UIColor redColor]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
