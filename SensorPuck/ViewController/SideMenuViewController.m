//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "MainViewController.h"
#import "Puck.h"

@interface SideMenuViewController() {
    NSMutableArray *arrayPucks;
}

@end

@implementation SideMenuViewController

@synthesize bleManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    arrayPucks = [[NSMutableArray alloc] init];
    
    bleManager = [BleManager sharedInstance];
    bleManager.delegateSideMenu = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    bleManager.delegateSideMenu = nil;
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (CGFloat) 0.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayPucks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Puck *puck = (Puck*)[arrayPucks objectAtIndex:indexPath.row];
    if (puck != nil)
        cell.textLabel.text = [NSString stringWithFormat:@"%@", puck._name];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (arrayPucks.count < indexPath.row)
        return;
    
    Puck *selPuck = [arrayPucks objectAtIndex:indexPath.row];
    [[BleManager sharedInstance] setCurPuck:selPuck];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
    
}

- (void)getPucks:(NSMutableArray *)pucks {
    arrayPucks = pucks;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
