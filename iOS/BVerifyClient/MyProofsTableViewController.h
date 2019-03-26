//
//  MyProofsTableViewController.h
//  BVerifyClient
//
//  Created by Gert-Jaap Glasbergen on 26/03/2019.
//  Copyright © 2019 Gert-Jaap Glasbergen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVerifyManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface MyProofsTableViewController : UITableViewController
@property (nonatomic, retain) BVerifyStatus *status;
@property (nonatomic, retain) NSTimer *refreshTimer;
@property (nonatomic, retain) NSArray *logs;
@end

NS_ASSUME_NONNULL_END
