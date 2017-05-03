//
//  ViewController.m
//  PayUIntegration
//
//  Created by pulkitarora on 4/26/17.
//  Copyright © 2017 pulkitarora. All rights reserved.
//

#import "ViewController.h"
#import "PaymentWebController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)initializePayment:(id)sender{
    PaymentWebController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PaymentWebController"];
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
