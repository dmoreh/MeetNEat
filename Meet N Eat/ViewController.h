//
//  ViewController.h
//  Meet N Eat
//
//  Created by Daniel Moreh on 1/25/13.
//  Copyright (c) 2013 Daniel Moreh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import "HoldViewController.h"
#import "ResultsViewController.h"

@interface ViewController : UIViewController <NSURLConnectionDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
{
    // Connections n stuff
    NSURLConnection *initConnection;
    NSURLConnection *resultsConnection;
    NSURLConnection *joinConnection;
    NSMutableData *receivedData;
    NSTimer *resultsTimer;
    int sessionId;
    BOOL isHost;
    
    // Results caching
    NSDictionary *cachedResults;
    
    // Location
    CLLocationManager *locationManager;
    
    // UI
    UILabel *holdLabel;
}

@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

// Dynamic labels
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UIButton *goButton;



- (IBAction)goButtonPressed:(id)sender;

@end