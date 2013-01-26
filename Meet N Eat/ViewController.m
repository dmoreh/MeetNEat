//
//  ViewController.m
//  Meet N Eat
//
//  Created by Daniel Moreh on 1/25/13.
//  Copyright (c) 2013 Daniel Moreh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


static NSString *insight_lat = @"42.3587";
static NSString *insight_lon = @"-71.1045";
static NSString *hubspot_lat = @"42.3697";
static NSString *hubspot_lon = @"-71.0779";

#define BASE_URL @"http://173.255.234.17/" //@"http://mne.fickling.us/"
 /* 404 - hold your horses - waiting for a join.
  * 418 - serious issue when you're trying to get' -- random session you never init'd
  * 400 - if there's an issue. don't worry about it.
  */

/* TODO:
 *
 * - Kick out to maps
 * - Make pretty
 * - Use picker for category?
 * - Use contacts
 * - Drop mic & walk out, throw it on the ground?
 *
 */


#pragma mark - Buttons

- (IBAction)goButtonPressed:(id)sender {
    isHost = YES;
    
    // Create Session ID, url
    sessionId = abs(arc4random());
    NSLog(@"Session  ID: %d", sessionId);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/init", BASE_URL, sessionId]];
    
    // Parse location, create JSON data
    NSString *location = locationManager.location.description;
    int commaIndex = [location rangeOfString:@","].location;
    int endIndex = [location rangeOfString:@">"].location - 1;
    NSString *latitude = insight_lat;//[location substringWithRange:NSMakeRange(1, commaIndex - 1)];
    NSString *longitude = insight_lon;//[location substringWithRange:NSMakeRange(commaIndex + 1, endIndex - commaIndex)];
    NSString *foodType = self.categoryTextField.text;
    
    NSArray *keys = [NSArray arrayWithObjects:@"latitude", @"longitude", @"foodtype", nil];
    NSArray *values = [NSArray arrayWithObjects:latitude, longitude, foodType, nil];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSData *jsonData;
    
    if([NSJSONSerialization isValidJSONObject:jsonDictionary])
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
    else
        NSLog(@"Error: jsonDictionary is not valid JSON object. It's actually:\n%@", [jsonDictionary description]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    // Create the connection with the request and start loading the data
    initConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (initConnection) {
        // Create the NSMutableData to hold the received data.
        receivedData = [NSMutableData data];
        NSLog(@"Connected...");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Error, no connection.");
    }
    
    // Create SMS
    NSString *appURL = [NSString stringWithFormat:@"meet://%d", sessionId];
    NSString *smsText = [NSString stringWithFormat:@"Hey, let's get lunch! %@", appURL];
    
    // Send user to SMS
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = smsText;
		controller.recipients = [NSArray arrayWithObject:self.phoneNumberTextField.text];
		controller.messageComposeDelegate = self;
		[self presentViewController:controller animated:YES completion:nil];
	}
}

#pragma mark - HTTP Helpers
- (void)startResultsTimer {
    resultsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(getResults) userInfo:nil repeats:YES];
}

- (void)getResults {
    NSLog(@"Getting results...");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/results", BASE_URL, sessionId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.0];

    // Create the connection with the request and start loading the data
    resultsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (resultsConnection) {
        // Create the NSMutableData to hold the received data.
        receivedData = [NSMutableData data];
        NSLog(@"Connected...");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Error, no connection.");
    }
}

- (void)postJoin:(NSNotification *)notification {
    isHost = NO;
    [self presentHoldViewController];
    
    NSLog(@"Posting join...");
    NSDictionary *userInfo = [notification userInfo];
    sessionId = [[userInfo objectForKey:@"sessionId"] intValue];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/join", BASE_URL, sessionId]];
    
    // Parse location, create JSON data
    NSString *location = locationManager.location.description;
    int commaIndex = [location rangeOfString:@","].location;
    int endIndex = [location rangeOfString:@">"].location - 1;
    NSString *latitude = hubspot_lat;//[location substringWithRange:NSMakeRange(1, commaIndex - 1)];
    NSString *longitude = hubspot_lon;// [location substringWithRange:NSMakeRange(commaIndex + 1, endIndex - commaIndex)];

    NSArray *keys = [NSArray arrayWithObjects:@"latitude", @"longitude", nil];
    NSArray *values = [NSArray arrayWithObjects:latitude, longitude, nil];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSData *jsonData;
    
    if([NSJSONSerialization isValidJSONObject:jsonDictionary])
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
    else
        NSLog(@"Error: jsonDictionary is not valid JSON object. It's actually:\n%@", [jsonDictionary description]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    // Create the connection with the request and start loading the data
    joinConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (joinConnection) {
        // Create the NSMutableData to hold the received data.
        receivedData = [NSMutableData data];
        NSLog(@"Connected...");
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Error, no connection.");
    }
}

#pragma mark - Dynamic Labels
- (void)presentHoldViewController {
    HoldViewController *hvc = [[HoldViewController alloc] initWithNibName:@"HoldViewController" bundle:nil];
    [self presentViewController:hvc animated:NO completion:nil];
}

- (void)presentResultsViewControllerWithResults:(NSDictionary *)results {
    [resultsTimer invalidate];
    ResultsViewController *rvs = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil results:results host:isHost];
    [self dismissViewControllerAnimated:NO completion:^{
        [self presentViewController:rvs animated:NO completion:nil];
    }];
}


#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {    
    switch (result) {
        case MessageComposeResultCancelled:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case MessageComposeResultSent:
        {
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentHoldViewController];
            }];
        }
        default:
            NSLog(@"Error: Message failed to send.");
    };
}

#pragma mark - NSURLConnectionDelegate
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    // Don't cache.
    return nil;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    NSLog(@"Connection will send request");
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    receivedData.length = 0;
    
    if (connection == initConnection) {
        [self presentHoldViewController];
        [self startResultsTimer];        
    } else if (connection == joinConnection) {
        [self startResultsTimer];
    } else if (connection == resultsConnection) {
        // No-op
    }
    NSLog(@"Connection recieved response: %@", [response URL]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == initConnection) {
        // No-op
    } else if (connection == joinConnection) {
        // No-op
    } else if (connection == resultsConnection) {
        [receivedData appendData:data];
        NSError *error = nil;
        NSDictionary *newResults = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&error];

        if (![newResults isEqualToDictionary:cachedResults] && newResults) {
            cachedResults = newResults;
            [self presentResultsViewControllerWithResults:cachedResults];
//            NSLog(@"Results recv'd data:%@", [cachedResults description]);
        }
    }
    
    NSLog(@"Connection received data: %@", [[NSString alloc] initWithData:receivedData encoding:NSStringEncodingConversionExternalRepresentation]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection %@ finished loading", [connection description]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with error: %@", [error description]);
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [((UIImageView *)self.view) setImage:[UIImage imageNamed:@"background.png"]];
    // Get location
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location enabled");
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        NSLog(@"Location: %@", [[locationManager location] description]);
    }
    
    // Listen for opened with url notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postJoin:) name:@"Opened with URL" object:nil];
    
    // Temporary
    [self.categoryTextField setText:@"Mexican"];
    [self.phoneNumberTextField setText:@"19788465131"];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
