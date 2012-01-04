//
//  MainViewController.h
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import <UIKit/UIKit.h>
#import "MGAMenuController.h"

@interface MainViewController : UIViewController <MGARootViewControllerProtocol, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;

@end
