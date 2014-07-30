//
//  CarAnnotation.m
//  DriveBetter
//
//  Created by Philipp Waldhauer on 21/07/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import "CarAnnotation.h"

@implementation CarAnnotation

- (instancetype)initWithCar:(Car *)car {
    self = [super init];
    if(self) {
        self.car = car;
    }
    
    return self;
}

- (MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CarAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = NO;
    annotationView.image = [UIImage imageNamed:@"car"];
    
    return annotationView;
}

-(void)setCar:(Car *)car {
    _car = car;
    
    self.coordinate = CLLocationCoordinate2DMake(car.latitude, car.longitude);
}

@end
