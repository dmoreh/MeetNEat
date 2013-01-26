//
//  HoldViewController.m
//  Meet N Eat
//
//  Created by Daniel Moreh on 1/26/13.
//  Copyright (c) 2013 Daniel Moreh. All rights reserved.
//

#import "HoldViewController.h"

@interface HoldViewController ()

@end

@implementation HoldViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set label
    [((UIImageView *)self.view) setImage:[UIImage imageNamed:@"background"]];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hold"]];
    [iv setFrame:CGRectMake(0, 0, 320, 548)];
    [self.view addSubview:iv];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
