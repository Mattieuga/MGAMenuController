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


@interface MGADrawerViewController: UIViewController <MGADrawerViewControllerProtocol, UITableViewDataSource, UITableViewDelegate> {
    int drawerWidth;
    int sectionIndex;
}

@property (nonatomic, strong) MGAMenuController *theMenuController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableData;

- (void) actionExample;

@end
