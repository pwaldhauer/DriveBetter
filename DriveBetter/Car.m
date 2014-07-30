//
//  Car.m
//  DriveBetter
//
//  Created by Philipp Waldhauer on 21/07/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import "Car.h"

@implementation Car

+(Car *)carFromJSON:(NSDictionary *)json {
    Car *car = [[Car alloc] init];
    car.name = json[@"name"];
    car.modelName = json[@"modelName"];
    car.licensePlate = json[@"licensePlate"];
    car.fuelLevel = [json[@"fuelLevel"] floatValue];
    car.transmission = json[@"transmission"];
    car.latitude = [json[@"latitude"] floatValue];
    car.longitude = [json[@"longitude"] floatValue];
    car.imageURL = [NSURL URLWithString:json[@"carImageUrl"]];
    
    return car;
}



@end
