//
//  MainViewController.m
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import "MainViewController.h"
#import "RedViewController.h"
#import "DrawerExample2.h"

@implementation MainViewController

@synthesize table;


#pragma mark - View lifecycle

- (void)loadView
{
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
    [table setDelegate:self];
    [table setDataSource:self];
    [self setView:table];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //UNCOMMENT TO OVERRIDE DEFAULT MENU CONTROLLER NAVIGATION BUTTON
    //[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil]];
    //[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil]];

}

- (void) viewWillAppear:(BOOL)animated {
    [[self table] deselectRowAtIndexPath:[table indexPathForSelectedRow] animated:YES];
}

// OVERRIDES THE DEFAULT DRAWER SET IN THE MENU CONTROLLER PROPERTIES
- (UIViewController<MGADrawerViewControllerProtocol> *)rightDrawerForMenuController:(MGAMenuController *)menuController {
    return [[DrawerExample2 alloc] init];
}

// OVERRIDES THE DEFAULT DRAWER SET IN THE MENU CONTROLLER PROPERTIES
//- (UIViewController<MGADrawerViewControllerProtocol> *)leftDrawerForMenuController:(MGAMenuController *)menuController {
//    return [[DrawerExample2 alloc] init];
//}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RedViewController *redVC = [[RedViewController alloc] init];
    [self.navigationController pushViewController:redVC animated:YES];
}


#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    // Acquire the cell. 
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    cell.textLabel.text = @"This is a cell!";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
