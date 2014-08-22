//
//  UsedCarViewController.h
//  DriveBetter
//
//  Created by Philipp Waldhauer on 20/08/14.
//  Copyright (c) 2014 Philipp Waldhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Car.h"

@protocol UsedCarViewControllerDelegate <NSObject>

@required
- (void)carTapped:(Car*)car;
@end

@interface UsedCarViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) id<UsedCarViewControllerDelegate> delegate;

@end
