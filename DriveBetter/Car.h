//
//  Car.h
//  DriveBetter
//
//  Created by Philipp Waldhauer on 21/07/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Car : NSObject

@property (strong) NSString *name;
@property (strong) NSString *modelName;
@property (strong, nonatomic) NSString *licensePlate;
@property (nonatomic) float fuelLevel;
@property (nonatomic) NSString *transmission;
@property (strong, nonatomic) NSURL *imageURL;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

+ (Car*)carFromJSON:(NSDictionary *)json;


@end
