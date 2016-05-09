//
//  ViewController.m
//  WhereTo
//
//  Created by Oliver Short on 4/27/16.
//  Copyright © 2016 Oliver Short. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Landmark.h"

@interface ViewController () <CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate>

@property(strong, nonatomic) MKMapView *mapView;
@property(strong, nonatomic)CLLocationManager *manager;
@property(strong,nonatomic)UIViewController*insideViewController;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Mutt Cutts hits the Road!";
    
    CGRect theFrame = self.view.frame; //CGRect is a struct - a vanilla container object that has an origin and a size. read-only, can't be changed
    
    theFrame.origin.x = 20; //setting to margin on the left hand side
    theFrame.origin.y = 94; //setting the vertical margin to account for the navigation controller we made in the .h file
    theFrame.size.width -= 40;
    theFrame.size.height -= 114;

     self.manager = [[CLLocationManager alloc]init];
    [self.manager requestAlwaysAuthorization];

    self.mapView = [[MKMapView alloc]initWithFrame:theFrame];
    self.mapView.showsUserLocation = YES;
    
    [self.view addSubview:self.mapView]; //putting the map view on the view controller
    
    Landmark * capitolBuilding = [[Landmark alloc]initWithCoord:CLLocationCoordinate2DMake(35.7804, -78.6391) title:@"Capitol Building" subtitle:@"The place where the capitol is"];
    
    [self.mapView addAnnotation:capitolBuilding];
    
    
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
    
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.leftBarButtonItem = locationButton;
    
    CLLocation *currentLocation = self.mapView.userLocation.location;
    
    CLLocation * capitolLocation = [[CLLocation alloc]initWithLatitude:capitolBuilding.coordinate.latitude longitude:capitolBuilding.coordinate.longitude];
    
    
    if (currentLocation && capitolLocation) {
    
            [self zoomMapToRegionEncapsulatingLocation:capitolLocation andLocation:currentLocation];
    
    }

    
}

-(UIViewController*)controllerForInsidePopover {
    UIViewController *createMeNow = [[UIViewController alloc]init];
    
    createMeNow.view.backgroundColor = UIColor.whiteColor;
    
    UITextField *firstText = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 300, 30)];
    firstText.borderStyle = UITextBorderStyleLine;
    firstText.tag = 5;
    [createMeNow.view addSubview:firstText];
    
    UITextField *secondText = [[UITextField alloc]initWithFrame:CGRectMake(10, 50, 300, 30)];
    secondText.borderStyle = UITextBorderStyleLine;
    secondText.tag = 6;
    [createMeNow.view addSubview:secondText];
    
    UIButton *closeMeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 90, 200, 35)];
    
    [closeMeButton setTitle:@"CloseMe" forState:UIControlStateNormal];
    [closeMeButton setTitleColor: UIColor.blueColor forState:UIControlStateNormal];
    
    
    [closeMeButton addTarget:self action:@selector(closePopoverView) forControlEvents:UIControlEventTouchUpInside];
    
    [createMeNow.view addSubview:closeMeButton];
    
    return createMeNow;
}

-(void)closePopoverView{
    
    UITextField* firstText = [self.insideViewController.view viewWithTag:5];
    UITextField* secondText = [self.insideViewController.view viewWithTag:6];
    
    [self lookupCities:@[firstText.text, secondText.text]];
    
    [self.insideViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)addButtonPressed:(UIBarButtonItem*)sender{
    
    self.insideViewController = [self controllerForInsidePopover];
    self.insideViewController.modalPresentationStyle= UIModalPresentationPopover;
    
    UIPopoverPresentationController*popPresController = [self.insideViewController popoverPresentationController];
    
    popPresController.delegate = self;
    popPresController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPresController.barButtonItem = sender;
 
    [self presentViewController:self.insideViewController animated:YES completion:nil];
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

-(UIViewController*)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style{
    return self.insideViewController;
}

-(BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController* )popoverPresentationController{
    return YES;
}

-(void)centerMapOnLocation:(CLLocationCoordinate2D)location{
    CLLocationDistance regionRadius =1000;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, regionRadius*2.0, regionRadius*2.0);
    [self.mapView setRegion:region animated:YES];
    
}

-(void)zoomMapToRegionEncapsulatingLocation:(CLLocation*)firstLoc andLocation:(CLLocation*)secondLoc{
    
    float lat =(firstLoc.coordinate.latitude + secondLoc.coordinate.latitude) /2;
    
    float longitude = (firstLoc.coordinate.longitude + secondLoc.coordinate.longitude) /2;
    
    
    CLLocationDistance distance = [firstLoc distanceFromLocation:secondLoc];
    
    CLLocation *centerLocation = [[CLLocation alloc]initWithLatitude:lat longitude:longitude];
    
    //    MKCoordinateSpan span = MKCoordinateSpanMake(2000, 2000);
    
    if (CLLocationCoordinate2DIsValid(centerLocation.coordinate)){
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerLocation.coordinate, distance,distance);
        
        [self.mapView setRegion:region animated:YES];
        
    }
}

-(void)lookupCities:(NSArray*)cityArray{
    //An NSAssert is basically a quick way of saying "hey, are these things nil"
    NSAssert2(@"both strings", @"are present", cityArray[0], cityArray[1]);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
   __block CLLocationCoordinate2D firstPlace;
   __block CLLocationCoordinate2D secondPlace;
    
    __block ViewController *weakSelf = self;
    
    [geocoder geocodeAddressString:cityArray[0]
                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks,
                                     NSError * _Nullable error) {
                     CLPlacemark *placemark = [placemarks lastObject];
                     firstPlace = placemark.location.coordinate;
                     Landmark *theFirst = [[Landmark alloc]initWithCoord:firstPlace title:cityArray[0] subtitle:@"The first location"];
                     [weakSelf.mapView addAnnotation: theFirst];
                     [geocoder cancelGeocode];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    [geocoder geocodeAddressString:cityArray[1]
                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks,
                                     NSError * _Nullable error) {
                     CLPlacemark *placemark = [placemarks lastObject];
                     secondPlace = placemark.location.coordinate;
                     Landmark *theSecond= [[Landmark alloc]initWithCoord:secondPlace title:cityArray[1] subtitle:@"The second location"];
                     [weakSelf.mapView addAnnotation:theSecond];
                     
                     [geocoder cancelGeocode];
                 }];
    });
    
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation* firstLocation = [locations firstObject];
    CLLocation* lastLocation = [locations lastObject];
    
    if([firstLocation isEqual:lastLocation]) {
        NSLog(@"same place!");
    }else{
        NSLog(@"who knows!");
    }
 Landmark * capitolBuilding = [[Landmark alloc]initWithCoord:CLLocationCoordinate2DMake(35.7804, -78.6391) title:@"Capitol Building" subtitle:@"The place where the capitol is"];
    
CLLocation * capitolLocation = [[CLLocation alloc]initWithLatitude:capitolBuilding.coordinate.latitude longitude:capitolBuilding.coordinate.longitude];
    
CLLocation *currentLocation = firstLocation;
    if (currentLocation && capitolLocation) {
        [self zoomMapToRegionEncapsulatingLocation:capitolLocation andLocation:currentLocation];
    }
    
    [manager stopUpdatingLocation];
}



@end
