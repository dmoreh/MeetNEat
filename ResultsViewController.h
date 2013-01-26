//
//  ResultsViewController.h
//  Meet N Eat
//
//  Created by Daniel Moreh on 1/26/13.
//  Copyright (c) 2013 Daniel Moreh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ResultsViewController : UIViewController {
    NSString *latA, *latB, *lonA, *lonB;
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) NSDictionary *results;
@property UIButton *yesButton;
@property UIButton *noButton;
@property BOOL isHost;

- (void)yesButtonPressed;
- (void)noButtonPressed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil results:(NSDictionary *)results host:(BOOL)isHost;

@end
