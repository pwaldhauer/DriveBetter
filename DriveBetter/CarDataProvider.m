//
//  CarDataProvider.m
//  DriveBetter
//
//  Created by Philipp Waldhauer on 20/08/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import "CarDataProvider.h"
#import "Car.h"

@interface CarDataProvider()

@property (strong, nonatomic) NSArray *allCars;
@property (strong, nonatomic) NSMutableDictionary *licensePlateToCarDict;
@property (strong, nonatomic) NSArray *usedCars;

@end

@implementation CarDataProvider

+ (instancetype)sharedProvider {
    static CarDataProvider *instance = nil;
    if(!instance) {
        instance = [[CarDataProvider alloc] init];
        instance.allCars = @[];
        [instance loadUsedCars];
    }
    
    return instance;
}

- (void)liveDataWithBlock:(void (^)(NSError *, NSArray *))block {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Origin": @"https://de.drive-now.com",
                                                   @"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36",
                                                   @"X-Api-Key": @"",
                                                   @"Referer": @"https://de.drive-now.com/"
                                                   };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://api.drive-now.com/cars?cityId=40065&expand=full"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        NSMutableArray *cars = [NSMutableArray array];
        for(NSDictionary *car in json[@"items"]) {
            if([car[@"transmission"] isEqualToString:@"A"]) {
                Car *carModel = [Car carFromJSON:car];
                
                // If car is in used car, we use this.
                if([self.licensePlateToCarDict.allKeys containsObject:carModel.licensePlate]) {
                    Car *usedCar = self.licensePlateToCarDict[carModel.licensePlate];
     
                    usedCar.longitude = carModel.longitude;
                    usedCar.latitude = carModel.latitude;
                    usedCar.modelName = carModel.modelName;
                    usedCar.fuelLevel = carModel.fuelLevel;
                    usedCar.name = carModel.name;
                    usedCar.transmission = carModel.transmission;
                    usedCar.imageURL = carModel.imageURL;
                    
                    [cars addObject:usedCar];
                    continue;
                }
                
                
                [cars addObject: carModel];
            }
        }
        
        self.allCars = [NSArray arrayWithArray:cars];
        
        // Save used cars to persist changes.
        [self saveUsedCars];

        dispatch_async(dispatch_get_main_queue(), ^{
                       block(error, [NSArray arrayWithArray:self.allCars]);
        });
    }];
    
    [dataTask resume];
    
}

- (void)usedCarsWithBlock:(void (^)(NSError *, NSArray *))block {
    [self loadUsedCars];
    
    NSMutableArray *cars = [NSMutableArray array];
    for (Car *car in self.usedCars) {
        [cars addObject:car];
    }
    
    block(nil, cars);
}

- (void)addToUsedCars:(Car*)car {
    // Search for already used cars
    for(Car *usedCar in self.usedCars) {
        if([usedCar.licensePlate isEqualToString:car.licensePlate]) {
            usedCar.useTimes++;
            
            [self saveUsedCars];
            return;
        }
    }
    
    // If not found add it
    car.useTimes++;
    
    NSMutableArray *usedCars = self.usedCars.mutableCopy;
    [usedCars addObject:car];
    
    self.usedCars = usedCars;
    [self saveUsedCars];
}

- (void)addToUsedCarsByLicensePlate:(NSString *)licensePlate {
    if(licensePlate == nil) {
        return;
    }
    
    for (Car *car in self.allCars) {
        if([car.licensePlate isEqualToString:licensePlate]) {
            [self addToUsedCars:car];
            return;
        }
    }
    
    Car *car = [[Car alloc] init];
    car.licensePlate = licensePlate;
    car.modelName = @"Unknown";
    
    [self addToUsedCars:car];
}

- (void)removeFromUsedCars:(Car *)car {
    car.useTimes = 0;
    
    NSMutableArray *usedCars = self.usedCars.mutableCopy;
    [usedCars removeObject:car];
    
    self.usedCars = usedCars;
    [self saveUsedCars];
}

- (void) loadUsedCars {
    if(self.usedCars) {
        return;
    }
    
    self.usedCars = [NSKeyedUnarchiver unarchiveObjectWithFile:[self usedCarsPath]];
    if(!self.usedCars) {
        self.usedCars = [NSArray array];
    }
    
    self.licensePlateToCarDict = [NSMutableDictionary dictionary];
    for (Car* car in self.usedCars) {
        [self.licensePlateToCarDict setObject:car forKey:car.licensePlate];
    }
}

- (void) saveUsedCars {
    [NSKeyedArchiver archiveRootObject:self.usedCars toFile:[self usedCarsPath]];
}

- (NSString *)usedCarsPath {
    NSString *documents = ((NSURL*)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]).path;
    return [documents stringByAppendingPathComponent:@"usedCars1.dat"];
}


@end
