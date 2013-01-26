//
//  ResultsViewController.m
//  Meet N Eat
//
//  Created by Daniel Moreh on 1/26/13.
//  Copyright (c) 2013 Daniel Moreh. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

/* TODO:
 *
 * - GET with timer to check other's status
 *
 */

//#define insight_lat 42.3587
//#define insight_lon -71.1045
//
//#define hubspot_lat 42.3697
//#define hubspot_lon -71.0779


static NSString *insight_lat = @"42.3587";
static NSString *insight_lon = @"-71.1045";
static NSString *hubspot_lat = @"42.3697";
static NSString *hubspot_lon = @"-71.0779";


@implementation ResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil results:(NSDictionary *)results host:(BOOL)isHost
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.results = results;
        self.isHost = isHost;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        NSLog(@"Location: %@", [[locationManager location] description]);
    }
    [((UIImageView *)self.view) setImage:[UIImage imageNamed:@"background"]];

    // Set up buttons
    self.yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize size = CGSizeMake(168, 47);
    CGRect frame = {CGPointZero, size};
    self.yesButton.frame = frame;
    self.yesButton.center = CGPointMake(160, .65 * 568);
    [self.yesButton setImage:[UIImage imageNamed:@"niceimin"] forState:UIControlStateNormal];
    [self.yesButton addTarget:self action:@selector(yesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.yesButton];
    
    self.noButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.noButton.frame = frame;
    self.noButton.center = CGPointMake(160, self.yesButton.center.y + self.yesButton.frame.size.height + 8);
    [self.noButton setImage:[UIImage imageNamed:@"noway"] forState:UIControlStateNormal];
    [self.noButton addTarget:self action:@selector(noButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.noButton];
    
    // Parse results
    NSDictionary *info = [self.results objectForKey:@"0"];
    
    [self.introLabel setText:@"i'm cravin"];
    [self.destinationLabel setText:[info objectForKey:@"name"]];
    [self.distanceLabel setText:[NSString stringWithFormat:@"it's %@ miles away", [self milesFromFeet:[info objectForKey:(self.isHost ? @"a_distance" : @"b_distance")]]]];
    [self.timeLabel setText:[NSString stringWithFormat:@"(that's a %@ minute walk)", [self minutesFromSeconds:[info objectForKey:(self.isHost ? @"a_time" : @"b_time")]]]];
    
    latB = [info objectForKey:@"latitude"];
    lonB = [info objectForKey:@"longitude"];
    
    // Parse location, create JSON data
//    NSString *location = locationManager.location.description;
//    int commaIndex = [location rangeOfString:@","].location;
//    int endIndex = [location rangeOfString:@">"].location - 1;
//    latA = [location substringWithRange:NSMakeRange(1, commaIndex - 1)];
//    lonA = [location substringWithRange:NSMakeRange(commaIndex + 1, endIndex - commaIndex)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Conversion Helpers

- (NSString *)minutesFromSeconds:(NSString *)seconds {
    int s = [seconds intValue];
    int m = round(s / 60);
    return [NSString stringWithFormat:@"%d", m];
}

- (NSString *)milesFromFeet:(NSString *)feet {
    float f = [feet floatValue];
    float m = roundf(f / 528.0) / 10.0 * 3.281;
    return [NSString stringWithFormat:@"%.1f", m];
}

#pragma mark - Buttons

- (void)yesButtonPressed {
    // POST accept
    
    // Open maps (if other user accepted too?)
    
    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake([latB floatValue], [lonB floatValue]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.destinationLabel.text];
        
        // Set the directions mode to "Walking"
        // Can use MKLaunchOptionsDirectionsModeDriving instead
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        // Get the "Current User Location" MKMapItem
//        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
         
        /////
        coordinate =
        CLLocationCoordinate2DMake([(self.isHost ? insight_lat : hubspot_lat) floatValue], [(self.isHost ? insight_lon : hubspot_lon) floatValue]);
        placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem2 = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem2 setName:(self.isHost ? @"Insight Squared" : @"Hubspot" )];
        /////
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[mapItem2, mapItem]//currentLocationMapItem, currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
    
//
}

- (void)noButtonPressed{
    // POST decline
    
    // Reload with next result
}
@end
