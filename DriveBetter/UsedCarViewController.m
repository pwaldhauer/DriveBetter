//
//  UsedCarViewController.m
//  DriveBetter
//
//  Created by Philipp Waldhauer on 20/08/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import "UsedCarViewController.h"
#import "UsedCarTableViewCell.h"
#import "CarDataProvider.h"
#import "Car.h"

@interface UsedCarViewController ()

@property (strong, nonatomic) NSMutableDictionary *data;
@property (nonatomic) NSInteger myCarCount;

@end

@implementation UsedCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeTapped:)];
    self.navigationItem.leftBarButtonItem = closeItem;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    [self refreshData];

}

- (void) refreshData {
    [[CarDataProvider sharedProvider] usedCarsWithBlock:^(NSError *err, NSArray *cars) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        self.myCarCount = cars.count;
        
        for (Car *car in cars) {
            if(!data[car.modelName]) {
                [data setObject:[NSMutableArray array] forKey:car.modelName];
            }
            
            [data[car.modelName] addObject:car];
        }
        
        self.data = data;
        [self.tableView reloadData];
    }];
}

- (void)closeTapped:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTapped:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add used car" message:@"License plate" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex != 1) {
        return;
    }
    
    NSString *licensePlate = [alertView textFieldAtIndex:0].text;
    [[CarDataProvider sharedProvider] addToUsedCarsByLicensePlate:licensePlate];
    
    [self refreshData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.allKeys.count;;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.data.allKeys[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)self.data[self.data.allKeys[section]]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UsedCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UsedCarCell" forIndexPath:indexPath];
    
    Car *car = ((NSArray*)self.data[self.data.allKeys[indexPath.section]])[indexPath.row];
    
    cell.kennzeichenLabel.text = car.licensePlate;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%ix", car.useTimes];
    cell.nameLabel.text = car.name;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section != self.data.allKeys.count - 1) {
        return nil;
    }

    // Totalcar count is wrong, there are more cars. The api only returns parking cars...
    
    return [NSString stringWithFormat:@"You already drove %i individual cars.", (int)self.myCarCount];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Car *car = ((NSArray*)self.data[self.data.allKeys[indexPath.section]])[indexPath.row];
        [[CarDataProvider sharedProvider] removeFromUsedCars:car];
        [self refreshData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Car *car = ((NSArray*)self.data[self.data.allKeys[indexPath.section]])[indexPath.row];
    
    NSLog(@"Delegate: %@", self.delegate);
    
    if(!self.delegate || ![self.delegate respondsToSelector:@selector(carTapped:)]) {
        return;
    }
    
    [self.delegate carTapped:car];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
