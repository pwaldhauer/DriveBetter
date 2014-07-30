//
//  ViewController.h
//  DriveBetter
//
//  Created by Philipp Waldhauer on 21/07/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *kennzeichenLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *walkingDistanceLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *routeLoadingIndicator;
@property (strong, nonatomic) IBOutlet UIButton *locationButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *reloadIndicator;

- (IBAction) locationButtonTapped:(id)sender;

@end

