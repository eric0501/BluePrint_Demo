//
//  ViewController.m
//  BluePrint_Demo
//
//  Created by Eric周 on 15/10/17.
//  Copyright © 2015年 Eric周. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WelCome";

}

- (IBAction)ButtonClick:(id)sender {
    BluetoothDeviceView *deviceView = [[BluetoothDeviceView alloc]init];
    //[self presentViewController:deviceView animated:YES completion:nil];
    [self.navigationController pushViewController:deviceView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
