//
//  MyProofsTableViewController.m
//  BVerifyClient
//
//  Created by Gert-Jaap Glasbergen on 26/03/2019.
//  Copyright © 2019 Gert-Jaap Glasbergen. All rights reserved.
//

#import "MyProofsTableViewController.h"
#import "QRCodeReaderViewController/QRCodeReaderViewController.h"
#import "BVerifyManager.h"

@interface MyProofsTableViewController ()

@end

@implementation MyProofsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
         [self refreshStatus];
    }];
   
    [_refreshTimer fire];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)refreshStatus {
    [BVerifyManager getStatus:^(BVerifyStatus *status) {
        self.status = status;
        [BVerifyManager getLogs:^(NSArray *logs) {
            self.logs = logs;
            [self.tableView reloadData];
        }];
    }];
    
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    uint64_t numLogs = 0;
    if(self.logs != nil) {
        numLogs = [self.logs count];
    }
    
    if(indexPath.row > 0 && indexPath.row <= numLogs) {
        return 55.0f;
    }
    
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    uint64_t numLogs = 0;
    if(self.logs != nil) {
        numLogs = [self.logs count];
    }
    return 2 + numLogs;
}

- (IBAction)addNew:(id)sender {
   QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
   QRCodeReaderViewController *qrvc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
   qrvc.modalPresentationStyle = UIModalPresentationFormSheet;
    [qrvc setCompletionWithBlock:^(NSString *resultAsString) {
        [BVerifyManager addForeignLog:resultAsString withCallback:^(bool result) {
            if(result){
                [self refreshStatus];
            }
            [qrvc dismissViewControllerAnimated:YES completion:^{
                 if(!result){
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Could not add log"
                                                                                   message:@"The scanned log is not valid"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
            
        }];
        
    }];
    [self presentViewController:qrvc animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    
    uint64_t numLogs = 0;
    if(self.logs != nil) {
        numLogs = [self.logs count];
    }
    if(indexPath.row == 0) {
        if(_status != nil && _status.synced) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SyncedCell" forIndexPath:indexPath];
            
            ((UILabel *)[cell viewWithTag:1000]).text = [NSString stringWithFormat:@"Synced (%@ blocks)",_status.blockHeight];
                                                         
            
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SyncingCell" forIndexPath:indexPath];
    
            ((UILabel *)[cell viewWithTag:1000]).text = [NSString stringWithFormat:@"Syncing (%@ blocks)",_status.blockHeight];
            
            return cell;
        }
    } else if(indexPath.row <= numLogs) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProofCell" forIndexPath:indexPath];
        
        BVerifyLog *log = [self.logs objectAtIndex:indexPath.row-1];
        if([log.lastStatement isEqualToString:@""]) {
            ((UILabel *)[cell viewWithTag:1000]).text = log.logID;
        } else {
            ((UILabel *)[cell viewWithTag:1000]).text = log.lastStatement;
        }
        
        if(log.valid) {
            ((UILabel *)[cell viewWithTag:1001]).text = [NSString stringWithFormat:@"Valid at %@", [df stringFromDate:log.lastCommitmentTimestamp]];
        } else {
            ((UILabel *)[cell viewWithTag:1001]).text = [NSString stringWithFormat:@"Invalid: %@", log.error];
        }
        
        return cell;
    } else if(indexPath.row == 1 + numLogs) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddNewCell" forIndexPath:indexPath];
        
        ((UILabel *)[cell viewWithTag:1000]).text = [NSString stringWithFormat:@"Synced (%@ blocks)",_status.blockHeight];
        
        
        return cell;
    }
    return nil;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
