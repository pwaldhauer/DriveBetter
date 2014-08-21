//
//  CarDataProvider.h
//  DriveBetter
//
//  Created by Philipp Waldhauer on 20/08/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Car.h"

@interface CarDataProvider : NSObject

+ (instancetype) sharedProvider;

- (void) liveDataWithBlock:(void (^)(NSError *err, NSArray *cars))block;
- (void) usedCarsWithBlock:(void (^)(NSError *err, NSArray *cars))block;
- (void) removeFromUsedCars:(Car*)car;
- (void) addToUsedCars:(Car*)car;
- (void) addToUsedCarsByLicensePlate:(NSString*)licensePlate;

@end
