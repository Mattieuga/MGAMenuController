//
//  MGDrawerViewController.h
//
//  Copyright (c) 2011 Mattieu Gamache-Asselin. All rights reserved.

#import <UIKit/UIKit.h>
#import "MGAMenuController.h"

typedef enum {
    kPUSH,
    kSET_ROOT,
    kACTION_BLOCK,
    kACTION_SEL
} DrawerRowType;


@interface DrawerExample2: UIViewController <MGADrawerViewControllerProtocol, UITableViewDataSource, UITableViewDelegate> {
    int drawerWidth;
    int sectionIndex;
}

@property (nonatomic, strong) MGAMenuController *theMenuController;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tableData;



- (void) addPushRowWithViewController:(UIViewController *)viewController andLabel:(NSString *)label;
- (void) addRootRowWithViewController:(UIViewController *)viewController andLabel:(NSString *)label;
- (void) addActionRowWithBlock:(void (^)(void)) action  andLabel:(NSString *)label;
- (void) addActionRowWithSelector:(SEL)selector target:(id)target andLabel:(NSString *)label;
- (void) addTableSectionWithLabel:(NSString *) label andHeaderView:(UIView *)headerView;
- (void) addTableSectionWithLabel:(NSString *) label;
- (void) setHeaderView:(UIView *)headerView forSectionWithIndex:(int) index;


- (void) actionExample;
@end
