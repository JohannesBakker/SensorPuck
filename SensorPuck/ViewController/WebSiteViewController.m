//
//  WebSiteViewController.m
//  SensorPuck
//
//  Created by Admin on 4/26/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "WebSiteViewController.h"
#import "MFSideMenu.h"

@interface WebSiteViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webAddress;
@end

@implementation WebSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    
    switch (self.kind) {
        case 0:
            [self.webAddress loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.silabs.com/products/sensors/Pages/environmental-biometric-sensor-puck.aspx"]]];
            break;
        case 1:
            [self.webAddress loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.silabs.com/products/sensors/humidity-sensors/Pages/si7013-20-21.aspx"]]];
            break;
        case 2:
            [self.webAddress loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.silabs.com/products/sensors/infraredsensors/Pages/Si114x.aspx"]]];
            break;
        case 3:
            [self.webAddress loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.silabs.com/products/analog/dc-dc-converter/Pages/default.aspx"]]];
            break;
        case 4:
            [self.webAddress loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.silabs.com/products/mcu/32-bit/efm32-gecko/pages/efm32-gecko.aspx"]]];
            break;
            
        default:
            break;
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
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

@end
