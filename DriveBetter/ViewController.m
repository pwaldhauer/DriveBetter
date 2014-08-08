//
//  ViewController.m
//  DriveBetter
//
//  Created by Philipp Waldhauer on 21/07/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "Car.h"
#import "CarAnnotation.h"
#import "AsyncImageView.h"

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *cars;
@property (strong, nonatomic) NSMutableArray *annotations;
@property (strong, nonatomic) MKDirectionsRequest *directionsRequest;
@property (strong, nonatomic) MKDirections *directions;
@property (nonatomic) BOOL requestedLocation;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cars = [NSMutableArray new];
    self.annotations = [NSMutableArray new];
    self.requestedLocation = YES;
    
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCars) name:UIApplicationDidBecomeActiveNotification object:nil];
     
    [self loadCars];
}

#pragma mark - Button actions

- (void)locationButtonTapped:(id)sender {
    self.requestedLocation = YES;
    
    [self loadCars];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if(![annotation isKindOfClass:[CarAnnotation class]]) {
        return nil;
    }
    
    CarAnnotation *carAnnotation = (CarAnnotation*)annotation;
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"CarAnnotation"];
    if(!view) {
        view = [carAnnotation annotationView];
    }
    
    view.annotation = annotation;
    return view;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSTimeInterval locationAge = -1 * [userLocation.location.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    if(userLocation.location.horizontalAccuracy < 0 || userLocation.location.verticalAccuracy < 0) {
        return;
    }
    
    if(!self.requestedLocation) {
        return;
    }
    
    self.requestedLocation = NO;
    
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.008, 0.008));
    
    [self.mapView setRegion:userRegion];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if(![view.annotation isKindOfClass:[CarAnnotation class]]) {
        return;
    }
    
    view.image = [UIImage imageNamed:@"carhl"];
    
    CarAnnotation *annotation = (CarAnnotation*)view.annotation;
    
    [self updateDetailViewWithCar:annotation.car];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if(![view.annotation isKindOfClass:[CarAnnotation class]]) {
        return;
    }
    
    self.detailView.hidden = YES;
    view.image = [UIImage imageNamed:@"car"];
    
}

#pragma mark - Load cars

- (void) loadCarsWithBlock:(void (^)(NSError *err, NSDictionary *cars))block {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
            @"Origin": @"https://de.drive-now.com",
            @"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36",
            @"X-Api-Key": @"API-KEY",
            @"Referer": @"https://de.drive-now.com/"
    };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://api.drive-now.com/cars?cityId=40065&expand=full"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error, json);
        });
    }];
    
    [dataTask resume];
}

- (void) loadCars {
    self.locationButton.hidden = YES;
    [self.reloadIndicator startAnimating];
    
    [self loadCarsWithBlock:^(NSError *err, NSDictionary *cars) {
        [self.reloadIndicator stopAnimating];
        self.locationButton.hidden = NO;
        
        [self.cars removeAllObjects];
        
        for(NSDictionary *car in cars[@"items"]) {
            if([car[@"transmission"] isEqualToString:@"A"]) {
                [self.cars addObject:[Car carFromJSON:car]];
            }
        }
        
        [self updateMapMarkers];
        
        // Zoom to include the nearest car
        Car *nearestCar = [self getNearestCarForCurrentLocation];
        CarAnnotation *annotation = [self annotationForCar:nearestCar];
        
        if(annotation ) {
            [self.mapView showAnnotations:@[self.mapView.userLocation, annotation] animated:YES];
            [self.mapView selectAnnotation:annotation animated:YES];
        }
    }];
}

#pragma mark - Update Views

- (void) updateDetailViewWithCar:(Car*)car {
    self.detailView.hidden = NO;
    
    self.walkingDistanceLabel.hidden = YES;
    self.routeLoadingIndicator.hidden = NO;
    [self.routeLoadingIndicator startAnimating];
    
    self.kennzeichenLabel.text = car.licensePlate;
    self.infoLabel.text = [NSString stringWithFormat:@"%@ - “%@” - %i%%", car.modelName, car.name,(int)(car.fuelLevel*100)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.imageURL = car.imageURL;
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(car.latitude, car.longitude) addressDictionary:nil];
    
    [self.directions cancel];
    self.directions = nil;
    self.directionsRequest = nil;
    
    self.directionsRequest = [[MKDirectionsRequest alloc] init];
    self.directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
    self.directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    self.directionsRequest.transportType = MKDirectionsTransportTypeWalking;

    self.directions = [[MKDirections alloc] initWithRequest:self.directionsRequest];
    
    [self.directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        [self.routeLoadingIndicator stopAnimating];
        self.routeLoadingIndicator.hidden = YES;
        self.walkingDistanceLabel.hidden = NO;
        
        if(error) {
            self.walkingDistanceLabel.text = @"?";
        }
        
        self.walkingDistanceLabel.text = [NSString stringWithFormat:@"%imin", (int)(response.expectedTravelTime/60)];
    }];
}

- (void) updateMapMarkers {
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    
    for(Car* car in self.cars) {
        [self.annotations addObject:[[CarAnnotation alloc] initWithCar:car]];
    }
    
    [self.mapView addAnnotations:self.annotations];
}

#pragma mark - Calculate stuff

- (Car*) getNearestCarForCurrentLocation {
    CLLocation *userLocation = self.mapView.userLocation.location;
    
    
    Car *shortestCar = nil;
    CLLocationDistance shortestDistance = CLLocationDistanceMax;
    
    for(Car* car in self.cars) {
        CLLocation *carLocation = [[CLLocation alloc] initWithLatitude:car.latitude longitude:car.longitude];
        CLLocationDistance distance = [carLocation distanceFromLocation:userLocation];
        
        if(distance < shortestDistance) {
            shortestDistance = distance;
            shortestCar = car;
        }
    }
    
    return shortestCar;
}

- (CarAnnotation*) annotationForCar:(Car*)car {
    for(CarAnnotation *annotation in self.annotations) {
        if(annotation.car == car) {
            return annotation;
        }
    }
    
    return nil;
}


@end
