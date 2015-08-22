//
//  InformationViewController.m
//  SensorPuck
//
//  Created by Admin on 4/26/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "InformationViewController.h"
#import "WebSiteViewController.h"
#import "MFSideMenu.h"

@interface InformationViewController () {
    int _kind;
}

@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _kind = 0;
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [button setTitle:@"Silicon Labs Sensor Puck" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onLeftSideMenuClicked:)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 7, 180, 20)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return barButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onLeftSideMenuClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onWebSiteClicked:(id)sender {
    _kind = 0;
    [self performSegueWithIdentifier:@"gotoWebSite" sender:self];
}

- (IBAction)onTemperatureClicked:(id)sender {
    _kind = 1;
    [self performSegueWithIdentifier:@"gotoWebSite" sender:self];
}

- (IBAction)onOpticalClicked:(id)sender {
    _kind = 2;
    [self performSegueWithIdentifier:@"gotoWebSite" sender:self];
}

- (IBAction)onBoostClicked:(id)sender {
    _kind = 3;
    [self performSegueWithIdentifier:@"gotoWebSite" sender:self];
}

- (IBAction)onMCUClicked:(id)sender {
    _kind = 4;
    [self performSegueWithIdentifier:@"gotoWebSite" sender:self];
}
- (IBAction)onSensorPuckClicked:(id)sender {
    _kind = 0;
    [self performSegueWithIdentifier:@"gotoWebSite" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"gotoWebSite"])
    {
        // Get reference to the destination view controller
        WebSiteViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.kind = _kind;
    }
}

@end
