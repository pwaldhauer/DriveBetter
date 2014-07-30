//
//  CarAnnotation.h
//  DriveBetter
//
//  Created by Philipp Waldhauer on 21/07/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Car.h"

@interface CarAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) Car *car;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) BOOL highlighted;

- (MKAnnotationView*)annotationView;

- (instancetype)initWithCar:(Car*)car;


@end
